"use server";

const baseUrl = process.env.SERVER_API_URL;

export const getCountries = async () => {
  try {
    const res = await fetch(`${baseUrl}/home/countries`, {
      method: "GET",
      next: { revalidate: 3600 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getCities = async () => {
  try {
    const res = await fetch(`${baseUrl}/home/cities`, {
      method: "GET",
      next: { revalidate: 3600 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getStates = async () => {
  try {
    const res = await fetch(`${baseUrl}/home/states`, {
      method: "GET",
      next: { revalidate: 3600 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};

export const getGoogleConfig = async () => {
  try {
    const res = await fetch(`${baseUrl}/home/google-config`, {
      method: "GET",
      next: { revalidate: 3600 },
    });
    return await res.json();
  } catch (error) {
    console.log(error);
  }
};
