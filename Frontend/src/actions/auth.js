"use server";

import { authKey, success } from "@/constants";
import { revalidateTag } from "next/cache";
import { cookies } from "next/headers";
import { getWishList } from "./product";
import { getCart } from "./cart";
const baseUrl = process.env.SERVER_API_URL;
console.log('🔍Auth baseUrl', baseUrl);
export const createUser = async (data) => {
  console.log('🔍 createUser: data', data);
  try {
    const res = await fetch(`${baseUrl}/home/signup`, {
      method: "POST",
      headers: { "Content-type": "application/json" },
      body: JSON.stringify(data),
    });
    const result = await res.json();
    console.log('🔍 createUser: result', result);
    if (result.status === success) {
      cookies().set(authKey, result?.data?.token, {
        secure: process.env.NODE_ENV === "production",
      });
      const { user, wishlist, cart } = await getUserCartWishlist();
      return { status: "success", user, wishlist, cart };
    } else {
      return result;
    }
  } catch (error) {
    console.log(error);
  }
};

export const loginUser = async (credentials) => {
  try {
    const res = await fetch(`${baseUrl}/home/login`, {
      method: "POST",
      headers: { "Content-type": "application/json" },
      body: JSON.stringify(credentials),
    });
    const data = await res.json();
    if (data.status === success) {
      cookies().set(authKey, data?.data?.token, {
        secure: process.env.NODE_ENV === "production",
      });
      const { user, wishlist, cart } = await getUserCartWishlist();
      return { status: "success", user, wishlist, cart };
    } else {
      return data;
    }
  } catch (error) {
    console.log(error);
  }
};

export const googleAuthLogin = async (body) => {
  try {
    const res = await fetch(`${baseUrl}/google-login/create-user`, {
      method: "POST",
      headers: { "Content-type": "application/json" },
      body: JSON.stringify(body),
    });
    const data = await res.json();
    if (data.status === success) {
      cookies().set(authKey, data?.data?.token, {
        secure: process.env.NODE_ENV === "production",
      });
      const { user, wishlist, cart } = await getUserCartWishlist();
      return { status: "success", user, wishlist, cart };
    } else {
      return data;
    }
  } catch (error) {
    console.log(error);
  }
};

export const getToken = async () => {
  return cookies().get(authKey)?.value;
};

export const getUser = async () => {
  try {
    const token = await getToken();
    if (!token) return { data: {} };
    const res = await fetch(`${baseUrl}/user/get_me`, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
      },
      next: { revalidate: 0, tags: ["user"] }, // Disable caching temporarily to test role
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const updateUser = async (data) => {
  try {
    const res = await fetch(`${baseUrl}/user/update_me`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
      },
      body: data,
    });
    revalidateTag("user");
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const changePassword = async (data) => {
  try {
    const res = await fetch(`${baseUrl}/user/change_password`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        "Content-type": "application/json",
      },
      body: JSON.stringify(data),
    });
    revalidateTag("user");
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const logoutUser = async () => {
  try {
    const res = await fetch(`${baseUrl}/user/logout`, {
      method: "GET",
      headers: { Authorization: `Bearer ${await getToken()}` },
    });
    const data = await res.json();
    if (data.status === success) {
      cookies().delete(authKey);
    }
    return data;
  } catch (error) {
    console.log(error);
  }
};

export const sendEmail = async (data) => {
  try {
    const res = await fetch(`${baseUrl}/home/send-reset-otp`, {
      method: "POST",
      headers: { "Content-type": "application/json" },
      body: JSON.stringify(data),
    });
    return await res.json();
  } catch (error) {}
};

export const otpVerification = async (data) => {
  try {
    const res = await fetch(`${baseUrl}/home/verify-otp`, {
      method: "POST",
      headers: { "Content-type": "application/json" },
      body: JSON.stringify(data),
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const resetPassword = async (data) => {
  try {
    const res = await fetch(`${baseUrl}/home/reset-password`, {
      method: "POST",
      headers: { "Content-type": "application/json" },
      body: JSON.stringify(data),
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const createShop = async (data) => {
  try {
    const res = await fetch(`${baseUrl}/user/shops`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
      },
      body: data,
    });
    revalidateTag("user");
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const updateShop = async (data) => {
  try {
    const res = await fetch(`${baseUrl}/user/shops/update`, {
      method: "POST",
      headers: { Authorization: `Bearer ${await getToken()}` },
      body: data,
    });
    revalidateTag("user");
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getUserBillingAddress = async () => {
  try {
    const res = await fetch(`${baseUrl}/user/billing-address`, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        next: { revalidate: 3600, tags: ["billing"] },
      },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const updateUserBillingAddress = async (data) => {
  try {
    const res = await fetch(`${baseUrl}/user/billing-address`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        "Content-type": "application/json",
      },
      body: JSON.stringify(data),
    });
    revalidateTag("billing");
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getUserShippingAddress = async () => {
  try {
    const res = await fetch(`${baseUrl}/user/shipping-address`, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        next: { revalidate: 3600, tags: ["shipping"] },
      },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const updateUserShippingAddress = async (data) => {
  try {
    const res = await fetch(`${baseUrl}/user/shipping-address`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        "Content-type": "application/json",
      },
      body: JSON.stringify(data),
    });
    revalidateTag("shipping");
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

const getUserCartWishlist = async () => {
  const [user, cart, wishlist] = await Promise.all([
    getUser()
      .then((res) => res?.data)
      .catch(() => ({})),
    getCart()
      .then((res) => res?.data)
      .catch(() => []),
    getWishList()
      .then((res) => res?.data)
      .catch(() => []),
  ]);

  return { user, cart, wishlist };
};
