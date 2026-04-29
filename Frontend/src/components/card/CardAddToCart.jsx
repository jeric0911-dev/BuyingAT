"use client";

import { addToCart } from "@/actions/cart";
import { success } from "@/constants";
import Image from "next/image";
import { useEffect, useState } from "react";
// import {
//   FacebookShareButton,
//   FacebookIcon,
//   TwitterShareButton,
//   TwitterIcon,
//   PinterestShareButton,
//   PinterestIcon,
// } from "react-share";
import { toast } from "sonner";
import { FiShoppingCart } from "react-icons/fi";
import { createConversion } from "@/actions/others";
import { getUser } from "@/actions/auth";
import ReportButton from "../product/ReportButton";
import useAuth from "@/hooks/useAuth";
import { toggleCartItem, toggleWishlistItem, saveUser } from "@/utils/localStorage";
import { useTransitionRouter } from "next-view-transitions";

const CardAddToCart = ({ data }) => {
  const { wishlist, user, token, setWishlist, setCart, setUser, cardCartItems, refreshCartCount, setCartCount, setCardCartItems } = useAuth();
  const [currentUrl, setCurrentUrl] = useState("");
  const router = useTransitionRouter();
  const [cartAnimation, setCartAnimation] = useState(false);
  const [loading, setLoading] = useState(false);

  const is_saved = wishlist?.find((item) => item === data?.id);
  
  // Check if card is already in cart
  const cardId = data?.card_id || data?.seller_inventory?.id || data?.id;
  const isCardInCart = cardCartItems?.some(item => item.card_id === cardId);

  useEffect(() => {
    if (typeof window !== "undefined") {
      setCurrentUrl(window.location.href);
    }
  }, []);

  const handleFav = async () => {
    if (!token)
      return toast.warning("Please log in to add this to your wishlist");

    // For now, just use localStorage since we don't have card wishlist API yet
    toggleWishlistItem(data?.id);
    setWishlist((prev) =>
      is_saved ? prev.filter((item) => item !== data?.id) : [data?.id, ...prev]
    );
    
    toast.success(is_saved ? "Removed from wishlist" : "Added to wishlist");
  };

  const handleAddToCart = async () => {
    if (!token) return toast.warning("Please log in");
    if (!data?.seller?.id) return toast.error("Seller information is missing");
    if (!data?.card_id && !data?.seller_inventory?.id) {
      return toast.error("Card information is missing");
    }

    // Check if card is already in cart
    if (isCardInCart) {
      return toast.error("This card is already in your cart");
    }

    const toastId = toast.loading("Adding to cart...");

    setCartAnimation(true);
    const res = await addToCart({
      product_id: cardId, // Use card_id (seller_inventory ID) for cards
      quantity: 1, // Fixed quantity of 1 for cards
      vendor_id: data?.seller?.id, // Seller ID is required by backend
      is_card: true, // Flag to indicate this is a card (backend might need this)
    });
    setCartAnimation(false);

    if (res.status === success) {
      toggleCartItem(cardId);
      setCart((prev) =>
        prev.includes(cardId) ? prev : [cardId, ...prev]
      );
      
      // Optimistically update cart count and cardCartItems immediately for real-time feedback
      if (setCartCount) {
        setCartCount((prev) => {
          const newCount = prev + 1;
          // Save to localStorage for persistence on reload
          if (typeof window !== "undefined") {
            localStorage.setItem("cartCount", JSON.stringify(newCount));
          }
          return newCount;
        });
      }
      
      // Optimistically add card to cardCartItems to disable button immediately
      if (setCardCartItems) {
        setCardCartItems((prev) => [
          ...prev,
          { card_id: cardId, id: Date.now() } // Temporary ID until backend sync
        ]);
      }
      
      // Trigger cart refresh event to sync with backend
      window.dispatchEvent(new Event('cartUpdated'));
      
      // Also trigger backend sync for accuracy (non-blocking)
      if (refreshCartCount) {
        refreshCartCount().catch(console.error);
      }
      
      toast.success("Item added to cart", { id: toastId });
    } else {
      toast.error(res.message || "Something went wrong", { id: toastId });
    }
  };
  const handleBuyNow = () => {
    if (!token) return toast.warning("Please log in");

    const query = new URLSearchParams({
      product_id: data?.id, // Use CardRequest ID, not card_id
      quantity: 1, // Fixed quantity of 1
    }).toString();

    router.push(`/shopping-cart/checkout?${query}`);
  };

  const handleMessage = async () => {
    // Check authentication first
    if (!token) {
      toast.error("You must login before messaging");
      return;
    }

    // Debug: Check authentication state
    console.log('Authentication check:', {
      token: !!token,
      user: user,
      user_id: user?.id,
      user_type: typeof user,
      user_keys: user ? Object.keys(user) : 'no user object'
    });

    // Get current user data (either from state or refresh from server)
    let currentUser = user;
    
    if (!currentUser || !currentUser.id) {
      // Try to refresh user data from server
      console.log('User data missing, attempting to refresh from server...');
      try {
        const userResponse = await getUser();
        if (userResponse?.data?.id) {
          // Update local storage and state
          saveUser(userResponse.data);
          setUser(userResponse.data);
          console.log('User data refreshed successfully:', userResponse.data);
          
          // Use the refreshed user data
          currentUser = userResponse.data;
        } else {
          toast.error("User information is not available. Please log in again.");
          console.error('Failed to refresh user data:', userResponse);
          return;
        }
      } catch (error) {
        toast.error("User information is not available. Please log in again.");
        console.error('Error refreshing user data:', error);
        return;
      }
    }
    
    // Don't allow contacting yourself
    if (currentUser?.id === data?.seller?.id) {
      toast.error("You cannot contact yourself");
      return;
    }

    // Debug: Check if required data is available
    console.log('Message data check:', {
      user_id: currentUser?.id,
      seller_id: data?.seller?.id,
      card_id: data?.id,
      data_structure: data
    });

    // Validate required data
    if (!data?.seller?.id) {
      toast.error("Seller information is missing. Please refresh the page and try again.");
      return;
    }

    if (!data?.id) {
      toast.error("Card ID is missing. Please refresh the page and try again.");
      return;
    }

    const toastId = toast.loading("Loading...");
    setLoading(true);
    
    try {
      // Final check before API call
      console.log('Final API call data:', {
        sender_id: currentUser?.id,
        receiver_id: data?.seller?.id,
        product_id: data?.id,
        conversation_type: 'product',
        user_object: currentUser
      });

      // Double-check that we have the required data
      if (!currentUser?.id) {
        toast.error("User ID is still missing after refresh. Please log out and log in again.");
        setLoading(false);
        return;
      }

      const res = await createConversion({
        sender_id: currentUser?.id,
        receiver_id: data?.seller?.id,
        product_id: data?.id, // Use CardRequest ID
        conversation_type: 'product'
      });
      
      setLoading(false);
      
      if (res.status === success) {
        toast.success("Starting conversation...", { id: toastId });
        router.push(`/chat/${res?.data?.id}`);
      } else {
        // Show specific validation errors if available
        if (res.errors) {
          const errorMessages = Object.values(res.errors).flat();
          toast.error(errorMessages.join(', '), { id: toastId });
        } else {
          toast.error(res.message || "Failed to start conversation", { id: toastId });
        }
        console.error("Conversation creation failed:", res);
      }
    } catch (error) {
      setLoading(false);
      console.error('Contact error:', error);
      toast.error("Something went wrong!", { id: toastId });
    }
  };

  return (
    <>
      <div className="w-full md:w-auto">
        <p className="text-xs text-red-600 mt-2"></p>
      </div>
      <div className="flex flex-col md:flex-row md:items-center flex-wrap gap-4 mt-8">
        <div className="flex items-center gap-4">
          <button
            onClick={handleMessage}
            className="bg-skyBlue rounded flex justify-center items-center px-4 h-14 flex-1 disabled:cursor-not-allowed"
            disabled={loading || user?.id == data?.seller?.id}
          >
            <Image src="/icon/chat.svg" alt="chat" width={24} height={24} />
          </button>
          <ReportButton data={data} />
        </div>

        <button
          onClick={handleAddToCart}
          type="button"
          aria-label="add to cart"
          disabled={cartAnimation || isCardInCart}
          style={{ "--hover-bg": `black`, "--hover-txt": "white" }}
          className={`btn-hover-effect px-6 h-14 rounded-[3px] text-white flex items-center justify-center gap-3 flex-grow w-full md:w-auto ${
            isCardInCart 
              ? "bg-gray-400 cursor-not-allowed" 
              : "bg-skyBlue"
          }`}
        >
          <span>{isCardInCart ? "ALREADY IN CART" : "ADD TO CART"}</span>
          <FiShoppingCart
            className={`text-xl ${cartAnimation ? "cart-animate" : ""}`}
          />
        </button>

        <button
          onClick={handleBuyNow}
          type="button"
          aria-label="buy now"
          className="border border-skyBlue px-8 h-14 font-bold text-skyBlue rounded-[3px] w-full md:w-auto transition-transform duration-200 hover:scale-110 active:scale-95 cursor-pointer"
        >
          BUY NOW
        </button>
      </div>

      <div className="mt-6 flex justify-between items-center">
        <button
          onClick={handleFav}
          className="flex items-center gap-[6px] disabled:cursor-not-allowed disabled:bg-transparent"
          disabled={data?.seller?.id == user?.id}
        >
          <Image
            src={`/icon/${is_saved ? "heart-red.svg" : "heart-gray.svg"}`}
            alt="#"
            width={24}
            height={24}
          />
          <span className="text-tGray text-sm">Add to Wishlist</span>
        </button>
        {/* <div className="flex items-center gap-3">
          <span className="text-sm text-tGray">Share product:</span>
          <FacebookShareButton url={currentUrl} aria-label="Share on Facebook">
            <FacebookIcon size={18} className="rounded-full" />
          </FacebookShareButton>
          <TwitterShareButton url={currentUrl} aria-label="Share on Twitter">
            <TwitterIcon size={18} className="rounded-full" />
          </TwitterShareButton>
          <PinterestShareButton
            url={currentUrl}
            media={`${currentUrl}/exampleImage`}
            aria-label="Share on Pinterest"
          >
            <PinterestIcon size={18} className="rounded-full" />
          </PinterestShareButton>
        </div> */}
      </div>
    </>
  );
};

export default CardAddToCart;
