"use server";

import { revalidateTag } from "next/cache";
import { getToken } from "./auth";

const baseUrl = process.env.SERVER_API_URL;

export const addProduct = async (data) => {
  try {
    const res = await fetch(`${baseUrl}/user/products`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
      },
      body: data,
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const editProduct = async (id, data) => {
  try {
    const res = await fetch(`${baseUrl}/user/products/${id}`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
      },
      body: data,
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getSingleProduct = async (id) => {
  try {
    const res = await fetch(`${baseUrl}/home/products/${id}`, {
      method: "GET",
      next: { revalidate: 0 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const giveReview = async (data) => {
  try {
    const res = await fetch(`${baseUrl}/user/products/rating`, {
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

export const getWishList = async () => {
  try {
    const token = await getToken();
    if (!token) return { data: [] };
    const res = await fetch(`${baseUrl}/user/product/wishlists`, {
      method: "GET",
      headers: { Authorization: `Bearer ${token}` },
      cache: "force-cache",
      next: { tags: ["wishlist"] },
    });
    return res.json();
  } catch (error) {
    console.log(error);
  }
};

export const addToWishList = async (product_id) => {
  try {
    const res = await fetch(`${baseUrl}/user/product/wishlists`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        "Content-type": "application/json",
      },
      body: JSON.stringify({ product_id }),
    });
    revalidateTag("wishlist");
    return res.json();
  } catch (error) {
    console.log(error);
  }
};

export const delFromWishList = async (id) => {
  try {
    const res = await fetch(`${baseUrl}/user/product/wishlists/${id}`, {
      method: "DELETE",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
      },
    });
    revalidateTag("wishlist");
    return res.json();
  } catch (error) {
    console.log(error);
  }
};

export const filter = async (params) => {
  try {
    const res = await fetch(
      `${baseUrl}/home/products/filter${params ? `?${params}` : ""}`,
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

// Browse active cards for buyers
export const browseActiveCards = async (params) => {
  try {
    const res = await fetch(
      `${baseUrl}/home/cards/filter${params ? `?${params}` : ""}`,
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

// Get single active card
export const getActiveCard = async (id) => {
  try {
    const res = await fetch(`${baseUrl}/home/cards/${id}`, {
      method: "GET",
      next: { revalidate: 0 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};
