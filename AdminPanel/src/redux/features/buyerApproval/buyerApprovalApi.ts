import baseApi from "../../api/baseApi";

const buyerApprovalApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getBuyerRequests: builder.query({
      query: () => "/buyer-requests/all",
      providesTags: ["buyerApproval"],
    }),
    getPendingBuyerRequests: builder.query({
      query: () => "/buyer-requests",
      providesTags: ["buyerApproval"],
    }),
    approveBuyerRequest: builder.mutation({
      query: (id) => ({
        url: `/buyer-requests/${id}/approve`,
        method: "POST",
      }),
      invalidatesTags: ["buyerApproval"],
    }),
    rejectBuyerRequest: builder.mutation({
      query: (id) => ({
        url: `/buyer-requests/${id}/reject`,
        method: "POST",
      }),
      invalidatesTags: ["buyerApproval"],
    }),
    getBuyerApprovalStatistics: builder.query({
      query: () => "/buyer-requests/statistics",
      providesTags: ["buyerApproval"],
    }),
  }),
});

export const {
  useGetBuyerRequestsQuery,
  useGetPendingBuyerRequestsQuery,
  useApproveBuyerRequestMutation,
  useRejectBuyerRequestMutation,
  useGetBuyerApprovalStatisticsQuery,
} = buyerApprovalApi;
