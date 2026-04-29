import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import { TCategory, TModalState, TPermissions } from "../types";
import { Box, Button, IconButton, Stack } from "@mui/material";
import {
  DeleteRounded,
  DriveFileRenameOutlineRounded,
} from "@mui/icons-material";
import handleAsyncToast from "../utils/handleAsyncToast";
import { useState } from "react";
import PageTitle from "../components/ui/shared/PageTitle";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import AddCategoryModal from "../components/ui/category/AddCategoryModal";
import UpdateCategoryModal from "../components/ui/category/UpdateCategoryModal";
import {
  useDeleteCategoryMutation,
  useGetAllCategoryQuery,
} from "../redux/features/category/categoryApi";
import RCConfirmationModal from "../components/modal/RCConfirmationModal";
import GetPermission from "../utils/getPermission";
import { toast } from "sonner";

const Category = () => {
  const [modalState, setModalState] = useState<TModalState<TCategory>>({
    type: null,
  });
  const { data, isFetching } = useGetAllCategoryQuery(undefined);
  const [deleteCategory] = useDeleteCategoryMutation();
  const rowsData: GridValidRowModel[] = data?.data || [];
  const { delete: del, edit } = GetPermission("category") as TPermissions;

  const columns: GridColDef<TCategory>[] = [
    {
      field: "category_name",
      headerName: "Name",
      minWidth: 200,
      flex: 1,
    },
    {
      field: "icon",
      headerName: "Icon",
      renderCell: ({ row }) => (
        <Stack direction="row" alignItems="center" height="100%">
          <img
            src={`${import.meta.env.VITE_IMG_URL}/${row.icon}`}
            alt="icon"
            style={{ maxHeight: 40 }}
          />
        </Stack>
      ),
      minWidth: 100,
      flex: 1,
    },
    {
      field: "banner",
      headerName: "Icon",
      renderCell: ({ row }) => (
        <Stack direction="row" alignItems="center" height="100%">
          <img
            src={`${import.meta.env.VITE_IMG_URL}/${row.banner}`}
            alt="icon"
            style={{ maxHeight: 40 }}
          />
        </Stack>
      ),
      minWidth: 100,
      flex: 1,
    },
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
          <IconButton onClick={() => handleEditModal(row)} aria-label="view">
            <DriveFileRenameOutlineRounded color="success" />
          </IconButton>
          <IconButton
            onClick={() => setModalState({ type: "delete", data: row })}
            aria-label="view"
          >
            <DeleteRounded color="error" />
          </IconButton>
        </Stack>
      ),
      minWidth: 140,
      flex: 1,
    },
  ];

  const handleEditModal = (data: TCategory) => {
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
        promise: deleteCategory(id).unwrap(),
        success: () => {
          return "Category deleted successfully!";
        },
      });
    }
  };
  const closeModal = () => setModalState({ type: null });

  return (
    <>
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="Category" />
        <Button onClick={() => setModalState({ type: "add" })}>
          Add Category
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
      <AddCategoryModal open={modalState.type === "add"} setOpen={closeModal} />
      {modalState.type === "edit" && (
        <UpdateCategoryModal
          open={modalState.type === "edit"}
          setOpen={closeModal}
          data={modalState.data as TCategory}
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

export default Category;
