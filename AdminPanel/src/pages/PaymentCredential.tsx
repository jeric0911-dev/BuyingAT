import { Box, Chip, IconButton, Stack } from "@mui/material";
import HeaderTitle from "../components/seo/HeaderTitle";
import PageTitle from "../components/ui/shared/PageTitle";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import { TGateway, TModalState } from "../types";
import { useGetGatewaysQuery } from "../redux/features/settings/settingsApi";
import { useState } from "react";
import { DriveFileRenameOutlineRounded } from "@mui/icons-material";
import EditGatewayModal from "../components/ui/gateway/EditGatewayModal";

const PaymentCredentials = () => {
  const [modalState, setModalState] = useState<TModalState<TGateway>>({
    type: null,
  });
  const { data, isFetching } = useGetGatewaysQuery(undefined);
  // const { edit } = GetPermission("payment-credentials") as TPermissions;

  const rowsData: GridValidRowModel[] = data?.data || [];

  const columns: GridColDef<TGateway>[] = [
    { field: "gateway_name", headerName: "Gateway", minWidth: 150, flex: 1 },
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
          <IconButton onClick={() => handleEditModal(row)}>
            <DriveFileRenameOutlineRounded color="success" />
          </IconButton>
        </Stack>
      ),
      minWidth: 140,
      flex: 1,
    },
  ];

  const handleEditModal = (data: TGateway) => {
    // if (!edit) {
    //   toast.error("You don't have permission");
    // } else {
    // }
    setModalState({ type: "edit", data });
  };

  return (
    <>
      <HeaderTitle title="Payment Credential" />
      <PageTitle title="Payment Credential" />
      <Box
        mt="20px"
        sx={{ border: "1px solid #E0E2E7" }}
        borderRadius={2}
        bgcolor="white"
        overflow="hidden"
      >
        <MyDataGrid rows={rowsData} columns={columns} loading={isFetching} />
      </Box>
      {modalState.type === "edit" && (
        <EditGatewayModal
          open={modalState.type === "edit"}
          setOpen={() => setModalState({ type: null })}
          data={modalState.data as TGateway}
        />
      )}
    </>
  );
};

export default PaymentCredentials;
