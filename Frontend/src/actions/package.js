"use server";

export async function getCurrentPackage() {
  try {
    const apiUrl = (process.env.SERVER_API_URL || "").replace(/\/$/, "");
    const { cookies } = await import("next/headers");
    const token = cookies().get("accessToken")?.value;
    if (!token) return { status: 'error', message: 'Not authenticated' };
    const res = await fetch(`${apiUrl}/user/current-package`, {
      method: 'GET',
      headers: { Authorization: `Bearer ${decodeURIComponent(token)}` },
      next: { revalidate: 0 },
    });
    const json = await res.json();
    return json;
  } catch (e) {
    return { status: 'error', message: 'Failed to fetch current package' };
  }
}

export async function getUserPackageStatus(userId) {
  try {
    const apiUrl = (process.env.SERVER_API_URL || "").replace(/\/$/, "");
    const res = await fetch(`${apiUrl}/user/package-status/${userId}`, {
      method: 'GET',
      next: { revalidate: 0 },
    });
    return await res.json();
  } catch (e) {
    return { status: 'error', message: 'Failed to fetch user package status' };
  }
}


