"use client";

import Image from "next/image";
import { FaUserCircle } from "react-icons/fa";
import { useState, useEffect } from "react";
import { getUserStatusById } from "../../actions/userStatus";

const ChattingList = ({ data, isSelected, currentUser }) => {
  const [userStatus, setUserStatus] = useState(null);
  const [statusLoading, setStatusLoading] = useState(false);
  
  // Always resolve the "other participant" the same way as header does
  const otherParticipant = data?.sender_id === currentUser?.id ? data?.receiver : data?.sender;

  // Use profile username when available, fallback to name
  const displayUser = otherParticipant;
  const displayName = displayUser?.profile?.username || displayUser?.name || "Unknown User";
  const displayAvatar = displayUser?.profile?.avatar || displayUser?.profile_img;

  // Function to fetch user status
  const fetchUserStatus = async (userId) => {
    setStatusLoading(true);
    try {
      const result = await getUserStatusById(userId);
      if (result?.status === 'success') {
        return result.data;
      }
    } catch (error) {
      console.error('Error fetching user status:', error);
    } finally {
      setStatusLoading(false);
    }
    return null;
  };

  // Fetch user status when component mounts or when displayUser changes
  useEffect(() => {
    if (displayUser?.id) {
      fetchUserStatus(displayUser.id).then(setUserStatus);
      
      // Set up interval to refresh status every 30 seconds
      const interval = setInterval(() => {
        fetchUserStatus(displayUser.id).then(setUserStatus);
      }, 30000);
      
      // Cleanup interval on unmount
      return () => clearInterval(interval);
    }
  }, [displayUser?.id]);

  // Determine if user is online based on database status
  const isOnline = userStatus?.is_online || false;

  return (
    <div
      className={`rounded p-3.5 grid grid-cols-[81px_1fr] gap-7 cursor-pointer transition-colors ${
        isSelected
          ? "bg-skyBlue/20 border border-skyBlue/60"
          : "bg-[#F5F7F9] hover:bg-gray-100"
      }`}
    >
        <div className="relative">
          <div className="w-[81px] h-[81px] rounded-full bg-gray-100 flex items-center justify-center">
            {displayAvatar ? (
              <Image
                src={`${process.env.NEXT_PUBLIC_IMG_URL}/${displayAvatar}`}
                alt="user"
                width={81}
                height={81}
                className="w-full h-full rounded-full object-cover"
              />
            ) : (
              <FaUserCircle className="size-12 text-gray-400" />
            )}
          </div>
          
          {/* Online/Offline Status Badge - positioned outside avatar */}
          <div 
            className={`absolute -bottom-1 -right-1 w-4 h-4 rounded-full border-2 border-white shadow-sm ${
              statusLoading 
                ? 'bg-yellow-400 animate-pulse' 
                : isOnline 
                  ? 'bg-green-500' 
                  : 'bg-gray-400'
            }`} 
            title={
              statusLoading 
                ? 'Checking status...' 
                : isOnline 
                  ? 'Online' 
                  : 'Offline'
            }
            style={{
              zIndex: 10,
              backgroundColor: statusLoading 
                ? '#facc15' 
                : isOnline 
                  ? '#10b981' 
                  : '#9ca3af'
            }}
          ></div>
        </div>
        <div className="overflow-hidden space-y-1">
          <p className="text-sm font-bold text-[#444444CC]">
            {displayName || "Unknown User"}
          </p>
          <p className="truncate text-sm text-gray-500">
            {(() => {
              const last = data?.messages?.[0];
              if (!last) return "No messages yet";
              const isOwn = last.user_id === currentUser?.id;
              let preview = last.message;
              // Try to parse structured deal item messages
              if (typeof last.message === 'string') {
                try {
                  const obj = JSON.parse(last.message);
                  if (obj && obj.type === 'deal_item' && obj.item) {
                    preview = `${isOwn ? 'You: ' : ''}Added to deal: ${obj.item.title} ($${obj.item.price})`;
                  } else if (isOwn) {
                    preview = `You: ${last.message}`;
                  }
                } catch (e) {
                  if (isOwn) preview = `You: ${last.message}`;
                }
              } else if (isOwn) {
                preview = `You: ${String(last.message)}`;
              }
              return preview;
            })()}
          </p>
        </div>
      </div>
  );
};

export default ChattingList;
