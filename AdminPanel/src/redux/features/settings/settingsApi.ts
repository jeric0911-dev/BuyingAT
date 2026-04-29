import {
  TGateway,
  TGoogleCredential,
  TMailConfig,
  TPusherConfig,
  TResponseRedux,
} from "../../../types";
import baseApi from "../../api/baseApi";

const settingsApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getMailConfig: builder.query<TResponseRedux<TMailConfig>, undefined>({
      query: () => ({
        url: "/mail-config",
        method: "GET",
      }),
      providesTags: ["mailConfig"],
    }),

    editMailConfig: builder.mutation({
      query: (data) => ({
        url: `/mail-config`,
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["mailConfig"],
    }),

    getPusherConfig: builder.query<TResponseRedux<TPusherConfig>, undefined>({
      query: () => ({
        url: "/pusher-config",
        method: "GET",
      }),
      providesTags: ["pusherConfig"],
    }),

    editPusherConfig: builder.mutation({
      query: (data) => ({
        url: "/pusher-config",
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["pusherConfig"],
    }),

    getGateways: builder.query<TResponseRedux<TGateway[]>, undefined>({
      query: () => ({
        url: "/gateway",
        method: "GET",
      }),
      providesTags: ["gateway"],
    }),

    editGateway: builder.mutation({
      query: ({ alias, data }) => ({
        url: `/gateway/${alias}`,
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["gateway"],
    }),

    googleCredential: builder.query<
      TResponseRedux<TGoogleCredential>,
      undefined
    >({
      query: () => ({
        url: "/google-config",
        method: "GET",
      }),
      providesTags: ["googleCredential"],
    }),

    editGoogleCredential: builder.mutation({
      query: (data) => ({
        url: "/google-config",
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["googleCredential"],
    }),
  }),
});

export const {
  useGetMailConfigQuery,
  useEditMailConfigMutation,
  useGetPusherConfigQuery,
  useEditPusherConfigMutation,
  useGetGatewaysQuery,
  useEditGatewayMutation,
  useGoogleCredentialQuery,
  useEditGoogleCredentialMutation,
} = settingsApi;
