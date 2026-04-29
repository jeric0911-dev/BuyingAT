import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import { useState } from "react";
import { TModalState, TSocial } from "../types";
import { Box, Button, IconButton, Stack } from "@mui/material";
import { DeleteRounded, EditRounded } from "@mui/icons-material";
import handleAsyncToast from "../utils/handleAsyncToast";
import HeaderTitle from "../components/seo/HeaderTitle";
import PageTitle from "../components/ui/shared/PageTitle";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import AddSocialModal from "../components/ui/social/AddSocialModal";
import UpdateSocialModal from "../components/ui/social/UpdateSocialModal";
import {
  useDeleteSocialMutation,
  useGetAllSocialQuery,
} from "../redux/features/social/socialApi";
import RCConfirmationModal from "../components/modal/RCConfirmationModal";

const Social = () => {
  const [modalState, setModalState] = useState<TModalState<TSocial>>({
    type: null,
  });
  const { data, isFetching } = useGetAllSocialQuery(undefined);
  const [deleteSocial] = useDeleteSocialMutation();
  const rowsData: GridValidRowModel[] = data?.data || [];
  // const { delete: del, edit } = GetPermission("social") as TPermissions;

  const columns: GridColDef<TSocial>[] = [
    // {
    //   field: "title",
    //   headerName: "Title",
    //   minWidth: 200,
    //   flex: 1,
    // },
    {
      field: "icon",
      headerName: "Icon",
      renderCell: ({ row }) => (
        <Stack direction="row" alignItems="center" height="100%">
          <img
            src={`${import.meta.env.VITE_IMG_URL}/${row.icon}`}
            alt="icon"
            width={40}
            height={40}
          />
        </Stack>
      ),
      minWidth: 100,
      flex: 1,
    },
    {
      field: "link",
      headerName: "Link",
      minWidth: 150,
      flex: 1,
    },
    {
      field: "action",
      headerName: "Action",
      renderCell: ({ row }) => (
        <Stack direction="row" alignItems="center" height="100%">
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
      minWidth: 140,
      flex: 1,
    },
  ];

  const handleEditModal = (data: TSocial) => {
    // if (!edit) {
    //   toast.error("You don't have permission");
    // } else {
    setModalState({ type: "edit", data });
    // }
  };
  const handleDelete = async (id: number) => {
    // if (!del) {
    //   toast.error("You don't have permission");
    // } else {
    handleAsyncToast({
      promise: deleteSocial(id).unwrap(),
      success: () => {
        return "Item deleted successfully!";
      },
    });
    // }
  };
  const closeModal = () => setModalState({ type: null });

  return (
    <>
      <HeaderTitle title="Social" />
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="Socials" />
        <Button onClick={() => setModalState({ type: "add" })}>
          Add Social
        </Button>
      </Stack>
      <Box
        mt="20px"
        border="1px solid #E0E2E7"
        borderRadius={2}
        bgcolor="white"
        overflow="hidden"
      >
        <MyDataGrid rows={rowsData} columns={columns} loading={isFetching} />
      </Box>
      <AddSocialModal open={modalState.type === "add"} setOpen={closeModal} />
      {modalState.type === "edit" && (
        <UpdateSocialModal
          open={modalState.type === "edit"}
          setOpen={closeModal}
          data={modalState.data as TSocial}
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

export default Social;
