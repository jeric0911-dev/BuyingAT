"use server";

import { getToken } from "./auth";

const baseUrl = process.env.SERVER_API_URL;

export const createSellerInventory = async (data) => {
  try {
    // Check if data is FormData (for file uploads) or JSON
    const isFormData = data instanceof FormData;
    
    const headers = { 
      Authorization: `Bearer ${await getToken()}`
    };
    
    let body;
    if (isFormData) {
      // Don't set Content-Type for FormData, let browser set it with boundary
      body = data;
    } else {
      // Set Content-Type for JSON
      headers["Content-Type"] = "application/json";
      body = JSON.stringify(data);
    }
    
    const res = await fetch(`${baseUrl}/seller-inventory`, {
      method: "POST",
      headers,
      body
    });
    return await res.json();
  } catch (error) {
    console.log(error);
    return {
      status: 'error',
      message: 'Failed to create inventory item'
    };
  }
};

export const getMySellerInventory = async (params = "") => {
  try {
    const res = await fetch(`${baseUrl}/seller-inventory${params ? `?${params}` : ""}`, {
      method: "GET",
      headers: { 
        Authorization: `Bearer ${await getToken()}`,
        "Content-Type": "application/json"
      },
      next: { revalidate: 0, tags: ["sellerInventory"] },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
    return {
      status: 'error',
      message: 'Failed to fetch seller inventory',
      data: []
    };
  }
};

export const getSellerInventoryById = async (id) => {
  try {
    const res = await fetch(`${baseUrl}/seller-inventory/${id}`, {
      method: "GET",
      headers: { 
        Authorization: `Bearer ${await getToken()}`,
        "Content-Type": "application/json"
      },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
    return {
      status: 'error',
      message: 'Failed to fetch inventory item'
    };
  }
};

export const updateSellerInventory = async (id, data) => {
  try {
    // Check if data is FormData (for file uploads) or JSON
    const isFormData = data instanceof FormData;
    
    const headers = { 
      Authorization: `Bearer ${await getToken()}`
    };
    
    let body;
    if (isFormData) {
      // Don't set Content-Type for FormData, let browser set it with boundary
      body = data;
    } else {
      // Set Content-Type for JSON
      headers["Content-Type"] = "application/json";
      body = JSON.stringify(data);
    }
    
    const res = await fetch(`${baseUrl}/seller-inventory/${id}`, {
      method: isFormData ? "POST" : "PUT", // Use POST for FormData with method override
      headers,
      body
    });
    return await res.json();
  } catch (error) {
    console.log(error);
    return {
      status: 'error',
      message: 'Failed to update inventory item'
    };
  }
};

export const deleteSellerInventory = async (id) => {
  try {
    const res = await fetch(`${baseUrl}/seller-inventory/${id}`, {
      method: "DELETE",
      headers: { 
        Authorization: `Bearer ${await getToken()}`,
        "Content-Type": "application/json"
      },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
    return {
      status: 'error',
      message: 'Failed to delete inventory item'
    };
  }
};