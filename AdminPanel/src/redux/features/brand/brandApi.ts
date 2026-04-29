import { TBrand, TResponseRedux } from "../../../types";
import baseApi from "../../api/baseApi";

const nftApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getAllBrand: builder.query<TResponseRedux<TBrand[]>, undefined>({
      query: () => ({
        url: "/brands/get-all",
        method: "GET",
      }),
      providesTags: ["brand"],
    }),

    addBrand: builder.mutation({
      query: (data) => ({
        url: "/brands/add",
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["brand"],
    }),

    updateBrand: builder.mutation({
      query: ({ id, data }) => ({
        url: `/brands/update/${id}`,
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["brand"],
    }),

    deleteBrand: builder.mutation({
      query: (id) => ({
        url: `/brands/delete/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: ["brand"],
    }),
  }),
});

export const {
  useAddBrandMutation,
  useDeleteBrandMutation,
  useGetAllBrandQuery,
  useUpdateBrandMutation,
} = nftApi;
