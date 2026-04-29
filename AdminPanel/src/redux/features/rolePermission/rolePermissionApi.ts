import { TResponseRedux, TRole } from "../../../types";
import baseApi from "../../api/baseApi";

const rolePermissionApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getAllRole: builder.query<TResponseRedux<TRole[]>, undefined>({
      query: () => ({
        url: "/admin-types-spatie/get-all",
        method: "GET",
      }),
      providesTags: ["rolePermission"],
    }),

    getSingleRole: builder.query<TResponseRedux<TRole>, string>({
      query: (id) => ({
        url: `/admin-types-spatie/get-one/${id}`,
        method: "GET",
      }),
      providesTags: (_, __, id) => [{ type: "rolePermission", id }],
    }),

    addRole: builder.mutation({
      query: (data) => ({
        url: "/admin-types-spatie/add",
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["rolePermission"],
    }),

    updateRole: builder.mutation({
      query: ({ id, data }) => ({
        url: `/admin-types-spatie/update/${id}`,
        method: "POST",
        body: data,
      }),
      invalidatesTags: (_, __, { id }) => [{ type: "rolePermission", id }],
    }),

    deleteRole: builder.mutation({
      query: (id) => ({
        url: `/admin-types-spatie/delete/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: ["rolePermission"],
    }),
  }),
});

export const {
  useGetAllRoleQuery,
  useAddRoleMutation,
  useDeleteRoleMutation,
  useGetSingleRoleQuery,
  useUpdateRoleMutation,
} = rolePermissionApi;
