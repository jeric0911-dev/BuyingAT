import { useState } from "react";
import {
  useDeleteReportMutation,
  useGetReportsQuery,
} from "../redux/features/others/othersApi";
import { TModalState, TProduct, TReport } from "../types";
import handleAsyncToast from "../utils/handleAsyncToast";
import HeaderTitle from "../components/seo/HeaderTitle";
import { Box, IconButton, Stack } from "@mui/material";
import PageTitle from "../components/ui/shared/PageTitle";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import { DeleteRounded, VisibilityRounded } from "@mui/icons-material";
import RCConfirmationModal from "../components/modal/RCConfirmationModal";
import ProductViewModal from "../components/ui/productManagement/ProductViewModal";
import { useServerPagination } from "../hooks/useServerPagination";
import { Link } from "react-router-dom";

const Reports = () => {
  const [modalState, setModalState] = useState<TModalState<TReport>>({
    type: null,
  });
  const { handlePaginationModelChange, paginationModel, queryParams } =
    useServerPagination({ defaultPageSize: 10 });
  const { data, isFetching } = useGetReportsQuery(queryParams);
  const [delReport] = useDeleteReportMutation();
  const rowsData: GridValidRowModel[] = data?.data || [];

  const columns: GridColDef<TReport>[] = [
    {
      field: "user",
      headerName: "Reported By",
      renderCell: ({ row }) => (
        <Link
          to={
            row.user.user_type === "vendor"
              ? `/shop-management/${row.user.id}`
              : `/user-management/${row.user.id}`
          }
        >
          {row.user.name}
        </Link>
      ),
      minWidth: 200,
      flex: 1,
    },
    { field: "title", headerName: "Report Reason", minWidth: 200, flex: 1 },
    { field: "description", headerName: "Description", minWidth: 200, flex: 1 },
    {
      field: "action",
      headerName: "Action",
      renderCell: ({ row }) => (
        <Stack direction="row" alignItems="center" height="100%">
          <IconButton
            onClick={() => setModalState({ type: "view", data: row })}
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

  const handleDelete = async (id: number) => {
    handleAsyncToast({
      promise: delReport(id).unwrap(),
      success: () => "Report deleted successfully!",
    });
  };

  return (
    <>
      <HeaderTitle title="Report" />
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="Report" />
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
        <ProductViewModal
          open={modalState.type === "view"}
          setOpen={() => setModalState({ type: null })}
          data={modalState.data?.product as TProduct}
        />
      )}
      {modalState.type === "delete" && (
        <RCConfirmationModal
          open={modalState.type === "delete"}
          setOpen={() => setModalState({ type: null })}
          handleDelete={() => handleDelete(modalState.data?.id as number)}
        />
      )}
    </>
  );
};

export default Reports;
