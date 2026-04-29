"use server";

import { getToken } from "./auth";
import { revalidateTag } from "next/cache";
const baseUrl = process.env.SERVER_API_URL;

export const getBlogCategories = async () => {
  try {
    const res = await fetch(`${baseUrl}/home/blog-categories`, {
      method: "GET",
      next: { revalidate: 3600 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getBlogs = async (params) => {
  try {
    const res = await fetch(
      `${baseUrl}/home/blogs${params ? `?${params}` : ""}`,
      {
        method: "GET",
        next: { revalidate: 300 },
      }
    );
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getBlogBySlug = async (slug) => {
  try {
    const res = await fetch(`${baseUrl}/home/blogs/${slug}`, {
      method: "GET",
      next: { revalidate: 0 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getBlogByCategoryId = async (id, limit) => {
  try {
    const res = await fetch(
      `${baseUrl}/home/blogs/category/${id}${limit ? `?limit=${limit}` : ""}`,
      {
        method: "GET",
        next: { revalidate: 300 },
      }
    );
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const postComment = async (data) => {
  try {
    const res = await fetch(`${baseUrl}/user/blog-comments`, {
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

export const getCategories = async () => {
  try {
    const res = await fetch(`${baseUrl}/home/categories`, {
      method: "GET",
      next: { revalidate: 300 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getTopCategories = async () => {
  try {
    const res = await fetch(`${baseUrl}/home/top-categories`, {
      method: "GET",
      next: { revalidate: 300 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getSubCategories = async () => {
  try {
    const res = await fetch(`${baseUrl}/home/sub-categories`, {
      method: "GET",
      next: { revalidate: 300 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getBrands = async () => {
  try {
    const res = await fetch(`${baseUrl}/home/brands`, {
      method: "GET",
      next: { revalidate: 300 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getShopWithCategory = async () => {
  try {
    const res = await fetch(`${baseUrl}/home/shop-with-categories`, {
      method: "GET",
      next: { revalidate: 300 },
    });
    return res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getBestDeals = async () => {
  try {
    const res = await fetch(`${baseUrl}/home/best-deals`, {
      method: "GET",
      next: { revalidate: 300 },
    });
    return res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getFeatured = async () => {
  try {
    const res = await fetch(`${baseUrl}/home/featured-products`, {
      method: "GET",
      next: { revalidate: 300 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getCategoryAccessories = async () => {
  try {
    const res = await fetch(`${baseUrl}/home/random-category-products`, {
      method: "GET",
      next: { revalidate: 300 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getTopRated = async () => {
  try {
    const res = await fetch(`${baseUrl}/home/top-rated`, {
      method: "GET",
      next: { revalidate: 300 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getNewArrival = async () => {
  try {
    const res = await fetch(`${baseUrl}/home/new-arrivals`, {
      method: "GET",
      next: { revalidate: 300 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getHeroData = async () => {
  try {
    const res = await fetch(`${baseUrl}/home/hero-section`, {
      method: "GET",
      next: { revalidate: 300 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getFooterData = async () => {
  try {
    const res = await fetch(`${baseUrl}/home/footer-section`, {
      method: "GET",
      next: { revalidate: 300 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getBanner = async () => {
  try {
    const res = await fetch(`${baseUrl}/home/advertise`, {
      method: "GET",
      next: { revalidate: 300 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getBannerSlider = async () => {
  try {
    const res = await fetch(`${baseUrl}/home/sliders`, {
      method: "GET",
      next: { revalidate: 300 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getSocial = async () => {
  try {
    const res = await fetch(`${baseUrl}/home/socials`, {
      method: "GET",
      next: { revalidate: 300 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getShopBySlug = async (slug, params) => {
  try {
    const res = await fetch(
      `${baseUrl}/home/shops/${slug}${params ? `?${params}` : ""}`,
      {
        method: "GET",
        next: { revalidate: 0 },
      }
    );
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getUserBySlug = async (slug, params) => {
  try {
    const res = await fetch(
      `${baseUrl}/home/user-products/${slug}${params ? `?${params}` : ""}`,
      {
        method: "GET",
        next: { revalidate: 0 },
      }
    );
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const createConversion = async (data) => {
  try {
    const res = await fetch(`${baseUrl}/user/conversation-thread`, {
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

// Create buyer profile conversation
export const createBuyerProfileConversation = async (data) => {
  try {
    const conversationData = {
      sender_id: data.sender_id,
      receiver_id: data.receiver_id,
      buyer_profile_id: data.buyer_profile_id,
      conversation_type: 'buyer_profile'
    };
    
    const res = await fetch(`${baseUrl}/user/conversation-thread`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        "Content-type": "application/json",
      },
      body: JSON.stringify(conversationData),
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getAllConversation = async () => {
  try {
    const res = await fetch(`${baseUrl}/user/conversation-threads/get-all`, {
      method: "GET",
      headers: { Authorization: `Bearer ${await getToken()}` },
      next: { revalidate: 0 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getPusherConfig = async () => {
  try {
    const res = await fetch(`${baseUrl}/user/pusher-config`, {
      method: "GET",
      next: { revalidate: 300 },
      headers: { Authorization: `Bearer ${await getToken()}` },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getMessagesById = async (id) => {
  try {
    const res = await fetch(`${baseUrl}/user/get-message/${id}`, {
      method: "GET",
      headers: { Authorization: `Bearer ${await getToken()}` },
      next: { revalidate: 0 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const sentMessage = async (data) => {
  try {
    // Create AbortController for timeout - longer timeout for longer messages
    const controller = new AbortController();
    const messageLength = data.message?.length || 0;
    const timeoutDuration = messageLength > 100 ? 10000 : 5000; // 10s for long messages, 5s for short
    const timeoutId = setTimeout(() => controller.abort(), timeoutDuration);
    
    const res = await fetch(`${baseUrl}/user/message`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        "Content-type": "application/json",
      },
      body: JSON.stringify(data),
      signal: controller.signal, // Add abort signal
    });
    
    clearTimeout(timeoutId);
    return await res.json();
  } catch (error) {
    if (error.name === 'AbortError') {
      console.log(`Message sending timed out after ${timeoutDuration}ms`);
      return { status: 'error', message: 'Request timeout' };
    }
    console.log(error);
    return { status: 'error', message: 'Network error' };
  }
};

export const getPackages = async () => {
  try {
    const res = await fetch(`${baseUrl}/home/packages`, {
      method: "GET",
      next: { revalidate: 0 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getWallet = async () => {
  try {
    const res = await fetch(`${baseUrl}/user/get-wallet`, {
      method: "GET",
      headers: { Authorization: `Bearer ${await getToken()}` },
      next: { revalidate: 0 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getTransactions = async () => {
  try {
    const res = await fetch(`${baseUrl}/user/get-transactions`, {
      method: "GET",
      headers: { Authorization: `Bearer ${await getToken()}` },
      next: { revalidate: 0 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getGateways = async () => {
  try {
    const res = await fetch(`${baseUrl}/user/get-all-from-frontend`, {
      method: "GET",
      headers: { Authorization: `Bearer ${await getToken()}` },
      next: { revalidate: 0 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const sslCommerz = async (body) => {
  try {
    const res = await fetch(`${baseUrl}/user/sslcommerz/pay`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        "Content-type": "application/json",
      },
      body: JSON.stringify(body),
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const razorpayPay = async (body) => {
  try {
    const res = await fetch(`${baseUrl}/user/razorpay/payment`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        "Content-type": "application/json",
      },
      body: JSON.stringify(body),
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const razorpayCallback = async (body) => {
  try {
    const res = await fetch(`${baseUrl}/user/razorpay/pay`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        "Content-type": "application/json",
      },
      body: JSON.stringify(body),
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const paypal = async (body) => {
  try {
    const res = await fetch(`${baseUrl}/user/paypal/initiate-payment`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        "Content-type": "application/json",
      },
      body: JSON.stringify(body),
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const paypalCallback = async (body) => {
  try {
    const res = await fetch(`${baseUrl}/user/paypal/success`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        "Content-type": "application/json",
      },
      body: JSON.stringify(body),
    });
    revalidateTag("user");
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const stripe = async (body) => {
  try {
    const res = await fetch(`${baseUrl}/user/stripe/create-checkout-session`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        "content-type": "application/json",
      },
      body: JSON.stringify(body),
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const purchasePlan = async (body) => {
  try {
    const res = await fetch(`${baseUrl}/user/subscribe`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        "Content-type": "application/json",
      },
      body: JSON.stringify(body),
    });
    revalidateTag("user");
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getSettings = async () => {
  try {
    const res = await fetch(`${baseUrl}/app-setting`, {
      method: "GET",
      next: { revalidate: 300 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const contactUs = async (data) => {
  try {
    const res = await fetch(`${baseUrl}/home/contact-us`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify(data),
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getFaqs = async () => {
  try {
    const res = await fetch(`${baseUrl}/home/faqs`, {
      method: "GET",
      next: { revalidate: 3600 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getPages = async () => {
  try {
    const res = await fetch(`${baseUrl}/home/more-pages`, {
      method: "GET",
      next: { revalidate: 3600 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getSinglePage = async (slug) => {
  try {
    const res = await fetch(`${baseUrl}/home/more-pages/${slug}`, {
      method: "GET",
      next: { revalidate: 300 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getAllShopSlug = async () => {
  try {
    const res = await fetch(`${baseUrl}/home/shops-slugs`, {
      method: "GET",
      next: { revalidate: 0 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};
