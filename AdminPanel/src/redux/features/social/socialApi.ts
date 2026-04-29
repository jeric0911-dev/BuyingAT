import { TResponseRedux, TSocial } from "../../../types";
import baseApi from "../../api/baseApi";

const socialApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    addSocial: builder.mutation({
      query: (data) => ({
        url: "/socials/add",
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["social"],
    }),

    updateSocial: builder.mutation({
      query: ({ id, data }) => ({
        url: `/socials/update/${id}`,
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["social"],
    }),

    getAllSocial: builder.query<TResponseRedux<TSocial[]>, undefined>({
      query: () => ({
        url: "/socials/get-all",
        method: "GET",
      }),
      providesTags: ["social"],
    }),

    deleteSocial: builder.mutation({
      query: (id) => ({
        url: `/socials/delete/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: ["social"],
    }),
  }),
});

export const {
  useAddSocialMutation,
  useDeleteSocialMutation,
  useGetAllSocialQuery,
  useUpdateSocialMutation,
} = socialApi;
