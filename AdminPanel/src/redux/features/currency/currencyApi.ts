import { TCurrency, TResponseRedux } from "../../../types";
import baseApi from "../../api/baseApi";

const currencyApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getCurrencies: builder.query<TResponseRedux<TCurrency[]>, undefined>({
      query: () => ({
        url: "/currency/get-all",
        method: "GET",
      }),
      providesTags: ["currency"],
    }),

    addCurrency: builder.mutation({
      query: (data) => ({
        url: "/currency/add",
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["currency"],
    }),

    updateCurrency: builder.mutation({
      query: ({ id, data }) => ({
        url: `/currency/update/${id}`,
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["currency"],
    }),

    deleteCurrency: builder.mutation({
      query: (id) => ({
        url: `/currency/delete/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: ["currency"],
    }),
  }),
});

export const {
  useAddCurrencyMutation,
  useDeleteCurrencyMutation,
  useGetCurrenciesQuery,
  useUpdateCurrencyMutation,
} = currencyApi;
