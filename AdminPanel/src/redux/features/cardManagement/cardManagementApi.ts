import { TResponseRedux } from "../../../types";
import baseApi from "../../api/baseApi";

// Define the card type based on the backend structure
export interface TCard {
  id: number;
  card_title: string;
  description: string;
  price: number;
  grade: string;
  sport_type: string;
  weight: number;
  images: string[];
  request_status: 'pending' | 'approved' | 'rejected';
  created_at: string;
  updated_at: string;
  seller_inventory: {
    id: number;
    card_title: string;
    description: string;
    price: number;
    grade: string;
    sport_type: string;
    weight: number;
    images: string[];
    user: {
      id: number;
      name: string;
      email: string;
    };
  };
}

const cardManagementApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getCards: builder.query<TResponseRedux<TCard[]>, object>({
      query: (args) => ({
        url: "/card-requests",
        method: "GET",
        params: args,
      }),
      providesTags: ["card"],
    }),

    getCard: builder.query<TResponseRedux<TCard>, number>({
      query: (id) => ({
        url: `/card-requests/${id}`,
        method: "GET",
      }),
      providesTags: ["card"],
    }),

    approveCard: builder.mutation({
      query: (id) => ({
        url: `/card-requests/${id}/approve`,
        method: "POST",
      }),
      invalidatesTags: ["card"],
    }),

    rejectCard: builder.mutation({
      query: (id) => ({
        url: `/card-requests/${id}/reject`,
        method: "POST",
      }),
      invalidatesTags: ["card"],
    }),

    getCardStatistics: builder.query<TResponseRedux<any>, void>({
      query: () => ({
        url: "/card-requests/statistics",
        method: "GET",
      }),
      providesTags: ["card"],
    }),
  }),
});

export const { 
  useGetCardsQuery, 
  useGetCardQuery, 
  useApproveCardMutation, 
  useRejectCardMutation,
  useGetCardStatisticsQuery 
} = cardManagementApi;
