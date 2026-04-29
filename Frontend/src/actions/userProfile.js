"use client";

import { success } from "@/constants";

const API_BASE_URL = process.env.SERVER_API_URL;
console.log("API URL:", process.env.SERVER_API_URL);

console.log('🌐 userProfile.------js: API_BASE_URL loaded', {
  API_BASE_URL: API_BASE_URL,
  env_var: process.env.SERVER_API_URL,
  fallback_used: !process.env.SERVER_API_URL
});

/**
 * Get user profile with detailed logging
 */
export const getUserProfile = async () => {
  try {
    console.log('🔍 getUserProfile: Starting profile fetch', {
      timestamp: new Date().toISOString(),
      api_url: `${API_BASE_URL}/user-profile`
    });

    const token = localStorage.getItem('accessToken');
    if (!token) {
      console.warn('❌ getUserProfile: No access token found');
      throw new Error('No access token found');
    }

    console.log('🔑 getUserProfile: Token found', {
      token_length: token.length,
      token_preview: token.substring(0, 10) + '...'
    });

    const response = await fetch(`${API_BASE_URL}/user-profile`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    });

    console.log('📡 getUserProfile: API response received', {
      status: response.status,
      status_text: response.statusText,
      headers: Object.fromEntries(response.headers.entries())
    });

    const data = await response.json();
    
    console.log('📊 getUserProfile: Response data', {
      status: data.status,
      message: data.message,
      has_data: !!data.data,
      data_keys: data.data ? Object.keys(data.data) : null
    });

    if (response.ok) {
      console.log('✅ getUserProfile: Profile fetched successfully', {
        profile_id: data.data?.id,
        username: data.data?.username,
        has_avatar: !!data.data?.avatar,
        has_bio: !!data.data?.bio
      });
      return data;
    } else {
      console.error('❌ getUserProfile: API error response', {
        status: response.status,
        error: data.message,
        errors: data.errors
      });
      throw new Error(data.message || 'Failed to fetch profile');
    }
  } catch (error) {
    console.error('💥 getUserProfile: Error occurred', {
      error: error.message,
      stack: error.stack,
      timestamp: new Date().toISOString()
    });
    throw error;
  }
};

/**
 * Create or update user profile with detailed logging
 */
