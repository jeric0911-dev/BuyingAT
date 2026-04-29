"use server";

import { revalidateTag } from "next/cache";
import { getToken } from "./auth";

const baseUrl = process.env.SERVER_API_URL;

export const getMyShop = async () => {
  try {
    const res = await fetch(`${baseUrl}/user/shop-by-vendor`, {
      method: "GET",
      headers: { Authorization: `Bearer ${await getToken()}` },
      next: { revalidate: 0 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getMyShopProducts = async (params) => {
  try {
    const res = await fetch(
      `${baseUrl}/user/products-by-vendor${params ? `?${params}` : ""}`,
      {
        method: "GET",
        headers: { Authorization: `Bearer ${await getToken()}` },
        next: { revalidate: 0, tags: ["myProducts"] },
      }
    );
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const unpublishProduct = async (id) => {
  try {
    const res = await fetch(`${baseUrl}/user/product/unpublish`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${await getToken()}`,
      },
      body: JSON.stringify({ product_id: id }),
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const deleteProduct = async (id) => {
  try {
    const res = await fetch(`${baseUrl}/user/products/${id}`, {
      method: "DELETE",
      headers: { Authorization: `Bearer ${await getToken()}` },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const manageStock = async (data) => {
  try {
    const res = await fetch(`${baseUrl}/user/product-stocks-multiple`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        "Content-type": "application/json",
      },
      body: JSON.stringify(data),
    });
    revalidateTag("myProducts");
    return res.json();
  } catch (error) {
    console.log(error);
  }
};

export const manageStockMain = async (data) => {
  try {
    const res = await fetch(`${baseUrl}/user/product/manage-stocks`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        "Content-type": "application/json",
      },
      body: JSON.stringify(data),
    });
    revalidateTag("myProducts");
    return res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getSupportTickets = async () => {
  try {
    const res = await fetch(`${baseUrl}/user/tickets`, {
      method: "GET",
      headers: { Authorization: `Bearer ${await getToken()}` },
      next: { revalidate: 0 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getTicketDetails = async (slug) => {
  try {
    const res = await fetch(`${baseUrl}/user/ticket-messages/${slug}`, {
      method: "GET",
      headers: { Authorization: `Bearer ${await getToken()}` },
      next: { revalidate: 0, tags: ["ticket"] },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const createTicket = async (data) => {
  try {
    const res = await fetch(`${baseUrl}/user/tickets`, {
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

export const closeTicket = async (slug) => {
  try {
    const res = await fetch(`${baseUrl}/user/close-tickets/${slug}`, {
      method: "GET",
      headers: { Authorization: `Bearer ${await getToken()}` },
    });
    revalidateTag("ticket");
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const replayTicket = async (data) => {
  try {
    const res = await fetch(`${baseUrl}/user/ticket-messages`, {
      method: "POST",
      headers: { Authorization: `Bearer ${await getToken()}` },
      body: data,
    });
    revalidateTag("ticket");
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const boostProduct = async (data) => {
  try {
    const res = await fetch(`${baseUrl}/user/features`, {
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

export const reportProduct = async (data) => {
  try {
    const res = await fetch(`${baseUrl}/user/reports`, {
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
