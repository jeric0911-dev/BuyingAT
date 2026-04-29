import { TResponseRedux, TTransaction } from "../../../types";
import baseApi from "../../api/baseApi";

const transactionApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getTransactions: builder.query<TResponseRedux<TTransaction[]>, object>({
      query: (args) => ({
        url: "/total-payments",
        method: "GET",
        params: args,
      }),
    }),
  }),
});

export const { useGetTransactionsQuery } = transactionApi;
