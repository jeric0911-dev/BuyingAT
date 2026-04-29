import { TResponseRedux, TCountry } from "../../../types";
import baseApi from "../../api/baseApi";

const countryApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getAllCountry: builder.query<TResponseRedux<TCountry[]>, undefined>({
      query: () => ({
        url: "/country/get-all",
        method: "GET",
      }),
      providesTags: ["country"],
    }),

    addCountry: builder.mutation({
      query: (data) => ({
        url: "/country/add",
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["country"],
    }),

    updateCountry: builder.mutation({
      query: ({ id, data }) => ({
        url: `/country/update/${id}`,
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["country"],
    }),

    deleteCountry: builder.mutation({
      query: (id) => ({
        url: `/country/delete/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: ["country"],
    }),
  }),
});

export const {
  useGetAllCountryQuery,
  useAddCountryMutation,
  useDeleteCountryMutation,
  useUpdateCountryMutation,
} = countryApi;
