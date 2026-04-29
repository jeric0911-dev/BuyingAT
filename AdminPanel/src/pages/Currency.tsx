import { useState } from "react";
import { TCurrency, TModalState, TPermissions } from "../types";
import {
  useDeleteCurrencyMutation,
  useGetCurrenciesQuery,
} from "../redux/features/currency/currencyApi";
import { GridColDef } from "@mui/x-data-grid";
import { Box, Button, Chip, IconButton, Stack } from "@mui/material";
import {
  DeleteRounded,
  DriveFileRenameOutlineRounded,
} from "@mui/icons-material";
import handleAsyncToast from "../utils/handleAsyncToast";
import { toast } from "sonner";
import GetPermission from "../utils/getPermission";
import PageTitle from "../components/ui/shared/PageTitle";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import RCConfirmationModal from "../components/modal/RCConfirmationModal";
import AddCurrencyModal from "../components/ui/currency/AddCurrencyModal";
import UpdateCurrencyModal from "../components/ui/currency/UpdateCurrencyModal";

const Currency = () => {
  const [modalState, setModalState] = useState<TModalState<TCurrency>>({
    type: null,
  });
  const { data, isFetching } = useGetCurrenciesQuery(undefined);
  const [deleteCurrency] = useDeleteCurrencyMutation();
  const { delete: del, edit } = GetPermission("currency") as TPermissions;

  const rowsData: TCurrency[] = data?.data || [];
  const columns: GridColDef<TCurrency>[] = [
    {
      field: "currency_code",
      headerName: "Currency",
      minWidth: 150,
      flex: 1,
    },
    {
      field: "value",
      headerName: "USD To Rate",
      minWidth: 100,
      flex: 1,
    },
    {
      field: "currency_symbol",
      headerName: "Symbol",
      minWidth: 100,
      flex: 1,
    },
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

  const handleEditModal = (data: TCurrency) => {
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
        promise: deleteCurrency(id).unwrap(),
        success: () => {
          return "Currency deleted successfully!";
        },
      });
    }
  };
  const closeModal = () => setModalState({ type: null });

  return (
    <>
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="Currency" />
        <Button onClick={() => setModalState({ type: "add" })}>
          Add Currency
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
      <AddCurrencyModal open={modalState.type === "add"} setOpen={closeModal} />
      {modalState.type === "edit" && (
        <UpdateCurrencyModal
          open={modalState.type === "edit"}
          setOpen={closeModal}
          data={modalState.data as TCurrency}
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

export default Currency;
