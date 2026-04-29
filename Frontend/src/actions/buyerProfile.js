"use server";

export async function createOrUpdateBuyerProfile(formData) {
  console.log("🎯 createOrUpdateBuyerProfile action called with:", formData);
  console.log("API URL:", process.env.SERVER_API_URL);
  
  try {
    // Get the API URL from environment variable
    const apiUrl = process.env.SERVER_API_URL;
    
    // Get the token from cookies
    const { cookies } = await import("next/headers");
    const cookieStore = cookies();
    const token = cookieStore.get("accessToken")?.value;
    
    if (!token) {
      return {
        status: "error",
        message: "Authentication token not found"
      };
    }

    // Decode the token if it's URL encoded
    const decodedToken = decodeURIComponent(token);

    // Prepare the request data
    const requestData = {
      categories: formData.categories || [],
      preferences: formData.preferences || "",
      budget_min: formData.budget_min ? parseFloat(formData.budget_min) : null,
      budget_max: formData.budget_max ? parseFloat(formData.budget_max) : null,
      profile_link: formData.profile_link || "",
      tags: formData.tags || []
    };

    console.log("Creating buyer profile with data:", requestData);
    console.log("Tags data:", requestData.tags);
    console.log("Tags count:", requestData.tags?.length || 0);
    console.log("Tags detailed:", JSON.stringify(requestData.tags, null, 2));

    // Make the API request
    const response = await fetch(`${apiUrl}/buyer-profile`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${decodedToken}`,
        "Accept": "application/json"
      },
      body: JSON.stringify(requestData)
    });

    const result = await response.json();
    
    console.log("Buyer profile creation response:", result);

    if (!response.ok) {
      return {
        status: "error",
        message: result.message || "Failed to create buyer profile",
        errors: result.errors || {}
      };
    }

    return {
      status: "success",
      message: result.message || "Buyer profile created successfully",
      data: result.data
    };

  } catch (error) {
    console.error("Error creating buyer profile:", error);
    return {
      status: "error",
      message: "An error occurred while creating the buyer profile"
    };
  }
}

export async function getBuyerProfile() {
  try {
    // Get the API URL from environment variable
    const apiUrl = process.env.SERVER_API_URL;
    
    // Get the token from cookies
    const { cookies } = await import("next/headers");
    const cookieStore = cookies();
    const token = cookieStore.get("accessToken")?.value;
    
    if (!token) {
      return {
        status: "error",
        message: "Authentication token not found"
      };
    }

    // Decode the token if it's URL encoded
    const decodedToken = decodeURIComponent(token);

    // Make the API request
    const response = await fetch(`${apiUrl}/buyer-profile`, {
      method: "GET",
      headers: {
        "Authorization": `Bearer ${decodedToken}`,
        "Accept": "application/json"
      }
    });

    const result = await response.json();
    
    if (!response.ok) {
      if (response.status === 404) {
        return {
          status: "not_found",
          message: "Buyer profile not found"
        };
      }
      return {
        status: "error",
        message: result.message || "Failed to fetch buyer profile"
      };
    }

    return {
      status: "success",
      data: result.data
    };

  } catch (error) {
    console.error("Error fetching buyer profile:", error);
    return {
      status: "error",
      message: "An error occurred while fetching the buyer profile"
    };
  }
}

export async function updateBuyerProfile(formData) {
  try {
    // Get the API URL from environment variable
    const apiUrl = process.env.SERVER_API_URL;
    
    // Get the token from cookies
    const { cookies } = await import("next/headers");
    const cookieStore = cookies();
    const token = cookieStore.get("accessToken")?.value;
    
    if (!token) {
      return {
        status: "error",
        message: "Authentication token not found"
      };
    }

    // Decode the token if it's URL encoded
    const decodedToken = decodeURIComponent(token);

    // Prepare the request data
    const requestData = {
      categories: formData.categories || [],
      preferences: formData.preferences || "",
      budget_min: formData.budget_min ? parseFloat(formData.budget_min) : null,
      budget_max: formData.budget_max ? parseFloat(formData.budget_max) : null,
      profile_link: formData.profile_link || "",
      tags: formData.tags || []
    };

    console.log("Updating buyer profile with data:", requestData);

    // Make the API request
    const response = await fetch(`${apiUrl}/buyer-profile`, {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${decodedToken}`,
        "Accept": "application/json"
      },
      body: JSON.stringify(requestData)
    });

    const result = await response.json();
    
    console.log("Buyer profile update response:", result);

    if (!response.ok) {
      return {
        status: "error",
        message: result.message || "Failed to update buyer profile",
        errors: result.errors || {}
      };
    }

    return {
      status: "success",
      message: result.message || "Buyer profile updated successfully",
      data: result.data
    };

  } catch (error) {
    console.error("Error updating buyer profile:", error);
    return {
      status: "error",
      message: "An error occurred while updating the buyer profile"
    };
  }
}

export async function getAllBuyerProfiles() {
  try {
    const apiUrl = process.env.SERVER_API_URL;
    const { cookies } = await import("next/headers");
    const cookieStore = cookies();
    const token = cookieStore.get("accessToken")?.value;

    if (!token) {
      return { status: "error", message: "Authentication token not found." };
    }

    console.log("🔍 API URL:", apiUrl);
    console.log("🔍 Token:", token ? "Present" : "Missing");
    
    const response = await fetch(`${apiUrl}/buyer-profiles`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      cache: 'no-store' // Ensure fresh data
    });

    console.log("🔍 Response status:", response.status);
    console.log("🔍 Response ok:", response.ok);
    
    const result = await response.json();
    console.log("🔍 API Result:", result);

    if (!response.ok) {
      console.error("API Error (getAllBuyerProfiles):", result);
      return { status: "error", message: result.message || "Failed to fetch buyer profiles" };
    }

    return { status: "success", data: result.data, message: result.message };
  } catch (error) {
    console.error("Error in getAllBuyerProfiles action:", error);
    return { status: "error", message: "An unexpected error occurred." };
  }
}

export async function getBuyerProfileById(id) {
  try {
    const apiUrl = process.env.SERVER_API_URL;
    const { cookies } = await import("next/headers");
    const cookieStore = cookies();
    const token = cookieStore.get("accessToken")?.value;

    if (!token) {
      return { status: "error", message: "Authentication token not found." };
    }

    const response = await fetch(`${apiUrl}/buyer-profiles/${id}`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      cache: 'no-store' // Ensure fresh data
    });

    const result = await response.json();

    if (!response.ok) {
      console.error("API Error (getBuyerProfileById):", result);
      return { status: "error", message: result.message || "Failed to fetch buyer profile" };
    }

    return { status: "success", data: result.data, message: result.message };
  } catch (error) {
    console.error("Error in getBuyerProfileById action:", error);
    return { status: "error", message: "An unexpected error occurred." };
  }
}

// Get buyer's interested cards for deal building
export async function getBuyerInterests(buyerId, search = "") {
  try {
    const params = new URLSearchParams();
    if (search) params.set('search', search);
    
    const res = await fetch(`${baseUrl}/buyer-profile/${buyerId}/interests?${params.toString()}`, {
      method: "GET",
      next: { revalidate: 0 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
    return { status: 'error', data: [] };
  }
}
