import { useState } from "react";
import { Box, Button, Chip, CircularProgress, Paper, Stack, Typography } from "@mui/material";
import { DataGrid, GridColDef } from "@mui/x-data-grid";
import { 
  useGetBuyerRequestsQuery, 
  useApproveBuyerRequestMutation, 
  useRejectBuyerRequestMutation 
} from "../redux/features/buyerApproval/buyerApprovalApi";

const formatDateTime = (value?: string | null) => {
  if (!value) return "-";
  try {
    const d = new Date(value);
    if (Number.isNaN(d.getTime())) return value;
    return `${d.toLocaleDateString()} ${d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}`;
  } catch {
    return value as string;
  }
};

const BuyerApprovals = () => {
  const [actionLoadingId, setActionLoadingId] = useState<number | null>(null);

  // Use RTK Query hooks
  const { data: requestsData, isLoading } = useGetBuyerRequestsQuery({});
  const [approveRequest] = useApproveBuyerRequestMutation();
  const [rejectRequest] = useRejectBuyerRequestMutation();

  const rows = requestsData?.data || [];

  const handleAction = async (id: number, action: "approve" | "reject") => {
    try {
      setActionLoadingId(id);
      if (action === "approve") {
        await approveRequest(id).unwrap();
      } else {
        await rejectRequest(id).unwrap();
      }
      // RTK Query will automatically refetch due to invalidatesTags
    } catch (e) {
      console.error(`Failed to ${action} request`, e);
    } finally {
      setActionLoadingId(null);
    }
  };

  const columns: GridColDef[] = [
    { field: "id", headerName: "ID", width: 70 },
    { field: "user_id", headerName: "User ID", width: 100 },
    {
      field: "name",
      headerName: "User",
      flex: 1,
      valueGetter: (_, row) => row?.user?.name || "-",
    },
    {
      field: "email",
      headerName: "Email",
      flex: 1,
      valueGetter: (_, row) => row?.user?.email || "-",
    },
    {
      field: "username",
      headerName: "Username",
      flex: 1,
      valueGetter: (_, row) => row?.user?.profile?.username || "-",
    },
    {
      field: "requested_at",
      headerName: "Requested",
      width: 180,
      valueGetter: (_, row) => formatDateTime(row?.requested_at),
    },
    {
      field: "approved_at",
      headerName: "Approved",
      width: 180,
      valueGetter: (_, row) => formatDateTime(row?.approved_at),
    },
    {
      field: "created_at",
      headerName: "Created",
      width: 180,
      valueGetter: (_, row) => formatDateTime(row?.created_at),
    },
    {
      field: "request_status",
      headerName: "Status",
      width: 140,
      renderCell: (params) => (
        <Chip
          size="small"
          label={params.value}
          color={params.value === "pending" ? "warning" : params.value === "approved" ? "success" : "default"}
          variant="outlined"
        />
      ),
    },
    {
      field: "actions",
      headerName: "Actions",
      width: 220,
      sortable: false,
      renderCell: (params) => (
        <Stack direction="row" spacing={1} alignItems="center">
          <Button
            variant="contained"
            color="success"
            size="small"
            disabled={actionLoadingId === params.row.id}
            onClick={() => handleAction(params.row.id, "approve")}
          >
            {actionLoadingId === params.row.id ? <CircularProgress size={16} /> : "Approve"}
          </Button>
          <Button
            variant="contained"
            color="error"
            size="small"
            disabled={actionLoadingId === params.row.id}
            onClick={() => handleAction(params.row.id, "reject")}
          >
            {actionLoadingId === params.row.id ? <CircularProgress size={16} /> : "Reject"}
          </Button>
        </Stack>
      ),
    },
  ];

  return (
    <Box>
      <Typography variant="h5" mb={2} fontWeight={700}>
        Buyer Approvals
      </Typography>
      <Paper sx={{ p: 2 }}>
        <div style={{ height: 520, width: "100%" }}>
          <DataGrid
            rows={rows}
            columns={columns}
            loading={isLoading}
            disableRowSelectionOnClick
            getRowId={(row) => row.id}
          />
        </div>
      </Paper>
    </Box>
  );
};

export default BuyerApprovals;


