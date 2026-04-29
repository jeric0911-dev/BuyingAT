import { useState } from "react";
import { TAdmin, TModalState, TPermissions } from "../types";
import {
  useDeleteAdminMutation,
  useGetAllAdminQuery,
} from "../redux/features/admin/adminApi";
import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import { Box, Button, IconButton, Stack } from "@mui/material";
import { DeleteRounded, EditRounded } from "@mui/icons-material";
import handleAsyncToast from "../utils/handleAsyncToast";
import HeaderTitle from "../components/seo/HeaderTitle";
import PageTitle from "../components/ui/shared/PageTitle";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import AddAdminModal from "../components/ui/admin/AddAdminModal";
import UpdateAdminModal from "../components/ui/admin/UpdateAdminModal";
import RCConfirmationModal from "../components/modal/RCConfirmationModal";
import GetPermission from "../utils/getPermission";
import { toast } from "sonner";

const Admins = () => {
  const [modalState, setModalState] = useState<TModalState<TAdmin>>({
    type: null,
  });
  const { data, isFetching } = useGetAllAdminQuery(undefined);
  const [deleteAdmin] = useDeleteAdminMutation();
  const { delete: del, edit } = GetPermission("admins") as TPermissions;

  const rowsData: GridValidRowModel[] = data?.data || [];

  const columns: GridColDef<TAdmin>[] = [
    { field: "username", headerName: "Name", minWidth: 200, flex: 1 },
    { field: "email", headerName: "Email", minWidth: 200, flex: 1 },
    {
      field: "role",
      headerName: "Role",
      renderCell: ({ row }) => row.admin_type.type,
      minWidth: 150,
      flex: 1,
    },
    {
      field: "action",
      headerName: "Action",
      renderCell: ({ row }) => (
        <Stack direction="row" alignItems="center" spacing={1} height="100%">
          <IconButton onClick={() => handleEditModal(row)} aria-label="edit">
            <EditRounded color="success" />
          </IconButton>
          <IconButton
            onClick={() => setModalState({ type: "delete", data: row })}
            aria-label="delete"
          >
            <DeleteRounded color="error" />
          </IconButton>
        </Stack>
      ),
      minWidth: 150,
      flex: 1,
    },
  ];

  const handleEditModal = (data: TAdmin) => {
    if (!edit) {
      toast.error("You don't have permission");
    } else {
      setModalState({ type: "edit", data });
    }
  };
  const handleDelete = async (id: number) => {
    if (!del) {
      toast.error("You don't have permission");
    } else {
      handleAsyncToast({
        promise: deleteAdmin(id).unwrap(),
        success: () => {
          return "Admin deleted successfully!";
        },
      });
    }
  };
  const closeModal = () => setModalState({ type: null });

  return (
    <>
      <HeaderTitle title="Admins" />
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="Admins" />
        <Button onClick={() => setModalState({ type: "add" })}>
          Add Admin
        </Button>
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
      <AddAdminModal open={modalState.type === "add"} setOpen={closeModal} />
      {modalState.type === "edit" && (
        <UpdateAdminModal
          open={modalState.type === "edit"}
          setOpen={closeModal}
          data={modalState.data as TAdmin}
        />
      )}
      {modalState.type === "delete" && (
        <RCConfirmationModal
          open={modalState.type === "delete"}
          setOpen={closeModal}
          handleDelete={() => handleDelete(modalState.data?.id as number)}
        />
      )}
    </>
  );
};

export default Admins;
