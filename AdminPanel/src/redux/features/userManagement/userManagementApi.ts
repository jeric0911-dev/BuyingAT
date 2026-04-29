import { TResponseRedux, TUser } from "../../../types";
import baseApi from "../../api/baseApi";

const userManagementApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getUsers: builder.query<TResponseRedux<TUser[]>, object>({
      query: (args) => ({
        url: "/users/get-all",
        method: "GET",
        params: args,
      }),
      providesTags: ["user"],
    }),

    getAUser: builder.query<TResponseRedux<TUser>, string>({
      query: (id) => ({
        url: `/users/get-one/${id}`,
        method: "GET",
      }),
      providesTags: (_, __, id) => [{ type: "user", id }],
    }),

    editUser: builder.mutation({
      query: (data) => ({
        url: "/users/update-status",
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["user", "meta"],
    }),
  }),
});

export const { useEditUserMutation, useGetUsersQuery, useGetAUserQuery } =
  userManagementApi;
