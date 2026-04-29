import { useState } from "react";
import { TModalState, TPage } from "../types";
import {
  useDeletePageMutation,
  useGetAllPageQuery,
} from "../redux/features/pages/pagesApi";
import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import HeaderTitle from "../components/seo/HeaderTitle";
import { Box, Button, IconButton, Stack } from "@mui/material";
import PageTitle from "../components/ui/shared/PageTitle";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import AddPageModal from "../components/ui/pages/AddPageModal";
import ViewPageModal from "../components/ui/pages/ViewPageModal";
import UpdatePageModal from "../components/ui/pages/UpdatePageModal";
import dayjs from "dayjs";
import {
  DeleteRounded,
  EditRounded,
  VisibilityRounded,
} from "@mui/icons-material";
import handleAsyncToast from "../utils/handleAsyncToast";
import RCConfirmationModal from "../components/modal/RCConfirmationModal";

const Pages = () => {
  const [modalState, setModalState] = useState<TModalState<TPage>>({
    type: null,
  });
  const { data, isFetching } = useGetAllPageQuery(undefined);
  const [deletePage] = useDeletePageMutation();
  // const { delete: del, edit } = GetPermission("pages") as TPermissions;

  const rowsData: GridValidRowModel[] = data?.data || [];

  const columns: GridColDef<TPage>[] = [
    {
      field: "title",
      headerName: "Title",
      minWidth: 150,
      flex: 1,
    },
    {
      field: "slug",
      headerName: "Slug",
      minWidth: 150,
      flex: 1,
    },
    {
      field: "updatedAt",
      headerName: "Date",
      renderCell: ({ row }) => dayjs(row.updated_at).format("D MMM YYYY"),
      minWidth: 150,
      flex: 1,
    },
    {
      field: "action",
      headerName: "Action",
      renderCell: ({ row }) => (
        <Stack direction="row" alignItems="center" height="100%">
          <IconButton
            onClick={() => setModalState({ type: "view", data: row })}
            aria-label="view"
          >
            <VisibilityRounded color="primary" />
          </IconButton>
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

  const handleEditModal = (data: TPage) => {
    // if (!edit) {
    //   toast.error("You don't have permission");
    // } else {
    // }
    setModalState({ type: "edit", data });
  };
  const handleDelete = async (id: number) => {
    // if (!del) {
    //   toast.error("You don't have permission");
    // } else {
    // }
    await handleAsyncToast({
      promise: deletePage(id).unwrap(),
      success: () => {
        return "Page deleted successfully!";
      },
    });
  };
  const closeModal = () => setModalState({ type: null });

  return (
    <>
      <HeaderTitle title="Pages" />
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="Pages" />
        <Button onClick={() => setModalState({ type: "add" })}>Add Page</Button>
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
      <AddPageModal open={modalState.type === "add"} setOpen={closeModal} />
      {modalState.type === "view" && (
        <ViewPageModal
          open={modalState.type === "view"}
          setOpen={closeModal}
          data={modalState.data as TPage}
        />
      )}
      {modalState.type === "edit" && (
        <UpdatePageModal
          open={modalState.type === "edit"}
          setOpen={closeModal}
          data={modalState.data as TPage}
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

export default Pages;
