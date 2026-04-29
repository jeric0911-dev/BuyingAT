import { TChildCategory, TResponseRedux } from "../../../types";
import baseApi from "../../api/baseApi";

const childCategoryApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getAllChildCategory: builder.query<TResponseRedux<TChildCategory[]>, undefined>({
      query: () => ({
        url: "/child-categories/get-all",
        method: "GET",
      }),
      providesTags: ["childCategory"],
    }),

    addChildCategory: builder.mutation({
      query: (data) => ({
        url: "/child-categories/add",
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["childCategory"],
    }),

    updateChildCategory: builder.mutation({
      query: ({ id, data }) => ({
        url: `/child-categories/update/${id}`,
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["childCategory"],
    }),

    deleteChildCategory: builder.mutation({
      query: (id) => ({
        url: `/child-categories/delete/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: ["childCategory"],
    }),
  }),
});

export const {
  useGetAllChildCategoryQuery,
  useAddChildCategoryMutation,
  useDeleteChildCategoryMutation,
  useUpdateChildCategoryMutation,
} = childCategoryApi;
