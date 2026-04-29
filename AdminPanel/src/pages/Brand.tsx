import { useState } from "react";
import { TBrand, TModalState, TPermissions } from "../types";
import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import { Box, Button, IconButton, Stack } from "@mui/material";
import { DeleteRounded, EditRounded } from "@mui/icons-material";
import handleAsyncToast from "../utils/handleAsyncToast";
import HeaderTitle from "../components/seo/HeaderTitle";
import PageTitle from "../components/ui/shared/PageTitle";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import UpdateBrandModal from "../components/ui/brand/UpdateBrandModal";
import RCConfirmationModal from "../components/modal/RCConfirmationModal";
import {
  useDeleteBrandMutation,
  useGetAllBrandQuery,
} from "../redux/features/brand/brandApi";
import AddBrandModal from "../components/ui/brand/AddBrandModal";
import GetPermission from "../utils/getPermission";
import { toast } from "sonner";

const Brand = () => {
  const [modalState, setModalState] = useState<TModalState<TBrand>>({
    type: null,
  });
  const { data, isFetching } = useGetAllBrandQuery(undefined);
  const [deleteBrand] = useDeleteBrandMutation();
  const { delete: del, edit } = GetPermission("brand") as TPermissions;
  const rowsData: GridValidRowModel[] = data?.data || [];

  const columns: GridColDef<TBrand>[] = [
    {
      field: "brand_name",
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

  const handleEditModal = (data: TBrand) => {
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
        promise: deleteBrand(id).unwrap(),
        success: () => {
          return "Item deleted successfully!";
        },
      });
    }
  };
  const closeModal = () => setModalState({ type: null });

  return (
    <>
      <HeaderTitle title="Brand" />
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="Brand" />
        <Button onClick={() => setModalState({ type: "add" })}>
          Add Brand
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
      <AddBrandModal open={modalState.type === "add"} setOpen={closeModal} />
      {modalState.type === "edit" && (
        <UpdateBrandModal
          open={modalState.type === "edit"}
          setOpen={closeModal}
          data={modalState.data as TBrand}
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

export default Brand;
