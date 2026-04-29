import { useParams } from "react-router-dom";
import { useGetAUserQuery } from "../redux/features/userManagement/userManagementApi";
import HeaderTitle from "../components/seo/HeaderTitle";
import { Box, Chip, IconButton, Stack } from "@mui/material";
import PageTitle from "../components/ui/shared/PageTitle";
import { useState } from "react";
import { TModalState, TProduct } from "../types";
import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import { VisibilityRounded } from "@mui/icons-material";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import ProductViewModal from "../components/ui/productManagement/ProductViewModal";

const UserAds = () => {
  const { id } = useParams();
  const [modalState, setModalState] = useState<TModalState<TProduct>>({
    type: null,
  });
  const { data, isFetching } = useGetAUserQuery(id as string);
  const rowsData: GridValidRowModel[] = data?.data?.products || [];

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
      <HeaderTitle title="User's Product" />
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle
          title={
            data?.data.user_type === "vendor"
              ? (data.data.shop?.name as string)
              : (data?.data?.name as string)
          }
        />
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
          //   paginationMode="server"
          //   paginationModel={paginationModel}
          //   onPaginationModelChange={handlePaginationModelChange}
          //   rowCount={data?.pagination?.total}
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

export default UserAds;
