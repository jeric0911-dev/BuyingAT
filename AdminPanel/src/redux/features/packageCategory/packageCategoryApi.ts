import { TPackageCategory, TResponseRedux } from "../../../types";
import baseApi from "../../api/baseApi";

const packageCategoryApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getPackageCategories: builder.query<
      TResponseRedux<TPackageCategory[]>,
      undefined
    >({
      query: () => ({
        url: "/package-category/get-all",
        method: "GET",
      }),
      providesTags: ["packageCategory"],
    }),

    addPackageCategory: builder.mutation({
      query: (data) => ({
        url: "/package-category/add",
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["packageCategory"],
    }),

    editPackageCategory: builder.mutation({
      query: ({ id, data }) => ({
        url: `/package-category/update/${id}`,
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["packageCategory"],
    }),

    deletePackageCategory: builder.mutation({
      query: (id) => ({
        url: `/package-category/delete/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: ["packageCategory"],
    }),
  }),
});

export const {
  useAddPackageCategoryMutation,
  useDeletePackageCategoryMutation,
  useEditPackageCategoryMutation,
  useGetPackageCategoriesQuery,
} = packageCategoryApi;
