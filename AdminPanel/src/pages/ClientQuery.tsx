import { useState } from "react";
import { Box, IconButton, Stack } from "@mui/material";
import HeaderTitle from "../components/seo/HeaderTitle";
import PageTitle from "../components/ui/shared/PageTitle";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import { TClientQuery, TModalState, TPermissions } from "../types";
import {
  useDeleteClientQueryMutation,
  useGetAllClientQueryQuery,
} from "../redux/features/clientQuery/clientQueryApi";
import { DeleteRounded } from "@mui/icons-material";
import handleAsyncToast from "../utils/handleAsyncToast";
import RCConfirmationModal from "../components/modal/RCConfirmationModal";
import { useServerPagination } from "../hooks/useServerPagination";
import GetPermission from "../utils/getPermission";
import { toast } from "sonner";

const ClientQuery = () => {
  const [modalState, setModalState] = useState<TModalState<TClientQuery>>({
    type: null,
  });
  const { handlePaginationModelChange, paginationModel, queryParams } =
    useServerPagination({ defaultPageSize: 10 });
  const { data, isFetching } = useGetAllClientQueryQuery(queryParams);
  const [deleteQuery] = useDeleteClientQueryMutation();
  const { delete: del } = GetPermission("client-query") as TPermissions;

  const rowsData: GridValidRowModel[] = data?.data || [];

  const columns: GridColDef<TClientQuery>[] = [
    {
      field: "name",
      headerName: "Name",
      minWidth: 150,
      flex: 1,
    },
    {
      field: "email",
      headerName: "Email",
      minWidth: 150,
      flex: 1,
    },
    {
      field: "message",
      headerName: "Message",
      minWidth: 250,
      flex: 1,
    },
    {
      field: "action",
      headerName: "Action",
      renderCell: ({ row }) => (
        <Stack direction="row" alignItems="center" height="100%">
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

  const handleDelete = async (id: number) => {
    if (!del) {
      toast.error("You don't have permission");
    } else {
      handleAsyncToast({
        promise: deleteQuery(id).unwrap(),
        success: () => {
          return "Item deleted successfully!";
        },
      });
    }
  };
  const closeModal = () => setModalState({ type: null });

  return (
    <>
      <HeaderTitle title="Client Query" />
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="Client Query" />
      </Stack>
      <Box
        mt="20px"
        sx={{ border: "1px solid #E0E2E7" }}
        borderRadius={2}
        bgcolor="white"
        overflow="hidden"
      >
        <MyDataGrid
          rows={rowsData}
          columns={columns}
          loading={isFetching}
          paginationMode="server"
          paginationModel={paginationModel}
          onPaginationModelChange={handlePaginationModelChange}
          rowCount={data?.pagination?.total}
        />
      </Box>

      <RCConfirmationModal
        open={modalState.type === "delete"}
        setOpen={closeModal}
        handleDelete={() => handleDelete(modalState.data?.id as number)}
      />
    </>
  );
};

export default ClientQuery;
