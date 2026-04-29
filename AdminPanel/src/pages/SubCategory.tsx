import { Box, Button, IconButton, Stack } from "@mui/material";
import PageTitle from "../components/ui/shared/PageTitle";
import { useState } from "react";
// import GetPermission from "../utils/getPermission";
import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import {
  DeleteRounded,
  DriveFileRenameOutlineRounded,
} from "@mui/icons-material";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import { TModalState, TSubCategory } from "../types";
import {
  useDeleteSubCategoryMutation,
  useGetAllSubCategoryQuery,
} from "../redux/features/subCategory/subCategoryApi";
import UpdateSubCategoryModal from "../components/ui/subCategory/UpdateSubCategoryModal";
import RCConfirmationModal from "../components/modal/RCConfirmationModal";
import handleAsyncToast from "../utils/handleAsyncToast";
import AddSubCategoryModal from "../components/ui/subCategory/AddSubCategoryModal";

const SubCategory = () => {
  const [modalState, setModalState] = useState<TModalState<TSubCategory>>({
    type: null,
  });
  const [deleteSubCategory] = useDeleteSubCategoryMutation();
  // const { delete: del, edit } = GetPermission("level") as TPermissions;

  const { data, isFetching } = useGetAllSubCategoryQuery(undefined);
  const rowsData: GridValidRowModel[] = data?.data || [];

  const columns: GridColDef<TSubCategory>[] = [
    {
      field: "sub_category_name",
      headerName: "Name",
      minWidth: 150,
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
            style={{ height: 40 }}
          />
        </Stack>
      ),
      minWidth: 100,
      flex: 1,
    },
    {
      field: "banner",
      headerName: "Banner",
      renderCell: ({ row }) => (
        <Stack direction="row" alignItems="center" height="100%">
          <img
            src={`${import.meta.env.VITE_IMG_URL}/${row.banner}`}
            alt="icon"
            style={{ height: 40 }}
          />
        </Stack>
      ),
      minWidth: 100,
      flex: 1,
    },
    {
      field: "category_name",
      headerName: "Category Name",
      renderCell: ({ row }) => row.category.category_name,
      minWidth: 150,
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
          <IconButton onClick={() => handleUpdate(row)} aria-label="view">
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

  const handleUpdate = (data: TSubCategory) => {
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
    handleAsyncToast({
      promise: deleteSubCategory(id).unwrap(),
      success: () => {
        return "Item deleted successfully!";
      },
    });
  };
  const closeModal = () => setModalState({ type: null });

  return (
    <>
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="Sub Category" />
        <Button onClick={() => setModalState({ type: "add" })}>
          Add Sub Category
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

      <AddSubCategoryModal
        open={modalState.type === "add"}
        setOpen={closeModal}
      />
      {modalState.type === "edit" && (
        <UpdateSubCategoryModal
          open={modalState.type === "edit"}
          setOpen={closeModal}
          data={modalState.data as TSubCategory}
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

export default SubCategory;
