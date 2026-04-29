import { TResponseRedux, TShop } from "../../../types";
import baseApi from "../../api/baseApi";

const shopManagementApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getShops: builder.query<TResponseRedux<TShop[]>, object>({
      query: (args) => ({
        url: "/shops/get-all",
        method: "GET",
        params: args,
      }),
      providesTags: ["shop"],
    }),

    changeShopStatus: builder.mutation({
      query: (data) => ({
        url: "/shops/approve-or-reject",
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["shop", "meta"],
    }),
  }),
});

export const { useChangeShopStatusMutation, useGetShopsQuery } =
  shopManagementApi;
