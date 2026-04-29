import { useState } from "react";
import { useGetCardsQuery, useApproveCardMutation, useRejectCardMutation } from "../redux/features/cardManagement/cardManagementApi";
import HeaderTitle from "../components/seo/HeaderTitle";
import { Box, Chip, IconButton, Stack } from "@mui/material";
import PageTitle from "../components/ui/shared/PageTitle";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import { TModalState, TCard } from "../types";
import { VisibilityRounded, CheckCircle, Cancel } from "@mui/icons-material";
import CardViewModal from "../components/ui/cardManagement/CardViewModal";
import { useServerPagination } from "../hooks/useServerPagination";
import { useSearchParams } from "react-router-dom";
import { toast } from "sonner";

const CardManagement = () => {
  const [modalState, setModalState] = useState<TModalState<TCard>>({
    type: null,
  });
  const [searchParams] = useSearchParams();
  const { handlePaginationModelChange, paginationModel, queryParams } =
    useServerPagination({ defaultPageSize: 10 });
  const params: Record<string, any> = { ...queryParams };
  searchParams.get("status") && (params["status"] = searchParams.get("status"));
  
  const { data, isFetching } = useGetCardsQuery(params);
  const [approveCard] = useApproveCardMutation();
  const [rejectCard] = useRejectCardMutation();

  const rowsData: GridValidRowModel[] = data?.data || [];

  const handleApprove = async (id: number) => {
    try {
      await approveCard(id).unwrap();
      toast.success("Card approved successfully!");
    } catch (error) {
      toast.error("Failed to approve card");
    }
  };

  const handleReject = async (id: number) => {
    try {
      await rejectCard(id).unwrap();
      toast.success("Card rejected successfully!");
    } catch (error) {
      toast.error("Failed to reject card");
    }
  };

  const columns: GridColDef<TCard>[] = [
    { field: "card_title", headerName: "Title", minWidth: 150, flex: 1 },
    {
      field: "images",
      headerName: "Banner",
      renderCell: ({ row }) => (
        <Stack direction="row" alignItems="center" height="100%">
          <img
            src={`${import.meta.env.VITE_IMG_URL}/${
              row.seller_inventory?.images?.[0] || row.images?.[0]
            }`}
            alt="card"
            height={40}
            style={{ objectFit: 'cover', borderRadius: '4px' }}
          />
        </Stack>
      ),
      disableColumnMenu: true,
      sortable: false,
      minWidth: 150,
      flex: 1,
    },
    {
      field: "description",
      headerName: "Description",
      sortable: false,
      minWidth: 200,
      flex: 1,
      renderCell: ({ row }) => (
        <Box sx={{ 
          overflow: 'hidden', 
          textOverflow: 'ellipsis', 
          whiteSpace: 'nowrap',
          maxWidth: 200 
        }}>
          {row.seller_inventory?.description || row.description || 'No description'}
        </Box>
      ),
    },
    { 
      field: "price", 
      headerName: "Price", 
      minWidth: 100, 
      flex: 1,
      renderCell: ({ row }) => `$${row.seller_inventory?.price || row.price || 0}`
    },
    {
      field: "request_status",
      headerName: "Status",
      renderCell: ({ row }) => (
        <Chip
          label={row?.request_status}
          color={
            row?.request_status === "approved"
              ? "success"
              : row?.request_status === "pending"
              ? "warning"
              : row?.request_status === "rejected"
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
        <Stack direction="row" alignItems="center" height="100%" spacing={1}>
          <IconButton
            onClick={() => setModalState({ type: "view", data: row })}
            aria-label="view"
          >
            <VisibilityRounded color="primary" />
          </IconButton>
          {row.request_status === 'pending' && (
            <>
              <IconButton
                onClick={() => handleApprove(row.id)}
                aria-label="approve"
                color="success"
              >
                <CheckCircle />
              </IconButton>
              <IconButton
                onClick={() => handleReject(row.id)}
                aria-label="reject"
                color="error"
              >
                <Cancel />
              </IconButton>
            </>
          )}
        </Stack>
      ),
      minWidth: 140,
      flex: 1,
    },
  ];

  return (
    <>
      <HeaderTitle title="Card Management" />
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="Card Management" />
      </Stack>
      <Box
        mt="20px"
        border="1px solid #E0E2E7"
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
      {modalState.type === "view" && (
        <CardViewModal
          open={modalState.type === "view"}
          setOpen={() => setModalState({ type: null })}
          data={modalState.data as TCard}
        />
      )}
    </>
  );
};

export default CardManagement;
