import { TFaq, TResponseRedux } from "../../../types";
import baseApi from "../../api/baseApi";

const faqApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    addFaq: builder.mutation({
      query: (data) => ({
        url: "/faq/add",
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["faq"],
    }),

    getAllFaq: builder.query<TResponseRedux<TFaq[]>, undefined>({
      query: () => ({
        url: "/faq/get-all",
        method: "GET",
      }),
      providesTags: ["faq"],
    }),

    updateFaq: builder.mutation({
      query: ({ id, data }) => ({
        url: `/faq/update/${id}`,
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["faq"],
    }),

    deleteFaq: builder.mutation({
      query: (id) => ({
        url: `/faq/delete/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: ["faq"],
    }),
  }),
});

export const {
  useAddFaqMutation,
  useGetAllFaqQuery,
  useUpdateFaqMutation,
  useDeleteFaqMutation,
} = faqApi;
