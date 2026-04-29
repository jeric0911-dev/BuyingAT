import { useState } from "react";
import { TModalState, TPackage } from "../types";
import {
  useDeletePackageMutation,
  useGetPackagesQuery,
} from "../redux/features/package/packageApi";
import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import HeaderTitle from "../components/seo/HeaderTitle";
import { Box, Button, IconButton, Stack } from "@mui/material";
import PageTitle from "../components/ui/shared/PageTitle";
import AddPackageModal from "../components/ui/package/AddPackageModal";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import {
  DeleteRounded,
  DriveFileRenameOutlineRounded,
} from "@mui/icons-material";
import handleAsyncToast from "../utils/handleAsyncToast";
import UpdatePackageModal from "../components/ui/package/UpdatePackageModal";
import RCConfirmationModal from "../components/modal/RCConfirmationModal";

const Package = () => {
  const [modalState, setModalState] = useState<TModalState<TPackage>>({
    type: null,
  });
  const { data, isFetching } = useGetPackagesQuery(undefined);
  const [deletePackage] = useDeletePackageMutation();
  // const { delete: del, edit } = GetPermission("package") as TPermissions;

  const rowsData: GridValidRowModel[] = data?.data || [];

  const columns: GridColDef<TPackage>[] = [
    { field: "title", headerName: "Title", minWidth: 150, flex: 1 },
    { field: "price", headerName: "Price", minWidth: 150, flex: 1 },
    {
      field: "package_category",
      headerName: "Package Category",
      renderCell: ({ row }) => row.package_category.title,
      minWidth: 150,
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
      minWidth: 140,
      flex: 1,
    },
  ];

  const handleEditModal = (data: TPackage) => {
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
      promise: deletePackage(id).unwrap(),
      success: () => {
        return "Package deleted successfully!";
      },
    });
  };
  const handleClose = () => setModalState({ type: null });

  return (
    <>
      <HeaderTitle title="Package" />
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="Package" />
        <Button onClick={() => setModalState({ type: "add" })}>
          Add Package
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
      <AddPackageModal open={modalState.type === "add"} setOpen={handleClose} />
      {modalState.type === "edit" && (
        <UpdatePackageModal
          open={modalState.type === "edit"}
          setOpen={handleClose}
          data={modalState.data as TPackage}
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

export default Package;
