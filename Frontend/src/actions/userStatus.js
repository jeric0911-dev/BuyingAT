"use server";

import { getToken } from "./auth";
const baseUrl = process.env.SERVER_API_URL;

export const getUserStatusById = async (userId) => {
  try {
    const token = await getToken();
    
    if (!token) {
      return {
        status: 'error',
        message: 'No authentication token found'
      };
    }
    
    const res = await fetch(`${baseUrl}/user/status/user/${userId}`, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-type": "application/json",
      },
    });
    
    return await res.json();
  } catch (error) {
    console.log('Error in getUserStatusById:', error);
    return {
      status: 'error',
      message: 'Network error',
      error: error.message
    };
  }
};

export const getCurrentUserStatus = async () => {
  try {
    const res = await fetch(`${baseUrl}/user/status`, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        "Content-type": "application/json",
      },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const markUserOnline = async () => {
  try {
    const res = await fetch(`${baseUrl}/user/status/online`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        "Content-type": "application/json",
      },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const markUserOffline = async () => {
  try {
    const res = await fetch(`${baseUrl}/user/status/offline`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        "Content-type": "application/json",
      },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const updateLastSeen = async () => {
  try {
    const res = await fetch(`${baseUrl}/user/status/last-seen`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        "Content-type": "application/json",
      },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getOnlineUsers = async () => {
  try {
    const res = await fetch(`${baseUrl}/user/status/online-users`, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${await getToken()}`,
        "Content-type": "application/json",
      },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};
