import { TCategory, TResponseRedux } from "../../../types";
import baseApi from "../../api/baseApi";

const categoryApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getAllCategory: builder.query<TResponseRedux<TCategory[]>, undefined>({
      query: () => ({
        url: "/categories/get-all",
        method: "GET",
      }),
      providesTags: ["category"],
    }),

    addCategory: builder.mutation({
      query: (data) => ({
        url: "/categories/add",
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["category", "meta"],
    }),

    updateCategory: builder.mutation({
      query: ({ id, data }) => ({
        url: `/categories/update/${id}`,
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["category"],
    }),

    deleteCategory: builder.mutation({
      query: (id) => ({
        url: `/categories/delete/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: ["category", "meta"],
    }),
  }),
});

export const {
  useGetAllCategoryQuery,
  useAddCategoryMutation,
  useDeleteCategoryMutation,
  useUpdateCategoryMutation,
} = categoryApi;
