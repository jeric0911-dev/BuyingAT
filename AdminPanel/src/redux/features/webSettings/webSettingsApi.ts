import { TResponseRedux, TWebSettings } from "../../../types";
import baseApi from "../../api/baseApi";

const webSettingsApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getWebSettings: builder.query<TResponseRedux<TWebSettings>, undefined>({
      query: () => ({
        url: "/app-setting",
        method: "GET",
      }),
      providesTags: ["webSettings"],
    }),

    updateWebSettings: builder.mutation({
      query: (data) => ({
        url: "/app-settings/update",
        method: "POST",
        body: data
      }),
      invalidatesTags: ["webSettings"],
    }),
  }),
});

export const { useGetWebSettingsQuery, useUpdateWebSettingsMutation } =
  webSettingsApi;
