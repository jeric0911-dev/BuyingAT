import { TCityState, TResponseRedux } from "../../../types";
import baseApi from "../../api/baseApi";

const cityStateApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getAllCity: builder.query<TResponseRedux<TCityState[]>, undefined>({
      query: () => ({
        url: "/city/get-all",
        method: "GET",
      }),
      providesTags: ["city"],
    }),
    getAllState: builder.query<TResponseRedux<TCityState[]>, undefined>({
      query: () => ({
        url: "/state/get-all",
        method: "GET",
      }),
      providesTags: ["state"],
    }),

    addCity: builder.mutation({
      query: (data) => ({
        url: "/city/add",
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["city"],
    }),
    addState: builder.mutation({
      query: (data) => ({
        url: "/state/add",
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["state"],
    }),

    updateCity: builder.mutation({
      query: ({ id, data }) => ({
        url: `/city/update/${id}`,
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["city"],
    }),
    updateState: builder.mutation({
      query: ({ id, data }) => ({
        url: `/state/update/${id}`,
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["state"],
    }),

    deleteCity: builder.mutation({
      query: (id) => ({
        url: `/city/delete/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: ["city"],
    }),
    deleteState: builder.mutation({
      query: (id) => ({
        url: `/state/delete/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: ["state"],
    }),
  }),
});

export const {
  useAddCityMutation,
  useGetAllCityQuery,
  useDeleteCityMutation,
  useUpdateCityMutation,
  useAddStateMutation,
  useGetAllStateQuery,
  useDeleteStateMutation,
  useUpdateStateMutation,
} = cityStateApi;
