import { TBlog, TResponseRedux } from "../../../types";
import baseApi from "../../api/baseApi";

const blogApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    addBlog: builder.mutation({
      query: (data) => ({
        url: "/blogs/add",
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["blog"],
    }),

    getAllBlog: builder.query<TResponseRedux<TBlog[]>, undefined>({
      query: () => ({
        url: "/blogs/get-all",
        method: "GET",
      }),
      providesTags: ["blog"],
    }),

    updateBlog: builder.mutation({
      query: ({ id, data }) => {
        return {
          url: `/blogs/update/${id}`,
          method: "POST",
          body: data,
        };
      },
      invalidatesTags: ["blog"],
    }),

    deleteBlog: builder.mutation({
      query: (id) => ({
        url: `/blogs/delete/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: ["blog"],
    }),
  }),
});

export const {
  useAddBlogMutation,
  useDeleteBlogMutation,
  useGetAllBlogQuery,
  useUpdateBlogMutation,
} = blogApi;
