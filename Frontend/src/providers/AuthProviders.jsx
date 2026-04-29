"use client";

import { authKey } from "@/constants";
import AuthContext from "@/contexts/AuthContext";
import {getUser, getWishlist, getCart as getCartFromStorage, saveCart, getCartCount, saveCartCount } from "@/utils/localStorage";
import Cookies from "js-cookie";
import { useState, useEffect } from "react";

const AuthProviders = ({ children }) => {
  const token = Cookies.get(authKey);
  const [user, setUser] = useState(getUser());
  const [wishlist, setWishlist] = useState(getWishlist());
  const [cart, setCart] = useState(getCartFromStorage());
  // Initialize cart count to 0 - will be synced from backend immediately
  const [cartCount, setCartCount] = useState(0);
  const [cardCartItems, setCardCartItems] = useState([]); // Store card cart items for validation

  // Sync cart count from backend when user is logged in
  const syncCartCount = async () => {
      // Get current token (may have changed)
      const currentToken = Cookies.get(authKey) || token;
      if (!currentToken) {
        setCartCount(0);
        setCart([]);
        setCardCartItems([]);
        saveCart([]);
        saveCartCount(0); // Clear cart count from localStorage when logged out
        return;
      }

      try {
        const apiBase = (process.env.NEXT_PUBLIC_SERVER_API_URL || process.env.NEXT_PUBLIC_SERVE || "").replace(/\/$/, "");
        if (!apiBase) {
          console.warn('API base URL not configured for cart sync');
          return;
        }

        const currentToken = Cookies.get(authKey) || token;
        const response = await fetch(`${apiBase}/user/get-cart-items`, {
          headers: {
            Authorization: `Bearer ${currentToken}`,
          },
        });

        if (response.ok) {
          const result = await response.json();
          if (result.status === 'success' && result.data) {
            // Count actual items from both products and cards tables
            const productsCount = Array.isArray(result.data.products) ? result.data.products.length : 0;
            const cardsCount = Array.isArray(result.data.cards) ? result.data.cards.length : 0;
            const totalCount = productsCount + cardsCount;
            
            // Use total_count from backend or calculate from arrays
            const backendTotalCount = result.data.total_count ?? totalCount;
            
            setCartCount(backendTotalCount);
            saveCartCount(backendTotalCount); // Persist to localStorage
            
            // Store card cart items for validation
            setCardCartItems(result.data.cards || []);
            
            // Update cart state with item IDs for compatibility
            const productIds = (result.data.products || []).map(item => item.id);
            const cardIds = (result.data.cards || []).map(item => item.card_id); // Use card_id for cards
            const allIds = [...productIds, ...cardIds];
            setCart(allIds);
            saveCart(allIds);
          } else {
            // If no data or error, clear cart count
            setCartCount(0);
            saveCartCount(0);
            setCardCartItems([]);
            setCart([]);
            saveCart([]);
          }
        } else {
          // If API call fails, clear cart count to avoid stale data
          setCartCount(0);
          saveCartCount(0);
          setCardCartItems([]);
        }
      } catch (error) {
        console.error('Error syncing cart count from backend:', error);
        // On error, clear cart count to avoid showing incorrect count
        // Backend is the source of truth, so if we can't reach it, show 0
        setCartCount(0);
        saveCartCount(0);
        setCardCartItems([]);
      }
    };

  useEffect(() => {
    syncCartCount();
    
    // Listen for cart update events
    const handleCartUpdate = () => {
      const currentToken = Cookies.get(authKey);
      if (currentToken) {
        syncCartCount();
      }
    };
    
    window.addEventListener('cartUpdated', handleCartUpdate);
    
    return () => {
      window.removeEventListener('cartUpdated', handleCartUpdate);
    };
  }, [token]);

  const value = {
    token,
    wishlist,
    setWishlist,
    cart,              
    setCart,
    cartCount, // Use cartCount from backend instead of cart.length
    setCartCount, // Expose setter for optimistic updates
    cardCartItems, // Expose card cart items for validation
    setCardCartItems, // Expose setter for optimistic updates
    refreshCartCount: syncCartCount, // Expose function to refresh cart count
    user,
    setUser,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export default AuthProviders;
