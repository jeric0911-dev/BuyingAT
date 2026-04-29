export const getUser = () => {
  if (typeof window !== "undefined") {
    const stored = localStorage.getItem("user");
    return stored ? JSON.parse(stored) : {};
  }
  return {};
};

export const saveUser = (user) => {
  if (typeof window !== "undefined") {
    localStorage.setItem("user", JSON.stringify(user));
  }
};

export const getWishlist = () => {
  if (typeof window !== "undefined") {
    const stored = localStorage.getItem("wishlist");
    return stored ? JSON.parse(stored) : [];
  }
  return [];
};

export const saveWishlist = (wishlist) => {
  if (typeof window !== "undefined") {
    localStorage.setItem("wishlist", JSON.stringify(wishlist));
  }
};

export const toggleWishlistItem = (productId) => {
  if (typeof window === "undefined") return [];

  const wishlist = getWishlist();
  const updated = wishlist.includes(productId)
    ? wishlist.filter((id) => id !== productId)
    : [...wishlist, productId];

  localStorage.setItem("wishlist", JSON.stringify(updated));
  return updated;
};

export const getCart = () => {
  if (typeof window !== "undefined") {
    const stored = localStorage.getItem("cart");
    if (!stored || stored === "undefined" || stored === "null") return [];
    try {
      return JSON.parse(stored);
    } catch (error) {
      console.error("Error parsing cart from localStorage:", error);
      return [];
    }
  }
  return [];
};

export const saveCart = (cart) => {
  if (typeof window !== "undefined") {
    localStorage.setItem("cart", JSON.stringify(cart));
  }
};

export const toggleCartItem = (productId) => {
  if (typeof window === "undefined") return [];

  const cart = getCart();
  if (cart.includes(productId)) return cart;

  const updated = [...cart, productId];
  localStorage.setItem("cart", JSON.stringify(updated));
  return updated;
};

export const getCartCount = () => {
  if (typeof window !== "undefined") {
    const stored = localStorage.getItem("cartCount");
    if (!stored || stored === "undefined" || stored === "null") return 0;
    try {
      return parseInt(stored, 10) || 0;
    } catch (error) {
      console.error("Error parsing cart count from localStorage:", error);
      return 0;
    }
  }
  return 0;
};

export const saveCartCount = (count) => {
  if (typeof window !== "undefined") {
    localStorage.setItem("cartCount", JSON.stringify(count));
  }
};
