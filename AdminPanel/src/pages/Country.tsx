import { useState } from "react";
import { TCountry, TModalState, TPermissions } from "../types";
import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import { Box, Button, IconButton, Stack } from "@mui/material";
import { DeleteRounded, EditRounded } from "@mui/icons-material";
import handleAsyncToast from "../utils/handleAsyncToast";
import HeaderTitle from "../components/seo/HeaderTitle";
import PageTitle from "../components/ui/shared/PageTitle";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import AddCountryModal from "../components/ui/country/AddCountryModal";
import UpdateCountryModal from "../components/ui/country/UpdateOtherStakeModal";
import RCConfirmationModal from "../components/modal/RCConfirmationModal";
import {
  useDeleteCountryMutation,
  useGetAllCountryQuery,
} from "../redux/features/country/countryApi";
import dayjs from "dayjs";
import GetPermission from "../utils/getPermission";
import { toast } from "sonner";

const Country = () => {
  const [modalState, setModalState] = useState<TModalState<TCountry>>({
    type: null,
  });
  const { data, isFetching } = useGetAllCountryQuery(undefined);
  const [deleteCountry] = useDeleteCountryMutation();
  const { delete: del, edit } = GetPermission("countries") as TPermissions;
  const rowsData: GridValidRowModel[] = data?.data || [];

  const columns: GridColDef<TCountry>[] = [
    {
      field: "country_name",
      headerName: "Country",
      minWidth: 200,
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

  const handleEditModal = (data: TCountry) => {
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
        promise: deleteCountry(id).unwrap(),
        success: () => {
          return "Item deleted successfully!";
        },
      });
    }
  };
  const closeModal = () => setModalState({ type: null });

  return (
    <>
      <HeaderTitle title="Countries" />
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="Countries" />
        <Button onClick={() => setModalState({ type: "add" })}>
          Add Country
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
      <AddCountryModal open={modalState.type === "add"} setOpen={closeModal} />
      {modalState.type === "edit" && (
        <UpdateCountryModal
          open={modalState.type === "edit"}
          setOpen={closeModal}
          data={modalState.data as TCountry}
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

export default Country;
