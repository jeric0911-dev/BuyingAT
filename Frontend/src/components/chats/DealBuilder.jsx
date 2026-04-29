"use client";

import Image from "next/image";
import { useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { addToCart } from "@/actions/cart";
import { sentMessage } from "@/actions/others";
import { toast } from "sonner";

// Props:
// - sellerId: number (required) -> whose inventory to load
// - buyerId: number (optional) -> buyer id for buyer profile conversations
// - conversationId: number (required) -> conversation id for saving messages
// - conversationType: string (required) -> 'buyer_profile' or 'product'
// - currentUserId: number (optional) -> current logged in user id to determine if checkout button should show
// - onAdd: (itemMessage) => void (required) -> notify chat to append added item message
// - onRemove: (itemId) => void (optional) -> notify chat to remove the item message
// - initialSelected: array of item ids (optional)
// - messages: array (optional) -> existing messages to initialize bundle from
// - fetchSellerListings: async (sellerId, search) => [{id, title, price, image}]
// - fetchBuyerInterests: async (buyerId, search) => [{id, title, price, image}] (optional)

const DealBuilder = ({ sellerId, buyerId, conversationId, conversationType, currentUserId, onAdd, onRemove, initialSelected = [], messages = [], fetchSellerListings, fetchBuyerInterests }) => {
  const router = useRouter();
  const [query, setQuery] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [items, setItems] = useState([]);
  const [selectedIds, setSelectedIds] = useState(new Set(initialSelected));
  const [bundle, setBundle] = useState([]);
  const [checkoutLoading, setCheckoutLoading] = useState(false);
  const [buyerAddedItems, setBuyerAddedItems] = useState(new Set()); // Track which items the buyer added

  const load = async () => {
    try {
      setLoading(true);
      setError("");
      
      let res = [];
      
      // Always show seller's cards regardless of conversation type
      if (sellerId && fetchSellerListings) {
        res = await fetchSellerListings(sellerId, query);
        console.log("========== Res data: ", res);
        
        // Log received card data from backend
        if (Array.isArray(res) && res.length > 0) {
          console.log('📥 [DealBuilder] Received card data from backend:', {
            totalCards: res.length,
            cards: res.map(card => ({
              id: card.id,
              title: card.title,
              price: card.price,
              hasImage: !!card.image
            })),
            sellerId,
            query: query || '(empty)'
          });
        } else if (Array.isArray(res) && res.length === 0) {
          console.log('📥 [DealBuilder] Received empty card data from backend:', {
            sellerId,
            query: query || '(empty)'
          });
        }
      }
      
      const itemsArray = Array.isArray(res) ? res : [];
      setItems(itemsArray);
    } catch (e) {
      setError("Failed to load seller's cards");
    } finally {
      setLoading(false);
    }
  };

  // Initialize bundle from existing messages using chronology (last event wins)
  useEffect(() => {
    if (!messages || messages.length === 0) {
      setBundle([]);
      setSelectedIds(new Set());
      setBuyerAddedItems(new Set());
      return;
    }

    try {
      const finalState = new Map(); // itemId -> item | null (null = removed)
      const buyerAddedSet = new Set(); // Track items added by buyer

      for (const m of messages) {
        // Parse message
        let parsed = null;
        if (m.deal_item) {
          parsed = { type: 'deal_item', item: m.deal_item };
        } else if (typeof m.message === 'string') {
          try {
            const obj = JSON.parse(m.message);
            if (obj && obj.type === 'deal_item' && obj.item) parsed = { type: 'deal_item', item: obj.item };
            else if (obj && obj.type === 'deal_item_removed' && obj.itemId) parsed = { type: 'removed', itemId: obj.itemId };
          } catch (_) {}
        }
        if (!parsed) continue;
        if (parsed.type === 'deal_item') {
          finalState.set(parsed.item.id, parsed.item);
          // Track if this item was added by the buyer (current user)
          if (currentUserId && m.user_id === currentUserId) {
            buyerAddedSet.add(parsed.item.id);
          }
        } else if (parsed.type === 'removed') {
          finalState.set(parsed.itemId, null);
          buyerAddedSet.delete(parsed.itemId); // Remove from buyer-added set if removed
        }
      }

      const dealItems = Array.from(finalState.entries())
        .filter(([, item]) => !!item)
        .map(([, item]) => item);

      setBundle(dealItems);
      setSelectedIds(new Set(dealItems.map(i => i.id)));
      setBuyerAddedItems(buyerAddedSet);
    } catch (error) {
      console.error('Error initializing bundle from messages:', error);
      setBundle([]);
      setSelectedIds(new Set());
      setBuyerAddedItems(new Set());
    }
  }, [messages, conversationId, currentUserId]);

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [sellerId, buyerId, conversationType]);

  const handleAdd = async (item) => {
    if (!item || !conversationId) return;
    
    try {
      // Add to local state first for immediate UI feedback
      setSelectedIds(prev => new Set(prev).add(item.id));
      setBundle(prev => [...prev, item]);
      // Track if buyer added this item
      if (currentUserId) {
        setBuyerAddedItems(prev => new Set(prev).add(item.id));
      }
      
      // Save as a message to the backend
      // Persist as a structured JSON payload so receivers can render the card block
      const messageData = {
        conversation_id: conversationId,
        message: JSON.stringify({
          type: 'deal_item',
          item: {
            id: item.id,
            title: item.title,
            price: item.price,
            image: item.image || ''
          }
        })
      };
      
      const result = await sentMessage(messageData);
      
      if (result.status === 'success') {
        // Notify parent component with the saved message
        onAdd?.({
          ...result.data,
          // Keep a normalized deal_item for immediate UI
          deal_item: item
        });
      } else {
        // If backend save fails, remove from local state
        setSelectedIds(prev => {
          const newSet = new Set(prev);
          newSet.delete(item.id);
          return newSet;
        });
        setBundle(prev => prev.filter(bundleItem => bundleItem.id !== item.id));
        setBuyerAddedItems(prev => {
          const newSet = new Set(prev);
          newSet.delete(item.id);
          return newSet;
        });
        toast.error('Failed to add item to deal');
      }
    } catch (error) {
      console.error('Error adding item to deal:', error);
      // Remove from local state on error
      setSelectedIds(prev => {
        const newSet = new Set(prev);
        newSet.delete(item.id);
        return newSet;
      });
      setBundle(prev => prev.filter(bundleItem => bundleItem.id !== item.id));
      setBuyerAddedItems(prev => {
        const newSet = new Set(prev);
        newSet.delete(item.id);
        return newSet;
      });
      toast.error('Failed to add item to deal');
    }
  };

  const handleRemove = async (itemId) => {
    setSelectedIds(prev => {
      const newSet = new Set(prev);
      newSet.delete(itemId);
      return newSet;
    });
    setBundle(prev => prev.filter(item => item.id !== itemId));
    setBuyerAddedItems(prev => {
      const newSet = new Set(prev);
      newSet.delete(itemId);
      return newSet;
    });

    // Inform chat via a structured removal message so both sides update in real time
    try {
      if (!conversationId) return;
      const messageData = {
        conversation_id: conversationId,
        message: JSON.stringify({ type: 'deal_item_removed', itemId })
      };
      await sentMessage(messageData);
      // Optimistic UI removal for the sender
      onRemove?.(itemId);
    } catch (e) {
      // no-op; local removal already applied
    }
  };

  const handleCheckout = async () => {
    if (bundle.length === 0) return;
    
    setCheckoutLoading(true);
    try {
      // Add all bundle items to cart
      // All items in the bundle are from the same seller (sellerId prop)
      const cartPromises = bundle.map(async (item) => {
        try {
          const result = await addToCart({
            product_id: item.id,
            quantity: 1,
            vendor_id: sellerId, // Use the sellerId prop since all bundle items are from the same seller
            is_card: true // All items from DealBuilder are cards
          });
          
          return result;
        } catch (error) {
          console.error('Error adding item to cart:', item.id, error);
          return { status: 'error', message: error.message || 'Failed to add item to cart' };
        }
      });
      
      const results = await Promise.all(cartPromises);
      
      // Separate successful, already in cart, and failed items
      const successful = [];
      const alreadyInCart = [];
      const failed = [];
      
      results.forEach((r, idx) => {
        const item = bundle[idx];
        const isSuccess = r?.status === 'success' || (r?.message && r?.message.includes('successfully'));
        const isAlreadyInCart = r?.message && r?.message.toLowerCase().includes('already in your cart');
        
        if (isSuccess) {
          successful.push(item);
        } else if (isAlreadyInCart) {
          alreadyInCart.push(item);
        } else {
          failed.push({ item, error: r });
        }
      });
      
      // Show messages for different outcomes
      if (failed.length > 0) {
        // Show detailed error messages for actual failures
        const errorMessages = failed.map(({ item, error }) => {
          const errorMsg = error?.message || error?.error || 'Unknown error';
          return `${item?.title || 'Item'}: ${errorMsg}`;
        });
        
        console.error('Failed to add items to cart:', failed);
        toast.error(`Failed to add ${failed.length} item(s): ${errorMessages.join('; ')}`);
        
        // If some items succeeded, still proceed to checkout
        if (successful.length > 0 || alreadyInCart.length > 0) {
          setTimeout(() => {
            toast.info(`${successful.length + alreadyInCart.length} item(s) ready for checkout`);
            router.push('/shopping-cart/checkout');
          }, 2000);
        }
        setCheckoutLoading(false);
        return;
      }
      
      // All items either added successfully or already in cart
      const totalReady = successful.length + alreadyInCart.length;
      if (totalReady > 0) {
        let message = '';
        if (successful.length > 0 && alreadyInCart.length > 0) {
          message = `${successful.length} item(s) added, ${alreadyInCart.length} already in cart`;
        } else if (successful.length > 0) {
          message = `${successful.length} item(s) added to cart!`;
        } else {
          message = `${alreadyInCart.length} item(s) already in cart`;
        }
        
        toast.success(message);
        
        // Redirect to checkout
        router.push('/shopping-cart/checkout');
      } else {
        toast.error('No items were added to cart');
        setCheckoutLoading(false);
      }
    } catch (error) {
      console.error('Error adding items to cart:', error);
      toast.error('Failed to add items to cart: ' + (error.message || 'Unknown error'));
    } finally {
      setCheckoutLoading(false);
    }
  };

  const totalPrice = bundle.reduce((sum, item) => sum + (parseFloat(item.price) || 0), 0);

  // Determine if current user is a buyer
  // For 'product' conversations, current user is the buyer (buyerId is null, sellerId is otherParticipant)
  // For 'buyer_profile' conversations, otherParticipant is the buyer (buyerId is set)
  const isCurrentUserBuyer = conversationType === 'product' && currentUserId;
  
  // Check if buyer has added any items that are still in the bundle
  const buyerItemsInBundle = bundle.filter(item => buyerAddedItems.has(item.id));
  const buyerHasAddedItems = isCurrentUserBuyer && buyerItemsInBundle.length > 0;
  const shouldShowCheckout = buyerHasAddedItems && bundle.length > 0;

  const filtered = useMemo(() => {
    if (!query) return items;
    const q = query.toLowerCase();
    return items.filter(it => (it.title || "").toLowerCase().includes(q));
  }, [items, query]);

  return (
    <aside className="w-full lg:w-80 border-l border-gray-200 bg-white flex flex-col h-full">
      <div className="p-3 border-b border-gray-200">
        <h3 className="text-sm font-semibold text-gray-900">Deal Builder</h3>
        <p className="text-xs text-gray-500">
          Add more cards from this seller
        </p>
        <div className="mt-2 flex gap-2">
          <input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Search seller cards..."
            className="flex-1 px-2 py-1 text-sm border border-gray-300 rounded"
          />
          <button onClick={load} className="px-3 py-1 text-sm rounded bg-skyBlue text-white">Search</button>
        </div>
      </div>

      {/* Bundle Summary */}
      <div className="p-3 border-b border-gray-200 bg-green-50">
        <h4 className="text-sm font-semibold text-gray-900 mb-2">Deal Bundle ({bundle.length} items)</h4>
        <div className="space-y-2 max-h-32 overflow-y-auto">
          {bundle.length === 0 ? (
            <p className="text-xs text-gray-500 text-center py-2">No items in bundle yet</p>
          ) : (
            bundle.map((item) => (
              <div key={item.id} className="flex items-center justify-between text-xs">
                <span className="truncate flex-1">{item.title}</span>
                <div className="flex items-center gap-2">
                  <span className="text-gray-600">${item.price}</span>
                  <button
                    onClick={() => handleRemove(item.id)}
                    className="text-red-600 hover:text-red-800"
                  >
                    ×
                  </button>
                </div>
              </div>
            ))
          )}
        </div>
        <div className="mt-2 pt-2 border-t border-gray-200">
          <div className="flex justify-between items-center text-sm font-semibold">
            <span>Total:</span>
            <span>${totalPrice.toFixed(2)}</span>
          </div>
          {shouldShowCheckout && (
            <button
              onClick={handleCheckout}
              disabled={checkoutLoading || bundle.length === 0}
              style={{
                backgroundColor: bundle.length === 0 ? '#9ca3af' : '#16a34a',
                color: '#ffffff',
                width: '100%',
                marginTop: '8px',
                padding: '8px 12px',
                fontSize: '14px',
                borderRadius: '4px',
                border: 'none',
                cursor: (checkoutLoading || bundle.length === 0) ? 'not-allowed' : 'pointer',
                opacity: checkoutLoading ? 0.5 : 1
              }}
              className={bundle.length > 0 ? "hover:bg-green-700" : ""}
            >
              {checkoutLoading ? 'Approved offer...' : 'Checkout Bundle'}
            </button>
          )}
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-3 space-y-3">
        {loading && <p className="text-sm text-gray-500">Loading...</p>}
        {error && <p className="text-sm text-red-600">{error}</p>}
        {!loading && !error && filtered.length === 0 && (
          <p className="text-sm text-gray-500">No items found</p>
        )}
        {filtered.map((it) => (
          <div key={it.id} className="flex gap-3 border border-gray-200 rounded p-2">
            <div className="relative w-16 h-16 bg-gray-100 rounded overflow-hidden">
              {it.image ? (
                <Image src={it.image} alt={it.title} fill className="object-cover" />
              ) : (
                <div className="w-full h-full" />
              )}
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium text-gray-900 truncate">{it.title}</p>
              <p className="text-xs text-gray-600 mt-0.5">${it.price}</p>
              <div className="mt-2">
                <button
                  disabled={selectedIds.has(it.id)}
                  onClick={() => handleAdd(it)}
                  className={`px-3 py-1 text-xs rounded font-medium ${selectedIds.has(it.id) ? 'bg-gray-200 text-gray-500 cursor-not-allowed' : 'bg-skyBlue text-white hover:bg-skyBlueHover'}`}
                >
                  {selectedIds.has(it.id) ? 'Added' : 'Add to Deal'}
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </aside>
  );
};

export default DealBuilder;


