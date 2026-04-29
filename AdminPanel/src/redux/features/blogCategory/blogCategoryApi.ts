import { TBlogCategory, TResponseRedux } from "../../../types";
import baseApi from "../../api/baseApi";

const blogCategoryApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    addBlogCategory: builder.mutation({
      query: (data) => ({
        url: "/blogs/category/add",
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["blogCategory"],
    }),

    getAllBlogCategory: builder.query<
      TResponseRedux<TBlogCategory[]>,
      undefined
    >({
      query: () => ({
        url: "/blogs/category/get-all",
        method: "GET",
      }),
      providesTags: ["blogCategory"],
    }),

    updateBlogCategory: builder.mutation({
      query: ({ id, data }) => ({
        url: `/blogs/category/update/${id}`,
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["blogCategory"],
    }),

    deleteBlogCategory: builder.mutation({
      query: (id) => ({
        url: `/blogs/category/delete/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: ["blogCategory"],
    }),
  }),
});

export const {
  useAddBlogCategoryMutation,
  useDeleteBlogCategoryMutation,
  useGetAllBlogCategoryQuery,
  useUpdateBlogCategoryMutation,
} = blogCategoryApi;
