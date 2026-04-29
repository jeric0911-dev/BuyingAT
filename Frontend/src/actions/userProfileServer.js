"use server";

import { cookies } from "next/headers";
import { authKey } from "@/constants";

const API_BASE_URL = process.env.SERVER_API_URL;
console.log("API URL:", API_BASE_URL);

export const getUserProfileServer = async () => {
  try {
    console.log('🔍 getUserProfileServer: Starting server-side profile fetch', {
      timestamp: new Date().toISOString(),
      api_url: `${API_BASE_URL}/user-profile`
    });

    const token = cookies().get(authKey)?.value;
    
    if (!token) {
      console.log('❌ getUserProfileServer: No access token found in cookies');
      return { status: "error", message: "No access token found" };
    }

    console.log('🔑 getUserProfileServer: Token found', {
      token_length: token.length,
      token_preview: token.substring(0, 10) + '...'
    });

    const response = await fetch(`${API_BASE_URL}/user-profile`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      cache: 'no-store'
    });

    console.log('📡 getUserProfileServer: API response received', {
      status: response.status,
      status_text: response.statusText
    });

    const data = await response.json();
    
    console.log('📊 getUserProfileServer: Response data', {
      status: data.status,
      message: data.message,
      has_data: !!data.data
    });

    return data;
  } catch (error) {
    console.error('💥 getUserProfileServer: Error in server-side profile fetch', {
      error: error.message,
      stack: error.stack,
      timestamp: new Date().toISOString()
    });
    return { status: "error", message: "Failed to fetch profile" };
  }
};