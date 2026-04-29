"use client";

import { getAllConversation, getMessagesById, sentMessage, getPusherConfig } from "@/actions/others";
import { getUser } from "@/actions/auth";
import { getUserStatusById } from "@/actions/userStatus";
import ChattingList from "@/components/chats/ChattingList";
import DealBuilder from "@/components/chats/DealBuilder";
import Container from "@/components/shared/Container";
import Image from "next/image";
import { useState, useEffect, useRef } from "react";
import { FaArrowLeft, FaPaperPlane, FaUser } from "react-icons/fa";
import { toast } from "sonner";
import { checkForContactInfo, getContactErrorMessage, trackViolation } from "@/utils/contactFilter";
import { browseActiveCards } from "@/actions/product";
import { getBuyerInterests } from "@/actions/buyerProfile";
import Pusher from "pusher-js";

export default function ChatPage() {
  const [conversations, setConversations] = useState([]);
  const [selectedConversation, setSelectedConversation] = useState(null);
  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState("");
  const [isLoading, setIsLoading] = useState(true);
  const [currentUser, setCurrentUser] = useState(null);
  const [isOnline, setIsOnline] = useState(false);
  const [pusherConfig, setPusherConfig] = useState(null);
  const [pusher, setPusher] = useState(null);
  const [showScrollButton, setShowScrollButton] = useState(false);
  const messagesEndRef = useRef(null);
  const messagesContainerRef = useRef(null);

  // Load conversations and current user
  useEffect(() => {
    const loadData = async () => {
      try {
        setIsLoading(true);
        
        // Get current user
        const { data: user } = await getUser();
        setCurrentUser(user);
        
        // Get Pusher configuration
        const pusherConfigResult = await getPusherConfig();
        console.log('🔧 Pusher config result:', pusherConfigResult);
        if (pusherConfigResult.status === 'success') {
          setPusherConfig(pusherConfigResult.data);
          console.log('✅ Pusher config loaded:', pusherConfigResult.data);
        } else {
          console.error('❌ Failed to load Pusher config:', pusherConfigResult);
        }
        
        // Get conversations
        const conversationsResult = await getAllConversation();
        if (conversationsResult.status === 'success') {
          setConversations(conversationsResult.data);
        }
      } catch (error) {
        console.error('Error loading data:', error);
        toast.error("Failed to load conversations");
      } finally {
        setIsLoading(false);
      }
    };

    loadData();
  }, []);

  // Load messages when conversation is selected
  useEffect(() => {
    const loadMessages = async () => {
      if (selectedConversation) {
        try {
          const messagesResult = await getMessagesById(selectedConversation.id);
          if (messagesResult.status === 'success') {
            const list = messagesResult.data.reverse();
            setMessages(applyDealRemovals(list));
            // Auto-scroll to bottom after loading messages
            setTimeout(() => {
              scrollToBottom();
            }, 200);
          }
        } catch (error) {
          console.error('Error loading messages:', error);
          toast.error("Failed to load messages");
        }
      }
    };

    loadMessages();
  }, [selectedConversation]);

  // Initialize WebSocket connection for real-time messaging
  useEffect(() => {
    if (pusherConfig && selectedConversation) {
      console.log('🔌 Initializing Pusher WebSocket connection for conversation:', selectedConversation.id);
      
      const pusherInstance = new Pusher(pusherConfig.pusher_app_key, {
        cluster: pusherConfig.pusher_app_cluster,
        encrypted: true,
        forceTLS: true,
      });
      
      setPusher(pusherInstance);
      
      const channel = pusherInstance.subscribe(`conversation.${selectedConversation.id}`);
      
      // Listen for new messages
      channel.bind('message.sent', (data) => {
        console.log('📨 Received new message via WebSocket:', data);
        console.log('📨 Message data structure:', JSON.stringify(data, null, 2));
        
        const isOwnMessage = data.message?.user_id === currentUser?.id;

        // Intercept deal removal messages: update state by removing items and do not append
        try {
          if (typeof data.message?.message === 'string') {
            const obj = JSON.parse(data.message.message);
            if (obj && obj.type === 'deal_item_removed' && obj.itemId) {
              setMessages(prev => prev.filter(m => {
                const hasDeal = m.deal_item && m.deal_item.id === obj.itemId;
                if (hasDeal) return false;
                if (typeof m.message === 'string') {
                  try {
                    const parsed = JSON.parse(m.message);
                    if (parsed && parsed.type === 'deal_item' && parsed.item && parsed.item.id === obj.itemId) {
                      return false;
                    }
                  } catch (_) {}
                }
                return true;
              }));
              return; // stop normal processing for removal - don't show the JSON message
            }
          }
        } catch (_) {}
        
        // Add a small delay for own messages to ensure optimistic message is processed first
        const processMessage = () => {
          setMessages(prev => {
            const messageExists = prev.some(msg => msg.id === data.message?.id);
            const optimisticExists = prev.some(msg => msg.is_optimistic && msg.message === data.message?.message);
            
            if (!messageExists) {
              if (optimisticExists && isOwnMessage) {
                // For own messages, replace optimistic with real message
                console.log('📨 WebSocket: Replacing own optimistic message with real message');
                return prev.map(msg => 
                  msg.is_optimistic && msg.message === data.message?.message 
                    ? { ...data.message, is_optimistic: false } 
                    : msg
                );
              } else if (optimisticExists && !isOwnMessage) {
                // For other's messages, just add the real message (don't replace optimistic)
                console.log('📨 WebSocket: Adding other user message');
                return [...prev, data.message];
              } else {
                // Add new message
                console.log('📨 WebSocket: Adding new message to chat');
                return [...prev, data.message];
              }
            } else {
              console.log('📨 WebSocket: Message already exists, skipping duplicate');
              return prev;
            }
          });
        };
        
        // For own messages, don't process WebSocket updates to prevent interference
        if (isOwnMessage) {
          console.log('📨 WebSocket: Ignoring own message to prevent optimistic message interference');
          return; // Don't process own messages via WebSocket
        } else {
          processMessage(); // Process other's messages immediately
        }
      });
      
      // Handle connection events
      pusherInstance.connection.bind('connected', () => {
        console.log('✅ Pusher connected successfully');
      });
      
      pusherInstance.connection.bind('disconnected', () => {
        console.log('❌ Pusher disconnected');
      });
      
      pusherInstance.connection.bind('error', (error) => {
        console.error('🚨 Pusher connection error:', error);
      });
      
      // Cleanup on unmount or conversation change
      return () => {
        console.log('🔌 Cleaning up Pusher connection...');
        pusherInstance.unsubscribe(`conversation.${selectedConversation.id}`);
        pusherInstance.disconnect();
      };
    }
  }, [pusherConfig, selectedConversation]);

  // Fallback: Poll for new messages every 3 seconds if WebSocket fails
  useEffect(() => {
    if (selectedConversation && (!pusher || pusher.connection.state !== 'connected')) {
      console.log('🔄 WebSocket not connected, starting fallback polling...');
      
      const pollInterval = setInterval(async () => {
        try {
          const messagesResult = await getMessagesById(selectedConversation.id);
          if (messagesResult.status === 'success') {
            const newMessages = applyDealRemovals(messagesResult.data.reverse());
            setMessages(prev => {
              // Only update if there are new messages
              if (newMessages.length !== prev.length) {
                console.log('📨 Polling found new messages:', newMessages.length - prev.length);
                return newMessages;
              }
              return prev;
            });
          }
        } catch (error) {
          console.error('❌ Polling error:', error);
        }
      }, 3000); // Poll every 3 seconds
      
      return () => clearInterval(pollInterval);
    }
  }, [pusher, selectedConversation]);

  // Helper: compute final deal state per item using message chronology (oldest -> newest)
  // Keeps only the latest "add" message for each item, hides all removal messages,
  // and attaches deal_item for convenience.
  const applyDealRemovals = (list) => {
    try {
      const finalState = new Map(); // itemId -> { type: 'add'|'removed', lastAddMessageId: number }
      const parsedCache = new Map();

      const parse = (m) => {
        if (parsedCache.has(m)) return parsedCache.get(m);
        let res = null;
        if (m.deal_item) {
          res = { type: 'deal_item', item: m.deal_item };
        } else if (typeof m.message === 'string') {
          try {
            const obj = JSON.parse(m.message);
            if (obj && obj.type === 'deal_item' && obj.item) res = { type: 'deal_item', item: obj.item };
            else if (obj && obj.type === 'deal_item_removed' && obj.itemId) res = { type: 'removed', itemId: obj.itemId };
          } catch (_) {}
        }
        parsedCache.set(m, res);
        return res;
      };

      // Compute final state in chronological order
      for (const m of list) {
        const p = parse(m);
        if (!p) continue;
        if (p.type === 'deal_item') {
          finalState.set(p.item.id, { type: 'add', lastAddMessageId: m.id });
        } else if (p.type === 'removed') {
          finalState.set(p.itemId, { type: 'removed' });
        }
      }

      // Build filtered list
      return list
        .filter(m => {
          const p = parse(m);
          if (!p) return true; // normal text
          if (p.type === 'removed') return false; // never show removal JSON
          // Only keep the latest add if final state is add
          const state = finalState.get(p.item.id);
          return state && state.type === 'add' && state.lastAddMessageId === m.id;
        })
        .map(m => {
          if (!m.deal_item) {
            const p = parse(m);
            if (p && p.type === 'deal_item') return { ...m, deal_item: p.item };
          }
          return m;
        });
    } catch (e) {
      return list;
    }
  };

  // Scroll to bottom when new messages arrive (only for chat container, not browser)
  const scrollToBottom = () => {
    if (messagesContainerRef.current) {
      messagesContainerRef.current.scrollTop = messagesContainerRef.current.scrollHeight;
    }
  };

  // Auto-scroll to bottom when conversation is selected
  useEffect(() => {
    if (selectedConversation && messages.length > 0) {
      // Small delay to ensure DOM is updated
      setTimeout(() => {
        scrollToBottom();
      }, 100);
    }
  }, [selectedConversation]);

  // Only auto-scroll if user is near the bottom of chat for new messages
  useEffect(() => {
    const container = messagesContainerRef.current;
    if (!container) return;

    const { scrollTop, scrollHeight, clientHeight } = container;
    const isNearBottom = scrollHeight - scrollTop - clientHeight < 100;
    
    // Only auto-scroll if user is already near the bottom
    if (isNearBottom) {
      scrollToBottom();
    }
  }, [messages]);

  // Handle scroll events to show/hide scroll button
  useEffect(() => {
    const container = messagesContainerRef.current;
    if (!container) return;

    const handleScroll = () => {
      const { scrollTop, scrollHeight, clientHeight } = container;
      const isNearBottom = scrollHeight - scrollTop - clientHeight < 100;
      setShowScrollButton(!isNearBottom);
    };

    container.addEventListener('scroll', handleScroll);
    return () => container.removeEventListener('scroll', handleScroll);
  }, []);

  // Check online status from database
  const checkOnlineStatus = async () => {
    if (selectedConversation) {
      try {
        // Get the other participant
        const otherParticipant = selectedConversation.sender_id === currentUser?.id 
          ? selectedConversation.receiver 
          : selectedConversation.sender;
        
        if (otherParticipant?.id) {
          const result = await getUserStatusById(otherParticipant.id);
          if (result?.status === 'success') {
            setIsOnline(result.data.is_online);
          }
        }
      } catch (error) {
        console.error('Error checking online status:', error);
        setIsOnline(false);
      }
    }
  };

  useEffect(() => {
    if (selectedConversation) {
      checkOnlineStatus();
      const interval = setInterval(checkOnlineStatus, 30000);
      return () => clearInterval(interval);
    }
  }, [selectedConversation, checkOnlineStatus]);

  // Handle conversation selection
  const handleConversationSelect = (conversation) => {
    setSelectedConversation(conversation);
  };

  // Send message
  const handleSendMessage = async (e) => {
    e.preventDefault();
    
    if (!newMessage.trim() || !selectedConversation) return;
    
    // Check for contact information before sending
    const contactCheck = checkForContactInfo(newMessage.trim());
    
    if (contactCheck.hasContact) {
      const errorMessage = getContactErrorMessage(contactCheck.violations);
      toast.error(errorMessage);
      
      // Track the violation on backend
      try {
        await trackViolation(contactCheck.violations, newMessage.trim(), 'chat');
      } catch (error) {
        console.error('Failed to track violation:', error);
      }
      
      return;
    }
    
    // Create optimistic message for immediate display
    const optimisticMessage = {
      id: `temp_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`, // More unique temporary ID
      message: newMessage.trim(),
      user_id: currentUser?.id,
      conversation_id: selectedConversation.id,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      is_optimistic: true, // Flag to identify optimistic messages
      temp_id: `temp_${Date.now()}_${Math.random().toString(36).substr(2, 9)}` // Additional unique identifier
    };

    // Add message immediately for instant feedback with high priority
    setMessages(prev => {
      // Ensure optimistic message is always added first
      const newMessages = [...prev, optimisticMessage];
      console.log('📝 Added optimistic message with priority');
      return newMessages;
    });
    setNewMessage("");
    
    // Add a backup mechanism to ensure optimistic message stays visible
    const backupTimeout = setTimeout(() => {
      setMessages(prev => {
        const optimisticExists = prev.some(msg => msg.id === optimisticMessage.id);
        if (!optimisticExists) {
          console.log('🔄 Backup: Re-adding optimistic message');
          return [...prev, optimisticMessage];
        }
        return prev;
      });
    }, 1000); // Check after 1 second
    
    // Add visual feedback for longer messages
    if (optimisticMessage.message.length > 100) {
      console.log('📝 Long message detected, extending processing time');
    }
    
    // Send message in background without blocking UI
    const sendMessageAsync = async () => {
      try {
        const messageData = {
          conversation_id: selectedConversation.id,
          message: optimisticMessage.message
        };
        
        const result = await sentMessage(messageData);
        
        if (result.status === 'success') {
          // Clear backup timeout
          clearTimeout(backupTimeout);
          
          // Only replace if optimistic message still exists, otherwise add the real message
          console.log('✅ API response: Processing successful message');
          setMessages(prev => {
            const optimisticExists = prev.some(msg => msg.id === optimisticMessage.id);
            const realMessageExists = prev.some(msg => msg.id === result.data.id);
            
            if (optimisticExists && !realMessageExists) {
              // Replace optimistic with real message
              console.log('✅ API response: Replacing optimistic message');
              return prev.map(msg => 
                msg.id === optimisticMessage.id ? { ...result.data, is_optimistic: false } : msg
              );
            } else if (!optimisticExists && !realMessageExists) {
              // Add real message if optimistic was removed
              console.log('✅ API response: Adding real message');
              return [...prev, { ...result.data, is_optimistic: false }];
            } else {
              // Real message already exists, do nothing
              console.log('✅ API response: Real message already exists');
              return prev;
            }
          });
          console.log('✅ Message sent successfully and updated');
        } else {
          // Remove optimistic message on failure
          setMessages(prev => prev.filter(msg => msg.id !== optimisticMessage.id));
          toast.error(result.message || "Failed to send message");
        }
      } catch (error) {
        console.error('Error sending message:', error);
        // Remove optimistic message on error
        setMessages(prev => prev.filter(msg => msg.id !== optimisticMessage.id));
        toast.error("Failed to send message");
      }
    };
    
    // Start sending in background
    sendMessageAsync();
  };

  // Determine the other participant
  const otherParticipant = selectedConversation && currentUser ? 
    (selectedConversation.sender_id === currentUser.id 
      ? selectedConversation.receiver 
      : selectedConversation.sender) : null;

  if (isLoading) {
    return (
      <Container>
        <div className="flex items-center justify-center h-screen">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600 mx-auto mb-4"></div>
            <p className="text-gray-600">Loading chats...</p>
          </div>
        </div>
      </Container>
    );
  }

  return (
    <Container>
      <div className="xl:border border-border rounded xl:p-7 lg:mt-6 h-[calc(100vh-90px)] lg:h-[calc(100vh-250px)] xl:h-[calc(100vh-250px)] overflow-hidden">
        {conversations?.length > 0 ? (
          <div className="grid grid-cols-1 lg:grid-cols-[362px_1fr] gap-5 h-full">
            {/* Chat List */}
            <div className="space-y-3 overflow-y-auto no-scrollbar">
              {conversations?.map((item) => (
                <div key={item.id} onClick={() => handleConversationSelect(item)}>
                  <ChattingList 
                    data={item} 
                    isSelected={selectedConversation?.id === item.id}
                    currentUser={currentUser}
                  />
                </div>
              ))}
            </div>

            {/* Chat Interface */}
            <div className="flex flex-col lg:flex-row h-full overflow-hidden min-h-0">
              <div className="flex-1 flex flex-col">
                {selectedConversation ? (
                  <>
                    {/* Chat Header */}
                    <div className="bg-white border-b border-gray-200 p-4 flex items-center justify-between">
                      <div className="flex items-center space-x-3">
                        <div className="flex items-center space-x-3">
                          <div className="relative">
                            {otherParticipant?.profile?.avatar ? (
                              <Image
                                src={`${process.env.NEXT_PUBLIC_IMG_URL}/${otherParticipant.profile.avatar}`}
                                alt={otherParticipant?.name || "User"}
                                width={40}
                                height={40}
                                className="w-10 h-10 rounded-full object-cover"
                              />
                            ) : (
                              <div className="w-10 h-10 bg-green-100 rounded-full flex items-center justify-center">
                                <FaUser className="w-5 h-5 text-green-600" />
                              </div>
                            )}
                            {/* Online/Offline Status Badge */}
                            <div 
                              className={`absolute -bottom-1 -right-1 w-4 h-4 rounded-full border-2 border-white shadow-sm ${
                                isOnline ? 'bg-green-500' : 'bg-gray-400'
                              }`} 
                              title={isOnline ? 'Online' : 'Offline'}
                              style={{
                                zIndex: 10,
                                backgroundColor: isOnline ? '#10b981' : '#9ca3af'
                              }}
                            ></div>
                          </div>
                          <div>
                            <div className="flex items-center space-x-2">
                              <h3 className="font-semibold text-gray-900">
                                {otherParticipant?.profile?.username || otherParticipant?.name || "Loading..."}
                              </h3>
                              <span className={`text-xs px-2 py-1 rounded-full ${
                                isOnline 
                                  ? 'bg-green-100 text-green-800' 
                                  : 'bg-gray-100 text-gray-600'
                              }`}>
                                {isOnline ? 'Online' : 'Offline'}
                              </span>
                            </div>
                            <p className="text-sm text-gray-500">
                              {selectedConversation?.conversation_type === 'buyer_profile' ? 'Buyer Profile Chat' : 'Product Chat'}
                            </p>
                          </div>
                        </div>
                      </div>
                    </div>

                   {/* Messages Area */}
                   <div 
                     ref={messagesContainerRef}
                     className="flex-1 overflow-y-auto p-4 space-y-4 bg-gray-50 chat-scrollbar relative"
                     data-responsive="chat-container"
                     style={{
                       scrollbarWidth: 'thin',
                       scrollbarColor: '#cbd5e1 #f1f5f9',
                       height: 'calc(100vh - 280px)', // Much more space for header and input
                       minHeight: '150px', // Very small minimum height for laptop screens
                       maxHeight: 'calc(100vh - 280px)' // Ensure it doesn't exceed viewport
                     }}
                   >
                    {messages.length === 0 ? (
                      <div className="text-center py-8">
                        <p className="text-gray-500">No messages yet. Start the conversation!</p>
                      </div>
                    ) : (
                      messages.map((message) => {
                        // Try to derive a deal item from structured JSON message payload
                        let parsedDealItem = null;
                        if (!message.deal_item && typeof message.message === 'string') {
                          try {
                            const obj = JSON.parse(message.message);
                            if (obj && obj.type === 'deal_item' && obj.item) {
                              parsedDealItem = obj.item;
                            }
                          } catch (e) {}
                        }
                        const dealItem = message.deal_item || parsedDealItem;
                        return (
                        <div
                          key={message.id}
                          className={`flex ${message.user_id === currentUser?.id ? 'justify-end' : 'justify-start'}`}
                        >
                          {dealItem ? (
                            <div className="max-w-xs lg:max-w-md p-3 rounded-lg bg-white border border-green-200">
                              <div className="flex gap-3">
                                <div className="relative w-16 h-16 bg-gray-100 rounded overflow-hidden">
                                  {dealItem.image ? (
                                    <Image 
                                      src={dealItem.image} 
                                      alt={dealItem.title} 
                                      fill 
                                      className="object-cover" 
                                    />
                                  ) : (
                                    <div className="w-full h-full" />
                                  )}
                                </div>
                                <div className="flex-1 min-w-0">
                                  <p className="text-sm font-medium text-gray-900 truncate">{dealItem.title}</p>
                                  <p className="text-xs text-gray-600 mt-0.5">${dealItem.price}</p>
                                  <p className="text-[10px] text-green-700 mt-1">Added to deal</p>
                                </div>
                              </div>
                            </div>
                          ) : (
                            <div
                                className={`max-w-xs lg:max-w-md px-4 py-2 rounded-lg ${
                                 message.user_id === currentUser?.id
                                   ? 'bg-skyBlue text-white'
                                   : 'bg-white text-gray-900 border border-gray-200'
                               }`}
                            >
                              <p className="text-sm">{message.message}</p>
                              <p className={`text-xs mt-1 flex items-center ${
                                message.user_id === currentUser?.id ? 'text-white/80' : 'text-gray-500'
                              }`}>
                                {new Date(message.created_at).toLocaleTimeString([], {
                                  hour: '2-digit',
                                  minute: '2-digit'
                                })}
                                {message.is_optimistic && (
                                  <span className="ml-2 text-xs">
                                    <div className="inline-block w-2 h-2 bg-current rounded-full animate-pulse"></div>
                                  </span>
                                )}
                              </p>
                            </div>
                          )}
                        </div>
                        );
                      })
                     )}
                     <div ref={messagesEndRef} />
                     
                     {/* Scroll to bottom button */}
                     {showScrollButton && (
                       <button
                         onClick={() => {
                           if (messagesContainerRef.current) {
                             messagesContainerRef.current.scrollTop = messagesContainerRef.current.scrollHeight;
                           }
                         }}
                         className="absolute bottom-4 right-4 bg-green-600 hover:bg-green-700 text-white p-2 rounded-full shadow-lg transition-all duration-200 z-10"
                         title="Scroll to bottom"
                       >
                         <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                           <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 14l-7 7m0 0l-7-7m7 7V3" />
                         </svg>
                       </button>
                     )}
                   </div>

                    {/* Message Input */}
                    <div className="bg-white border-t border-gray-200 p-4">
                      <form onSubmit={handleSendMessage} className="flex space-x-2">
                        <input
                          type="text"
                          value={newMessage}
                          onChange={(e) => setNewMessage(e.target.value)}
                          placeholder="Type your message..."
                          className="flex-1 border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent"
                        />
                        <button
                          type="submit"
                          disabled={!newMessage.trim()}
                          className="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center space-x-2"
                        >
                          <FaPaperPlane className="w-4 h-4" />
                        </button>
                      </form>
                    </div>
                  </>
                ) : (
                  <div className="flex-1 flex items-center justify-center bg-gray-50">
                    <div className="text-center">
                      <FaUser className="mx-auto text-6xl text-gray-300 mb-4" />
                      <h3 className="text-lg font-medium text-gray-900 mb-2">Select a conversation</h3>
                      <p className="text-gray-500">Choose a chat from the list to start messaging</p>
                    </div>
                  </div>
                )}
              </div>

              {/* Deal Builder Sidebar */}
              {selectedConversation && otherParticipant?.id && (
                <DealBuilder
                  sellerId={selectedConversation.conversation_type === 'product' ? otherParticipant.id : currentUser?.id}
                  buyerId={selectedConversation.conversation_type === 'buyer_profile' ? otherParticipant.id : null}
                  conversationId={selectedConversation.id}
                  conversationType={selectedConversation.conversation_type}
                  currentUserId={currentUser?.id}
                  messages={messages}
                  fetchSellerListings={async (sellerId, search) => {
                    const params = new URLSearchParams({ limit: '100' });
                    if (search) params.set('search', search);
                    const res = await browseActiveCards(params.toString());
                    const list = res?.data || [];
                    return list
                      .filter((c) => c?.seller?.id === sellerId)
                      .map((c) => ({
                        id: c.id,
                        title: c.card_title,
                        price: c.price,
                        image: c.images?.[0]
                          ? `${process.env.NEXT_PUBLIC_IMG_URL}/${c.images[0]}`
                          : ''
                      }));
                  }}
                  fetchBuyerInterests={async (buyerId, search) => {
                    const res = await getBuyerInterests(buyerId, search);
                    return res?.data || [];
                  }}
                  onAdd={(message) => {
                    setMessages((prev) => [...prev, message]);
                  }}
                  onRemove={(itemId) => {
                    setMessages(prev => prev.filter(m => {
                      const hasDeal = m.deal_item && m.deal_item.id === itemId;
                      if (hasDeal) return false;
                      if (typeof m.message === 'string') {
                        try {
                          const parsed = JSON.parse(m.message);
                          if (parsed && parsed.type === 'deal_item' && parsed.item && parsed.item.id === itemId) {
                            return false;
                          }
                        } catch (_) {}
                      }
                      return true;
                    }));
                  }}
                />
              )}
            </div>
          </div>
        ) : (
          <Image
            src="/images/empty-conversation.png"
            alt="no item found"
            width={0}
            height={0}
            sizes="100vw"
            className="w-full md:w-1/2 lg:w-1/5 h-auto mx-auto mt-10 lg:mt-20"
          />
        )}
      </div>
    </Container>
  );
};
