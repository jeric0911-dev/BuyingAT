import { useState } from "react";
import { useGetProductsQuery } from "../redux/features/productManagement/productManagementApi";
import HeaderTitle from "../components/seo/HeaderTitle";
import { Box, Chip, IconButton, Stack } from "@mui/material";
import PageTitle from "../components/ui/shared/PageTitle";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import { TModalState, TProduct } from "../types";
import { VisibilityRounded } from "@mui/icons-material";
import ProductViewModal from "../components/ui/productManagement/ProductViewModal";
import { useServerPagination } from "../hooks/useServerPagination";
import { useSearchParams } from "react-router-dom";

const ProductManagement = () => {
  const [modalState, setModalState] = useState<TModalState<TProduct>>({
    type: null,
  });
  const [searchParams] = useSearchParams();
  const { handlePaginationModelChange, paginationModel, queryParams } =
    useServerPagination({ defaultPageSize: 10 });
  const params: Record<string, any> = { ...queryParams };
  searchParams.get("status") && (params["status"] = searchParams.get("status"));
  const { data, isFetching } = useGetProductsQuery(params);

  const rowsData: GridValidRowModel[] = data?.data || [];
  const columns: GridColDef<TProduct>[] = [
    { field: "product_title", headerName: "Title", minWidth: 150, flex: 1 },
    {
      field: "banner",
      headerName: "Banner",
      renderCell: ({ row }) => (
        <Stack direction="row" alignItems="center" height="100%">
          <img
            src={`${import.meta.env.VITE_IMG_URL}/${
              row.get_gallery_images?.[0]?.img
            }`}
            alt="icon"
            height={40}
          />
        </Stack>
      ),
      disableColumnMenu: true,
      sortable: false,
      minWidth: 150,
      flex: 1,
    },
    {
      field: "product_description",
      headerName: "Description",
      sortable: false,
      minWidth: 200,
      flex: 1,
    },
    { field: "price", headerName: "Price", minWidth: 100, flex: 1 },
    {
      field: "status",
      headerName: "Status",
      renderCell: ({ row }) => (
        <Chip
          label={row?.status}
          color={
            row?.status === "Active"
              ? "success"
              : row?.status === "Pending"
              ? "warning"
              : row?.status === "Rejected"
              ? "error"
              : row?.status === "Unpublished"
              ? "info"
              : row?.status === "Disabled"
              ? "secondary"
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
            onClick={() => setModalState({ type: "view", data: row })}
            aria-label="view"
          >
            <VisibilityRounded color="primary" />
          </IconButton>
        </Stack>
      ),
      minWidth: 140,
      flex: 1,
    },
  ];

  return (
    <>
      <HeaderTitle title="Product Management" />
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="Product Management" />
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
          data={modalState.data as TProduct}
        />
      )}
    </>
  );
};

export default ProductManagement;
