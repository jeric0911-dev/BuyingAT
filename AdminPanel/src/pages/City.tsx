import { useState } from "react";
import { TCityState, TModalState } from "../types";
import {
  useDeleteCityMutation,
  useGetAllCityQuery,
} from "../redux/features/city-state/cityStateApi";
import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import dayjs from "dayjs";
import { Box, Button, IconButton, Stack } from "@mui/material";
import { DeleteRounded, EditRounded } from "@mui/icons-material";
import handleAsyncToast from "../utils/handleAsyncToast";
import HeaderTitle from "../components/seo/HeaderTitle";
import PageTitle from "../components/ui/shared/PageTitle";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import AddCityModal from "../components/ui/cityState/AddCityModal";
import UpdateCityModal from "../components/ui/cityState/UpdateCityModal";
import RCConfirmationModal from "../components/modal/RCConfirmationModal";

const City = () => {
  const [modalState, setModalState] = useState<TModalState<TCityState>>({
    type: null,
  });
  const { data, isFetching } = useGetAllCityQuery(undefined);
  const [deleteCountry] = useDeleteCityMutation();
  // const { delete: del, edit } = GetPermission("cities") as TPermissions;
  const rowsData: GridValidRowModel[] = data?.data || [];

  const columns: GridColDef<TCityState>[] = [
    {
      field: "city_name",
      headerName: "City",
      minWidth: 200,
      flex: 1,
    },
    {
      field: "country_name",
      headerName: "Country",
      renderCell: ({ row }) => row.country.country_name,
      minWidth: 150,
      flex: 1,
    },
    {
      field: "update_at",
      headerName: "Date",
      renderCell: ({ row }) => dayjs(row.updated_at).format("DD MMM YYYY"),
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

  const handleEditModal = (data: TCityState) => {
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
      promise: deleteCountry(id).unwrap(),
      success: () => {
        return "Item deleted successfully!";
      },
    });
  };
  const closeModal = () => setModalState({ type: null });

  return (
    <>
      <HeaderTitle title="Cities" />
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="Cities" />
        <Button onClick={() => setModalState({ type: "add" })}>Add City</Button>
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
      <AddCityModal open={modalState.type === "add"} setOpen={closeModal} />
      {modalState.type === "edit" && (
        <UpdateCityModal
          open={modalState.type === "edit"}
          setOpen={closeModal}
          data={modalState.data as TCityState}
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

export default City;