export const createOrUpdateUserProfile = async (profileData) => {
  try {
    console.log('🔄 createOrUpdateUserProfile: Starting profile operation', {
      timestamp: new Date().toISOString(),
      profile_data: {
        username: profileData.username,
        bio: profileData.bio,
        has_avatar: !!profileData.avatar,
        avatar_name: profileData.avatar?.name,
        avatar_size: profileData.avatar?.size,
        avatar_type: profileData.avatar?.type
      }
    });

    // Get token from localStorage first, then try to get from cookies
    let token = localStorage.getItem('accessToken');
    
    if (!token) {
      // Try to get from cookies using document.cookie
      console.log('🔍 createOrUpdateUserProfile: No token in localStorage, checking cookies...');
      
      // Get token from cookies (using the authKey name)
      const cookies = document.cookie.split(';');
      console.log('🍪 createOrUpdateUserProfile: Available cookies', {
        all_cookies: document.cookie,
        cookie_list: cookies.map(c => c.trim())
      });
      const tokenCookie = cookies.find(cookie => cookie.trim().startsWith('accessToken='));
      
      if (tokenCookie) {
        token = decodeURIComponent(tokenCookie.split('=')[1]);
        console.log('🔑 createOrUpdateUserProfile: Token found in cookies', {
          token_length: token.length,
          token_preview: token.substring(0, 10) + '...',
          raw_token: tokenCookie.split('=')[1],
          decoded_token: token
        });
      } else {
        console.log('⚠️ createOrUpdateUserProfile: No token found in cookies either');
        console.log('⚠️ createOrUpdateUserProfile: Proceeding without explicit token (using session auth)');
      }
    } else {
      console.log('🔑 createOrUpdateUserProfile: Token found in localStorage', {
        token_length: token.length,
        token_preview: token.substring(0, 10) + '...'
      });
    }

    // Create FormData for file upload
    const formData = new FormData();
    formData.append('username', profileData.username);
    formData.append('bio', profileData.bio || '');
    
    if (profileData.avatar) {
      console.log('📸 createOrUpdateUserProfile: Adding avatar to FormData', {
        file_name: profileData.avatar.name,
        file_size: profileData.avatar.size,
        file_type: profileData.avatar.type
      });
      formData.append('avatar', profileData.avatar);
    }

    console.log('📤 createOrUpdateUserProfile: Sending request to API', {
      api_url: `${API_BASE_URL}/user-profile`,
      form_data_keys: Array.from(formData.keys()),
      form_data_entries: Array.from(formData.entries()).map(([key, value]) => ({
        key,
        value_type: typeof value,
        value_preview: value instanceof File ? `${value.name} (${value.size} bytes)` : value
      }))
    });

    // Prepare headers with token if available
    const headers = {
      'Accept': 'application/json'
      // Note: Don't set Content-Type for FormData, let browser set it with boundary
    };
    
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    const response = await fetch(`${API_BASE_URL}/user-profile`, {
      method: 'POST',
      headers: headers,
      body: formData
    });

    console.log('🔍 createOrUpdateUserProfile: Response', response);

    console.log('📡 createOrUpdateUserProfile: API response received', {
      status: response.status,
      status_text: response.statusText,
      headers: Object.fromEntries(response.headers.entries())
    });

    const data = await response.json();
    
    console.log('📊 createOrUpdateUserProfile: Response data', {
      status: data.status,
      message: data.message,
      has_data: !!data.data,
      data_keys: data.data ? Object.keys(data.data) : null
    });

    if (response.ok) {
      console.log('✅ createOrUpdateUserProfile: Profile operation successful', {
        profile_id: data.data?.id,
        username: data.data?.username,
        has_avatar: !!data.data?.avatar,
        avatar_path: data.data?.avatar,
        operation: data.message
      });
      return data;
    } else {
      console.error('❌ createOrUpdateUserProfile: API error response', {
        status: response.status,
        error: data.message,
        errors: data.errors,
        validation_errors: data.errors
      });
      throw new Error(data.message || 'Failed to process profile');
    }
  } catch (error) {
    console.error('💥 createOrUpdateUserProfile: Error occurred', {
      error: error.message,
      stack: error.stack,
      timestamp: new Date().toISOString()
    });
    throw error;
  }
};

/**
 * Delete user profile with detailed logging
 */
export const deleteUserProfile = async () => {
  try {
    console.log('🗑️ deleteUserProfile: Starting profile deletion', {
      timestamp: new Date().toISOString(),
      api_url: `${API_BASE_URL}/user-profile`
    });

    const token = localStorage.getItem('accessToken');
    if (!token) {
      console.warn('❌ deleteUserProfile: No access token found');
      throw new Error('No access token found');
    }

    console.log('🔑 deleteUserProfile: Token found', {
      token_length: token.length,
      token_preview: token.substring(0, 10) + '...'
    });

    const response = await fetch(`${API_BASE_URL}/user-profile`, {
      method: 'DELETE',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    });

    console.log('📡 deleteUserProfile: API response received', {
      status: response.status,
      status_text: response.statusText,
      headers: Object.fromEntries(response.headers.entries())
    });

    const data = await response.json();
    
    console.log('📊 deleteUserProfile: Response data', {
      status: data.status,
      message: data.message,
      has_data: !!data.data
    });

    if (response.ok) {
      console.log('✅ deleteUserProfile: Profile deleted successfully', {
        message: data.message
      });
      return data;
    } else {
      console.error('❌ deleteUserProfile: API error response', {
        status: response.status,
        error: data.message,
        errors: data.errors
      });
      throw new Error(data.message || 'Failed to delete profile');
    }
  } catch (error) {
    console.error('💥 deleteUserProfile: Error occurred', {
      error: error.message,
      stack: error.stack,
      timestamp: new Date().toISOString()
    });
    throw error;
  }
};