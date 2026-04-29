import { TResponseRedux, TSubCategory } from "../../../types";
import baseApi from "../../api/baseApi";

const subCategoryApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getAllSubCategory: builder.query<TResponseRedux<TSubCategory[]>, undefined>(
      {
        query: () => ({
          url: "/sub-categories/get-all",
          method: "GET",
        }),
        providesTags: ["subCategory"],
      }
    ),

    addSubCategory: builder.mutation({
      query: (data) => ({
        url: "/sub-categories/add",
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["subCategory"],
    }),

    updateSubCategory: builder.mutation({
      query: ({ id, data }) => ({
        url: `/sub-categories/update/${id}`,
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["subCategory"],
    }),

    deleteSubCategory: builder.mutation({
      query: (id) => ({
        url: `/sub-categories/delete/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: ["subCategory"],
    }),
  }),
});

export const {
  useGetAllSubCategoryQuery,
  useAddSubCategoryMutation,
  useDeleteSubCategoryMutation,
  useUpdateSubCategoryMutation,
} = subCategoryApi;
