import { TClientQuery, TResponseRedux } from "../../../types";
import baseApi from "../../api/baseApi";

const clientQueryApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getAllClientQuery: builder.query<TResponseRedux<TClientQuery[]>, object>({
      query: (args) => ({
        url: "/contact-us/get-all",
        method: "GET",
        params: args,
      }),
      providesTags: ["clientQuery"],
    }),

    deleteClientQuery: builder.mutation({
      query: (id) => ({
        url: `/contact-us/delete/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: ["clientQuery", "meta"],
    }),
  }),
});

export const { useGetAllClientQueryQuery, useDeleteClientQueryMutation } =
  clientQueryApi;
