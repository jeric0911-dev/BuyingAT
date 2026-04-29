const appendFormData = (formData, key, value) => {
  if (value === null || value === undefined || value === "") {
    return; // Skip empty values
  }

  if (typeof value === "object" && !(value instanceof File)) {
    if (Array.isArray(value)) {
      if (value.every((v) => !(v instanceof File))) {
        formData.append(key, JSON.stringify(value));
      } else {
        value.forEach(
          (v, index) => appendFormData(formData, `${key}[${index}]`, v)
        );
      }
    } else {
      Object.entries(value).forEach(
        ([k, v]) => appendFormData(formData, `${key}[${k}]`, v)
      );
    }
  } else {
    formData.append(key, value);
  }
};

const objectToFormData = (obj) => {
  const formData = new FormData();
  Object.entries(obj).forEach(([key, value]) =>
    appendFormData(formData, key, value)
  );
  return formData;
};

export default objectToFormData;
