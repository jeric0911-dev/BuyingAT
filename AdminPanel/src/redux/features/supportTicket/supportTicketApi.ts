import { TMessage, TResponseRedux, TSupportTicket } from "../../../types";
import baseApi from "../../api/baseApi";

const supportTicketApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getSupportTickets: builder.query<TResponseRedux<TSupportTicket[]>, object>({
      query: (args) => ({
        url: "/tickets",
        method: "GET",
        params: args,
      }),
      providesTags: ["supportTicket"],
    }),

    getTicketDetails: builder.query<TResponseRedux<TMessage[]>, string>({
      query: (id) => ({
        url: `/ticket-messages/${id}`,
        method: "GET",
      }),
      providesTags: (_, __, id) => [{ type: "supportTicket", id }],
    }),

    replayTicket: builder.mutation({
      query: (data) => ({
        url: `/ticket-messages`,
        method: "POST",
        body: data,
      }),
      invalidatesTags: (_, __, data) => [
        { type: "supportTicket", id: data.ticket_id },
      ],
    }),

    closeTicket: builder.mutation({
      query: (id) => ({
        url: `/close-tickets/${id}`,
        method: "GET",
      }),
      invalidatesTags: ["supportTicket", "meta"],
    }),

    deleteTicket: builder.mutation({
      query: (id) => ({
        url: `/tickets/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: (_, __, id) => [
        { type: "supportTicket", id },
        "supportTicket",
      ],
    }),
  }),
});

export const {
  useCloseTicketMutation,
  useGetSupportTicketsQuery,
  useReplayTicketMutation,
  useGetTicketDetailsQuery,
  useDeleteTicketMutation,
} = supportTicketApi;
