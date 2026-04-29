import { TFooter, TResponseRedux } from "../../../types";
import baseApi from "../../api/baseApi";

const footerApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getFooter: builder.query<TResponseRedux<TFooter>, undefined>({
      query: () => ({
        url: "/footer_section/get",
        method: "GET",
      }),
      providesTags: ["footer"],
    }),

    addUpdateFooter: builder.mutation({
      query: (data) => ({
        url: "/footer_section/create-or-update",
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["footer"],
    }),
  }),
});

export const { useGetFooterQuery, useAddUpdateFooterMutation } = footerApi;
