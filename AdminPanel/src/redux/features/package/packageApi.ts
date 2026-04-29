import { TPackage, TResponseRedux } from "../../../types";
import baseApi from "../../api/baseApi";

const packageApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    addPackage: builder.mutation({
      query: (data) => ({
        url: "/package/add",
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["package"],
    }),

    getPackages: builder.query<TResponseRedux<TPackage[]>, undefined>({
      query: () => ({
        url: "/package/get-all",
        method: "GET",
      }),
      providesTags: ["package"],
    }),

    editPackage: builder.mutation({
      query: ({ id, data }) => ({
        url: `/package/update/${id}`,
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["package"],
    }),

    deletePackage: builder.mutation({
      query: (id) => ({
        url: `/package/delete/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: ["package"],
    }),
  }),
});

export const {
  useAddPackageMutation,
  useDeletePackageMutation,
  useEditPackageMutation,
  useGetPackagesQuery,
} = packageApi;
