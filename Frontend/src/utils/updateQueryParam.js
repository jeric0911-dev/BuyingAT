const updateQueryParam = (key, value, replace = true) => {
  try {
    if (!key || typeof key !== "string") {
      throw new Error("Invalid key. It must be a non-empty string");
    }

    const url = new URL(window.location.href);
    const params = new URLSearchParams(url.search);

    if (value === null || value === undefined || value === "") {
      params.delete(key);
    } else {
      params.set(key, value);
    }

    const newUrl = `${url.pathname}?${params.toString()}`;

    if (replace) {
      window.history.replaceState(null, "", newUrl);
    } else {
      window.history.pushState(null, "", newUrl);
    }
  } catch (error) {
    console.log("updateQueryParam error: ", error.message);
  }
};

export default updateQueryParam;
