import { useState } from "react";
import { TCityState, TModalState } from "../types";
import {
  useDeleteStateMutation,
  useGetAllStateQuery,
} from "../redux/features/city-state/cityStateApi";
import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import dayjs from "dayjs";
import { Box, Button, IconButton, Stack } from "@mui/material";
import { DeleteRounded, EditRounded } from "@mui/icons-material";
import handleAsyncToast from "../utils/handleAsyncToast";
import HeaderTitle from "../components/seo/HeaderTitle";
import PageTitle from "../components/ui/shared/PageTitle";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import AddStateModal from "../components/ui/cityState/AddStateModal";
import UpdateStateModal from "../components/ui/cityState/UpdateStateModal";
import RCConfirmationModal from "../components/modal/RCConfirmationModal";

const State = () => {
  const [modalState, setModalState] = useState<TModalState<TCityState>>({
    type: null,
  });
  const { data, isFetching } = useGetAllStateQuery(undefined);
  const [deleteCountry] = useDeleteStateMutation();
  const rowsData: GridValidRowModel[] = data?.data || [];

  const columns: GridColDef<TCityState>[] = [
    {
      field: "state_name",
      headerName: "State",
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
    //   if (!edit) {
    //     toast.error("You don't have permission");
    //   } else {
    // }
    setModalState({ type: "edit", data });
  };
  const handleDelete = async (id: number) => {
    //   if (!del) {
    //     toast.error("You don't have permission");
    //   } else {
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
      <HeaderTitle title="States" />
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="States" />
        <Button onClick={() => setModalState({ type: "add" })}>
          Add State
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
      <AddStateModal open={modalState.type === "add"} setOpen={closeModal} />
      {modalState.type === "edit" && (
        <UpdateStateModal
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

export default State;
