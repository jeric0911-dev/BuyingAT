"use client";

import { removeFromCart } from "@/actions/cart";
import { success } from "@/constants";
import Image from "next/image";
import { useState } from "react";
import { toast } from "sonner";
import useAuth from "@/hooks/useAuth";
import { saveCartCount } from "@/utils/localStorage";

const CartItem = ({ data }) => {
  const [loading, setLoading] = useState(false);
  const isCard = data?.itemType === 'card';
  const { setCartCount, setCardCartItems } = useAuth();

  const handleRemove = async () => {
    setLoading(true);
    
    // Optimistically update cart count immediately for real-time feedback
    if (setCartCount) {
      setCartCount((prev) => {
        const newCount = Math.max(0, prev - 1); // Ensure count doesn't go below 0
        // Save to localStorage for persistence on reload
        if (typeof window !== "undefined") {
          saveCartCount(newCount);
        }
        return newCount;
      });
    }

    // Optimistically remove card from cardCartItems if it's a card
    if (isCard && setCardCartItems) {
      setCardCartItems((prev) => prev.filter(item => item.id !== data.id && item.card_id !== data.card_id));
    }

    const res = await removeFromCart(data.id, isCard ? 'card' : 'product');
    if (res.status === success) {
      toast.success("Item removed from cart");
      // Trigger cart refresh event to sync with backend
      window.dispatchEvent(new Event('cartUpdated'));
      // Small delay then reload to refresh the cart page properly
      setTimeout(() => {
      window.location.reload();
      }, 500);
    } else {
      // Revert optimistic update on error
      if (setCartCount) {
        setCartCount((prev) => {
          const newCount = prev + 1;
          if (typeof window !== "undefined") {
            saveCartCount(newCount);
          }
          return newCount;
        });
      }
      toast.error(res.message || "Failed to remove item");
    }
    setLoading(false);
  };

  // For products
  if (!isCard) {
  return (
    <tr className="border-b border-border">
      <td className="px-6 py-4">
        <div className="flex items-center gap-4">
          <Image
            src={`${process.env.NEXT_PUBLIC_IMG_URL}/${data?.product?.get_gallery_images?.[0]?.img}`}
            alt={data?.product?.product_title}
            width={64}
            height={64}
            className="object-cover rounded"
          />
          <div>
            <p className="font-medium">{data?.product?.product_title}</p>
            <p className="text-sm text-gray-500">SKU: {data?.sku}</p>
          </div>
        </div>
      </td>
      <td className="px-6 py-4">
          <span className="font-semibold">${parseFloat(data?.price || 0).toFixed(2)}</span>
        </td>
        <td className="px-6 py-4">
          <span className="font-semibold">${(parseFloat(data?.price || 0) * parseInt(data?.quantity || 1)).toFixed(2)}</span>
        </td>
        <td className="px-6 py-4">
          <button
            onClick={handleRemove}
            disabled={loading}
            className="text-red-500 hover:text-red-700 disabled:opacity-50"
          >
            {loading ? "Removing..." : "Remove"}
          </button>
        </td>
      </tr>
    );
  }

  // For cards
  const card = data?.card;
  
  // Debug logging
  if (!card) {
    console.warn("Card data missing:", data);
  }

  const cardImage = card?.images && Array.isArray(card.images) && card.images.length > 0 
    ? card.images[0] 
    : (card?.images && typeof card.images === 'string' ? card.images : null);

  return (
    <tr className="border-b border-border">
      <td className="px-6 py-4">
        <div className="flex items-center gap-4">
          <Image
            src={cardImage ? `${process.env.NEXT_PUBLIC_IMG_URL}/${cardImage}` : '/placeholder-card.png'}
            alt={card?.card_title || 'Card'}
            width={64}
            height={64}
            className="object-cover rounded"
          />
          <div>
            <p className="font-medium">{card?.card_title || 'Card'}</p>
            {card?.grade && <p className="text-sm text-gray-500">Grade: {card.grade}</p>}
          </div>
        </div>
      </td>
      <td className="px-6 py-4">
        <span className="font-semibold">${parseFloat(card?.price || 0).toFixed(2)}</span>
      </td>
      <td className="px-6 py-4">
        <span className="font-semibold">${parseFloat(card?.price || 0).toFixed(2)}</span>
      </td>
      <td className="px-6 py-4">
        <button
          onClick={handleRemove}
          disabled={loading}
          className="text-red-500 hover:text-red-700 disabled:opacity-50"
        >
          {loading ? "Removing..." : "Remove"}
        </button>
      </td>
    </tr>
  );
};

export default CartItem;
