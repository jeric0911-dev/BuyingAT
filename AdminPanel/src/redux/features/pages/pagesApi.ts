import { TPage, TResponseRedux } from "../../../types";
import baseApi from "../../api/baseApi";

const pagesApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    addPage: builder.mutation({
      query: (data) => ({
        url: "/more-page/add",
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["page"],
    }),

    getAllPage: builder.query<TResponseRedux<TPage[]>, undefined>({
      query: () => ({
        url: "/more-page/get-all",
        method: "GET",
      }),
      providesTags: ["page"],
    }),

    updatePage: builder.mutation({
      query: ({ id, data }) => ({
        url: `/more-page/update/${id}`,
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["page"],
    }),

    deletePage: builder.mutation({
      query: (id) => ({
        url: `/more-page/delete/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: ["page"],
    }),
  }),
});

export const {
  useAddPageMutation,
  useDeletePageMutation,
  useGetAllPageQuery,
  useUpdatePageMutation,
} = pagesApi;
