import { TSlider, TResponseRedux, TAD } from "../../../types";
import baseApi from "../../api/baseApi";

const advertisementApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getAllSlider: builder.query<TResponseRedux<TSlider[]>, undefined>({
      query: () => ({
        url: "/sliders/get-all",
        method: "GET",
      }),
      providesTags: ["slider"],
    }),
    getAdvertisement: builder.query<TResponseRedux<TAD>, undefined>({
      query: () => ({
        url: "/advertise/get-all",
        method: "GET",
      }),
      providesTags: ["advertisement"],
    }),

    addSlider: builder.mutation({
      query: (data) => ({
        url: "/sliders/add",
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["slider"],
    }),
    addAdvertisement: builder.mutation({
      query: (data) => ({
        url: "/advertise/add_or_update",
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["advertisement"],
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
        url: `/sliders/delete/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: ["slider"],
    }),
  }),
});

export const {
  useGetAllSliderQuery,
  useAddSliderMutation,
  useUpdateSliderMutation,
  useDeleteSliderMutation,
  useAddAdvertisementMutation,
  useGetAdvertisementQuery,
} = advertisementApi;
