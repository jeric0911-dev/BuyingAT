import { TMeta, TReport, TResponseRedux, TSlider } from "../../../types";
import baseApi from "../../api/baseApi";

const othersApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getAllSliders: builder.query<TResponseRedux<TSlider[]>, undefined>({
      query: () => ({
        url: "/sliders",
        method: "GET",
      }),
      providesTags: ["slider"],
    }),

    addSlider: builder.mutation({
      query: (data) => ({
        url: "/sliders",
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["slider"],
    }),

    updateSlider: builder.mutation({
      query: ({ id, data }) => ({
        url: `/sliders/update/${id}`,
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["slider"],
    }),

    deleteSlider: builder.mutation({
      query: (id) => ({
        url: `/sliders/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: ["slider"],
    }),

    getReports: builder.query<TResponseRedux<TReport[]>, object>({
      query: (args) => ({
        url: "/reports",
        method: "GET",
        params: args,
      }),
      providesTags: ["report"],
    }),

    deleteReport: builder.mutation({
      query: (id) => ({
        url: `/reports/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: ["report"],
    }),

    getDashboardMeta: builder.query<TResponseRedux<TMeta>, undefined>({
      query: () => ({
        url: "/admin-dashboard-stats",
        method: "GET",
      }),
      providesTags: ["meta"],
    }),
  }),
});

export const {
  useGetAllSlidersQuery,
  useAddSliderMutation,
  useDeleteSliderMutation,
  useUpdateSliderMutation,
  useDeleteReportMutation,
  useGetReportsQuery,
  useGetDashboardMetaQuery
} = othersApi;
