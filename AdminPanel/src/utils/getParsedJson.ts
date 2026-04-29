const getParsedJson = (str: string) => {
  try {
    const once = JSON.parse(str);
    return typeof once === "string" ? JSON.parse(once) : once;
  } catch (e) {
    console.error("Failed to parse JSON:", e);
    return null;
  }
};

export default getParsedJson;
