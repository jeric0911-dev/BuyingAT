import { THeroSection, TResponse } from "../../../types";
import baseApi from "../../api/baseApi";

const heroSectionApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getHeroSection: builder.query<TResponse<THeroSection>, undefined>({
      query: () => ({
        url: "/hero_section/get",
        method: "GET",
      }),
      providesTags: ["heroSection"],
    }),

    addUpdateHeroSection: builder.mutation<TResponse<THeroSection>, FormData>({
      query: (data) => ({
        url: "/hero_section/create-or-update",
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["heroSection"],
    }),
  }),
});

export const { useGetHeroSectionQuery, useAddUpdateHeroSectionMutation } =
  heroSectionApi;
