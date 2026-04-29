import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";
import { RootState } from "../store";

const baseApi = createApi({
  reducerPath: "api",
  baseQuery: fetchBaseQuery({
    baseUrl: import.meta.env.VITE_API_URL,
    prepareHeaders: (headers, { getState }) => {
      const token = (getState() as RootState).auth.token;
      if (token) headers.set("authorization", `Bearer ${token}`);
      return headers;
    },
  }),
  endpoints: () => ({}),
  tagTypes: [
    "user",
    "slider",
    "advertisement",
    "category",
    "subCategory",
    "childCategory",
    "blogCategory",
    "blog",
    "rolePermission",
    "admin",
    "faq",
    "brand",
    "social",
    "country",
    "city",
    "state",
    "footer",
    "heroSection",
    "shop",
    "page",
    "product",
    "packageCategory",
    "package",
    "gateway",
    "mailConfig",
    "pusherConfig",
    "googleCredential",
    "supportTicket",
    "webSettings",
    "report",
    "clientQuery",
    "meta",
    "currency",
    "buyerApproval",
    "card",
  ],
});

export default baseApi;
