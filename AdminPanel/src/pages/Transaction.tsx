import { Box, Chip, Stack, Typography } from "@mui/material";
import HeaderTitle from "../components/seo/HeaderTitle";
import PageTitle from "../components/ui/shared/PageTitle";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import { useGetTransactionsQuery } from "../redux/features/transaction/transactionApi";
import { useNavigate, useSearchParams } from "react-router-dom";
import { useServerPagination } from "../hooks/useServerPagination";
import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import { TTransaction } from "../types";
import dayjs from "dayjs";
import relativeTime from "dayjs/plugin/relativeTime";
dayjs.extend(relativeTime);

const Transaction = () => {
  const [searchParams] = useSearchParams();
  const { handlePaginationModelChange, paginationModel, queryParams } =
    useServerPagination({ defaultPageSize: 10 });
  const params: Record<string, any> = { ...queryParams };
  searchParams.get("status") && (params["status"] = searchParams.get("status"));
  const { data, isFetching } = useGetTransactionsQuery(params);
  const router = useNavigate();

  const rowsData: GridValidRowModel[] = data?.data || [];
  const columns: GridColDef<TTransaction>[] = [
    {
      field: "transaction_id",
      headerName: "Gateway|Transaction",
      renderCell: ({ row }) => (
        <Stack justifyContent="center" height="100%">
          <Typography variant="body2">{row.payment_method}</Typography>
          <Typography variant="caption">{row.transaction_id}</Typography>
        </Stack>
      ),
      minWidth: 150,
      flex: 1,
    },
    {
      field: "initiated",
      headerName: "Initiated",
      renderCell: ({ row }) => (
        <Stack justifyContent="center" height="100%">
          <Typography variant="body2">{row.initiated}</Typography>
          <Typography variant="caption">
            {dayjs(row?.initiated).fromNow()}
          </Typography>
        </Stack>
      ),
      minWidth: 150,
      flex: 1,
    },
    {
      field: "user",
      headerName: "User",
      renderCell: ({ row }) => (
        <Stack
          onClick={() => handleRoute(row)}
          justifyContent="center"
          height="100%"
          sx={{ cursor: "pointer" }}
        >
          <Typography variant="body2">{row.user?.name}</Typography>
          <Typography variant="caption">{row.user?.email}</Typography>
        </Stack>
      ),
      minWidth: 200,
      flex: 1,
    },
    {
      field: "credits",
      headerName: "Credits",
      renderCell: ({ row }) => `${row.credits ?? 0} credit`,
      minWidth: 150,
      flex: 1,
    },
    {
      field: "conversion",
      headerName: "Conversion",
      renderCell: ({ row }) => (
        <Stack justifyContent="center" height="100%">
          <Typography variant="body2">{row.conversion}</Typography>
          <Typography variant="caption">{`${row.amount}${row.currency}`}</Typography>
        </Stack>
      ),
      minWidth: 200,
      flex: 1,
    },
    {
      field: "status",
      headerName: "Status",
      renderCell: ({ row }) => (
        <Chip
          label={row.status?.charAt(0).toUpperCase() + row.status?.slice(1)}
          color={
            row?.status === "success"
              ? "success"
              : row?.status === "pending"
              ? "warning"
              : row?.status === "cancelled"
              ? "error"
              : "default"
          }
          variant="outlined"
        />
      ),
      minWidth: 100,
      flex: 1,
    },
  ];

  const handleRoute = (data: TTransaction) => {
    if (data.user.user_type === "vendor") {
      router(`/shop-management/${data.user_id}`);
    } else {
      router(`/user-management/${data.user_id}`);
    }
  };

  return (
    <>
      <HeaderTitle title="Transaction History" />
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="Transaction History" />
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
    </>
  );
};

export default Transaction;
