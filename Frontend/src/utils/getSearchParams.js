const getSearchParams = (data) => {
  const params = new URLSearchParams();

  Object.entries(data).forEach(([key, value]) => {
    if (value === null || value === undefined || value === "") return;
    params.append(key, value);
  });

  return params;
};

export default getSearchParams;
