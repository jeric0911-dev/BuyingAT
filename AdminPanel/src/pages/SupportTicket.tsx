import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import {
  useDeleteTicketMutation,
  useGetSupportTicketsQuery,
} from "../redux/features/supportTicket/supportTicketApi";
import { TModalState, TSupportTicket } from "../types";
import HeaderTitle from "../components/seo/HeaderTitle";
import { Box, Chip, IconButton, Stack } from "@mui/material";
import PageTitle from "../components/ui/shared/PageTitle";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import { useNavigate, useSearchParams } from "react-router-dom";
import { DeleteRounded, VisibilityRounded } from "@mui/icons-material";
import handleAsyncToast from "../utils/handleAsyncToast";
import { useState } from "react";
import RCConfirmationModal from "../components/modal/RCConfirmationModal";

const SupportTicket = () => {
  const [modalState, setModalState] = useState<TModalState<TSupportTicket>>({
    type: null,
  });
  const [searchParams] = useSearchParams();
  const params: Record<string, any> = {};
  searchParams.get("status") && (params["status"] = searchParams.get("status"));
  const { data, isFetching } = useGetSupportTicketsQuery(params);
  const [deleteTicket] = useDeleteTicketMutation();
  const router = useNavigate();
  const rowsData: GridValidRowModel[] = data?.data || [];

  const columns: GridColDef<TSupportTicket>[] = [
    {
      field: "subject",
      headerName: "Subject",
      minWidth: 200,
      flex: 1,
    },
    {
      field: "priority",
      headerName: "Priority",
      renderCell: ({ value }) => (
        <Chip
          label={value?.charAt(0).toUpperCase() + value?.slice(1)}
          color={
            value === "low"
              ? "success"
              : value === "medium"
              ? "warning"
              : value === "high"
              ? "error"
              : "default"
          }
          variant="outlined"
        />
      ),
      minWidth: 150,
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
      renderCell: ({ row }) => (
        <Stack direction="row" alignItems="center" height="100%">
          <IconButton
            onClick={() => router(`/support-ticket/${row.id}`)}
            aria-label="view"
          >
            <VisibilityRounded color="primary" />
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

  const handleDeleteTicket = async (id: number) => {
    handleAsyncToast({
      promise: deleteTicket(id).unwrap(),
      success: () => "Ticket deleted successfully",
    });
  };

  return (
    <>
      <HeaderTitle title="Support Ticket" />
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="Support Ticket" />
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
      <RCConfirmationModal
        open={modalState.type === "delete"}
        setOpen={() => setModalState({ type: null })}
        handleDelete={() => handleDeleteTicket(modalState.data?.id as number)}
      />
    </>
  );
};

export default SupportTicket;
