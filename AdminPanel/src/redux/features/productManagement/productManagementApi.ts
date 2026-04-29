import { TProduct, TResponseRedux } from "../../../types";
import baseApi from "../../api/baseApi";

const productManagementApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getProducts: builder.query<TResponseRedux<TProduct[]>, object>({
      query: (args) => ({
        url: "/products/get-all",
        method: "GET",
        params: args,
      }),
      providesTags: ["product"],
    }),

    updateProduct: builder.mutation({
      query: (data) => ({
        url: `/products/approve-or-reject`,
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["product", "meta"],
    }),
  }),
});

export const { useGetProductsQuery, useUpdateProductMutation } =
  productManagementApi;
