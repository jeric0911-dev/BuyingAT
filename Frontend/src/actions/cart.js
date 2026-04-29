"use server";

import { getToken } from "./auth";

const baseUrl = process.env.SERVER_API_URL;

export const getCart = async () => {
  try {
    const token = await getToken();
    console.log("Cart token check:", token ? "Token exists" : "No token");
    
    if (!token) {
      console.error("No token found");
      // Return empty cart structure instead of error for better UX
      return { 
        status: "success", 
        message: "Cart is empty", 
        data: { products: [], cards: [], items: [], total_count: 0 } 
      };
    }

    if (!baseUrl) {
      console.error("API base URL not configured");
      return { 
        status: "success", 
        message: "Cart is empty", 
        data: { products: [], cards: [], items: [], total_count: 0 } 
      };
    }

    console.log("Fetching cart from:", `${baseUrl}/user/get-cart-items`);
    
    const res = await fetch(`${baseUrl}/user/get-cart-items`, {
      method: "GET",
      headers: { 
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      next: { revalidate: 0 },
    });

    console.log("Cart API response status:", res.status, res.statusText);

    if (!res.ok) {
      // Try to get error message from response
      let errorMessage = "Failed to fetch cart";
      let errorData = null;
      try {
        const text = await res.text();
        console.log("Cart API error response:", text);
        if (text) {
          errorData = JSON.parse(text);
          errorMessage = errorData.message || errorData.error || errorMessage;
        }
      } catch (e) {
        // If response is not JSON, use status text
        errorMessage = res.statusText || errorMessage;
      }
      
      console.error("Cart API error:", res.status, res.statusText, errorMessage, errorData);
      
      // Return empty cart structure for 401/403/400 (unauthorized/bad request) instead of error
      if (res.status === 401 || res.status === 403 || res.status === 400) {
        console.warn("Returning empty cart due to auth/validation error");
        return { 
          status: "success", 
          message: "Cart is empty", 
          data: { products: [], cards: [], items: [], total_count: 0 } 
        };
      }
      
      return { status: "error", message: errorMessage, data: null };
    }

    const result = await res.json();
    console.log("Cart API response:", result);
    return result;
  } catch (error) {
    console.error("Error in getCart:", error);
    // Return empty cart on error instead of crashing
    return { 
      status: "success", 
      message: "Cart is empty", 
      data: { products: [], cards: [], items: [], total_count: 0 } 
    };
  }
};

export const getCartDetails = async () => {
  try {
    const res = await fetch(`${baseUrl}/user/cart-details`, {
      method: "GET",
      headers: { Authorization: `Bearer ${await getToken()}` },
      next: { revalidate: 0 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const addToCart = async (data) => {
  try {
    const res = await fetch(`${baseUrl}/user/add-to-cart`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        "Content-type": "application/json",
      },
      body: JSON.stringify(data),
    });
    
    const result = await res.json();
    
    // If the response status is not ok, return error
    if (!res.ok) {
      return {
        status: 'error',
        message: result.message || 'Failed to add item to cart',
        error: result.error || result.message
      };
    }
    
    return result;
  } catch (error) {
    console.error('Error in addToCart:', error);
    return {
      status: 'error',
      message: 'Network error: Failed to add item to cart',
      error: error.message
    };
  }
};

export const updateCart = async (id, data) => {
  try {
    const res = await fetch(`${baseUrl}/user/cart/${id}`, {
      method: "PUT",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        "Content-type": "application/json",
      },
      body: JSON.stringify(data),
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const removeFromCart = async (id, itemType = 'product') => {
  try {
    const res = await fetch(`${baseUrl}/user/remove-cart-item`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        "Content-type": "application/json",
      },
      body: JSON.stringify({ 
        cart_item_id: id,
        item_type: itemType 
      }),
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getMyOrders = async (page = 1) => {
  try {
    console.log('Fetching orders for page:', page);
    const res = await fetch(`${baseUrl}/user/user-order-list?page=${page}`, {
      method: "GET",
      headers: { Authorization: `Bearer ${await getToken()}` },
      next: { revalidate: 0 },
    });
    const data = await res.json();
    console.log('Orders API response:', data);
    return data;
  } catch (error) {
    console.log('Error fetching orders:', error);
  }
};

export const getMyOrderStats = async () => {
  try {
    const res = await fetch(`${baseUrl}/user/user-order-data`, {
      method: "GET",
      headers: { Authorization: `Bearer ${await getToken()}` },
      next: { revalidate: 0 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getOrderDetails = async (orderId) => {
  try {
    console.log('Fetching order details for ID:', orderId);
    const res = await fetch(`${baseUrl}/user/order-details/${orderId}`, {
      method: "GET",
      headers: { Authorization: `Bearer ${await getToken()}` },
      next: { revalidate: 0 },
    });
    const data = await res.json();
    console.log('Order details API response:', data);
    return data;
  } catch (error) {
    console.log('Error fetching order details:', error);
  }
};

export const getCustomerOrders = async (page = 1) => {
  try {
    console.log('Fetching customer orders for page:', page);
    const res = await fetch(`${baseUrl}/user/vendor-or-user-order-list?page=${page}`, {
      method: "GET",
      headers: { Authorization: `Bearer ${await getToken()}` },
      next: { revalidate: 0 },
    });
    const data = await res.json();
    console.log('Customer orders API response:', data);
    return data;
  } catch (error) {
    console.log('Error fetching customer orders:', error);
  }
};

// Update order status (vendor/admin only per backend rules)
export const updateOrderStatus = async (orderId, body) => {
  try {
    const token = await getToken();
    const res = await fetch(`${baseUrl}/user/update-order-status/${orderId}`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-type": "application/json",
      },
      body: JSON.stringify(body),
      next: { revalidate: 0 },
    });

    const result = await res.json();
    if (!res.ok) {
      return { status: "error", message: result?.message || "Failed to update status", data: null };
    }
    return result;
  } catch (error) {
    return { status: "error", message: error?.message || "Network error", data: null };
  }
};

export const payOrderWithWallet = async (orderId) => {
  try {
    const res = await fetch(`${baseUrl}/user/order/${orderId}/pay-with-wallet`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        "Content-type": "application/json",
      },
      next: { revalidate: 0 },
    });
    const result = await res.json();
    if (!res.ok) return { status: 'error', message: result?.message || 'Payment failed' };
    return result;
  } catch (e) {
    return { status: 'error', message: e?.message || 'Network error' };
  }
};

export const buyNow = async (data) => {
  try {
    const res = await fetch(`${baseUrl}/user/buy-now`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        "Content-type": "application/json",
      },
      body: JSON.stringify(data),
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const checkout = async (data) => {
  try {
    const token = await getToken();
    if (!token) {
      return { status: "error", message: "Not authenticated", data: null };
    }

    if (!baseUrl) {
      return { status: "error", message: "API URL not configured", data: null };
    }

    // Add timeout to prevent hanging
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 30000); // 30 second timeout

    try {
      const res = await fetch(`${baseUrl}/user/checkout`, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-type": "application/json",
        },
        body: JSON.stringify(data),
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (!res.ok) {
        const errorData = await res.json().catch(() => ({ message: "Failed to place order" }));
        console.error("Checkout API error:", res.status, errorData);
        return { status: "error", message: errorData.message || "Failed to place order", data: null };
      }

      const result = await res.json();
      console.log("Checkout API response:", result);
      return result;
    } catch (fetchError) {
      clearTimeout(timeoutId);
      if (fetchError.name === 'AbortError') {
        console.error("Checkout request timed out");
        return { status: "error", message: "Request timed out. Please check your internet connection and try again.", data: null };
      }
      throw fetchError;
    }
  } catch (error) {
    console.error("Error in checkout:", error);
    return { status: "error", message: error.message || "Failed to place order", data: null };
  }
};
