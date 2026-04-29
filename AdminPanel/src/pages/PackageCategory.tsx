import { useState } from "react";
import { TModalState, TPackageCategory } from "../types";
import {
  useDeletePackageCategoryMutation,
  useGetPackageCategoriesQuery,
} from "../redux/features/packageCategory/packageCategoryApi";
import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import { Box, Button, Chip, IconButton, Stack } from "@mui/material";
import {
  DeleteRounded,
  DriveFileRenameOutlineRounded,
} from "@mui/icons-material";
import handleAsyncToast from "../utils/handleAsyncToast";
import HeaderTitle from "../components/seo/HeaderTitle";
import PageTitle from "../components/ui/shared/PageTitle";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import RCConfirmationModal from "../components/modal/RCConfirmationModal";
import PCAddModal from "../components/ui/packageCategory/PCAddModal";
import PCUpdateModal from "../components/ui/packageCategory/PCUpdateModal";

const PackageCategory = () => {
  const [modalState, setModalState] = useState<TModalState<TPackageCategory>>({
    type: null,
  });
  const { data, isFetching } = useGetPackageCategoriesQuery(undefined);
  const [deleteCat] = useDeletePackageCategoryMutation();
  const rowsData: GridValidRowModel[] = data?.data || [];

  const columns: GridColDef<TPackageCategory>[] = [
    { field: "title", headerName: "Title", flex: 1, minWidth: 200 },
    { field: "duration", headerName: "Duration", flex: 1, minWidth: 200 },
    {
      field: "status",
      headerName: "Status",
      renderCell: ({ row }) => (
        <Chip
          label={row.status === 1 ? "Active" : "Inactive"}
          color={
            row?.status === 1
              ? "success"
              : row?.status === 0
              ? "error"
              : "default"
          }
          variant="outlined"
        />
      ),
      minWidth: 100,
      flex: 1,
    },
    {
      field: "action",
      headerName: "Action",
      renderCell: ({ row }) => (
        <Stack direction="row" alignItems="center" height="100%">
          <IconButton onClick={() => handleEditModal(row)}>
            <DriveFileRenameOutlineRounded color="success" />
          </IconButton>
          <IconButton
            onClick={() => setModalState({ type: "delete", data: row })}
          >
            <DeleteRounded color="error" />
          </IconButton>
        </Stack>
      ),
      flex: 1,
      minWidth: 100,
    },
  ];

  const handleEditModal = (data: TPackageCategory) => {
    setModalState({ type: "edit", data });
  };
  const handleDelete = async (id: number) => {
    handleAsyncToast({
      promise: deleteCat(id).unwrap(),
      success: () => "Package category deleted successfully!",
    });
  };
  const handleClose = () => setModalState({ type: null });

  return (
    <>
      <HeaderTitle title="Package Category" />
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="Package Category" />
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
      <PCAddModal open={modalState.type === "add"} setOpen={handleClose} />
      {modalState.type === "edit" && (
        <PCUpdateModal
          open={modalState.type === "edit"}
          setOpen={handleClose}
          data={modalState.data as TPackageCategory}
        />
      )}
      {modalState.type === "delete" && (
        <RCConfirmationModal
          open={modalState.type === "delete"}
          setOpen={handleClose}
          handleDelete={() => handleDelete(modalState.data!.id)}
        />
      )}
    </>
  );
};

export default PackageCategory;
