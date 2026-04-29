import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import {
  useDeleteRoleMutation,
  useGetAllRoleQuery,
} from "../redux/features/rolePermission/rolePermissionApi";
import { TRole } from "../types";
import { Box, Button, IconButton, Stack } from "@mui/material";
import { Link } from "react-router-dom";
import { DeleteRounded, EditRounded } from "@mui/icons-material";
import handleAsyncToast from "../utils/handleAsyncToast";
import HeaderTitle from "../components/seo/HeaderTitle";
import PageTitle from "../components/ui/shared/PageTitle";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import { useState } from "react";
import RCConfirmationModal from "../components/modal/RCConfirmationModal";

const RolePermission = () => {
  const { data, isFetching } = useGetAllRoleQuery(undefined);
  const [modalData, setModalData] = useState<TRole>();
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState<boolean>(false);
  const [deleteRole] = useDeleteRoleMutation();
  // const { delete: del } = GetPermission("role-permission") as TPermissions;

  const rowsData: GridValidRowModel[] = data?.data || [];

  const columns: GridColDef<TRole>[] = [
    { field: "type", headerName: "Role Name", minWidth: 200, flex: 1 },
    {
      field: "action",
      headerName: "Action",
      headerAlign: "right",
      renderCell: ({ row }) => (
        <Stack
          direction="row"
          justifyContent="end"
          alignItems="center"
          height="100%"
        >
          <Link to={`/role-permission/${row.id}`}>
            <IconButton aria-label="edit">
              <EditRounded color="success" />
            </IconButton>
          </Link>
          <IconButton
            onClick={() => {
              setModalData(row);
              setIsDeleteModalOpen(true);
            }}
            aria-label="delete"
          >
            <DeleteRounded color="error" />
          </IconButton>
        </Stack>
      ),
      minWidth: 140,
      flex: 1,
    },
  ];

  const handleDelete = async (id: number) => {
    // if (!del) {
    //   toast.error("You don't have permission");
    // } else {
    handleAsyncToast({
      promise: deleteRole(id).unwrap(),
      success: () => {
        return "Role deleted successfully!";
      },
    });
    // }
  };

  return (
    <>
      <HeaderTitle title="Role Permission" />
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="Role & Permission" />
        <Link to="/role-permission/create">
          <Button>Add Role</Button>
        </Link>
      </Stack>
      <Box
        mt="20px"
        sx={{ border: "1px solid #E0E2E7" }}
        borderRadius={2}
        bgcolor="white"
        overflow="hidden"
      >
        <MyDataGrid rows={rowsData} columns={columns} loading={isFetching} />
      </Box>
      {isDeleteModalOpen && (
        <RCConfirmationModal
          open={isDeleteModalOpen}
          setOpen={setIsDeleteModalOpen}
          handleDelete={() => handleDelete(modalData?.id as number)}
        />
      )}
    </>
  );
};

export default RolePermission;
