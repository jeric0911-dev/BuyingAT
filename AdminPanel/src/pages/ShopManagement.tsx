import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import {
  useChangeShopStatusMutation,
  useGetShopsQuery,
} from "../redux/features/shopManagement/shopManagementApi";
import { TShop } from "../types";
import HeaderTitle from "../components/seo/HeaderTitle";
import { Box, Chip, IconButton, Menu, MenuItem, Stack } from "@mui/material";
import PageTitle from "../components/ui/shared/PageTitle";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import { useState } from "react";
import handleAsyncToast from "../utils/handleAsyncToast";
import { ArrowDropDownIcon } from "@mui/x-date-pickers";
import { Link, useSearchParams } from "react-router-dom";
import { VisibilityRounded } from "@mui/icons-material";

const ShopManagement = () => {
  const [menuAnchor, setMenuAnchor] = useState<{
    anchorEl: null | HTMLElement;
    rowId: number | null;
  }>({ anchorEl: null, rowId: null });
  const [searchParams] = useSearchParams();
  const params: Record<string, any> = {};
  searchParams.get("status") && (params["status"] = searchParams.get("status"));
  const { data, isFetching } = useGetShopsQuery(params);
  const [update] = useChangeShopStatusMutation();
  const rowsData: GridValidRowModel[] = data?.data || [];

  const columns: GridColDef<TShop>[] = [
    { field: "name", headerName: "Shop Name", minWidth: 150, flex: 1 },
    {
      field: "description",
      headerName: "Description",
      sortable: false,
      minWidth: 200,
      flex: 1,
    },
    {
      field: "banner",
      headerName: "Banner",
      renderCell: ({ row }) => (
        <Stack direction="row" alignItems="center" height="100%">
          <img
            src={`${import.meta.env.VITE_IMG_URL}/${row.banner}`}
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
      field: "status",
      headerName: "Status",
      renderCell: ({ row }) => (
        <>
          <Chip
            label={row.status?.charAt(0).toUpperCase() + row.status?.slice(1)}
            onClick={(e) =>
              setMenuAnchor({ anchorEl: e.currentTarget, rowId: row.id })
            }
            color={
              row?.status === "active"
                ? "success"
                : row?.status === "pending"
                ? "warning"
                : row?.status === "rejected"
                ? "error"
                : row?.status === "disabled"
                ? "secondary"
                : "default"
            }
            variant="outlined"
            deleteIcon={<ArrowDropDownIcon />}
            onDelete={(e) =>
              setMenuAnchor({ anchorEl: e.currentTarget, rowId: row.id })
            }
            sx={{ cursor: "pointer" }}
          />
          <Menu
            anchorEl={menuAnchor.anchorEl}
            open={menuAnchor.rowId === row.id}
            onClose={() => setMenuAnchor({ anchorEl: null, rowId: null })}
            MenuListProps={{
              "aria-labelledby": "status-button",
            }}
          >
            {["active", "pending", "rejected", "disabled"].map((item) => (
              <MenuItem
                key={item}
                onClick={() => handleClose(item, row.id)}
                selected={row?.status.toLowerCase() === item}
                sx={{ textTransform: "capitalize" }}
              >
                {item}
              </MenuItem>
            ))}
          </Menu>
        </>
      ),
      minWidth: 150,
      flex: 1,
    },
    {
      field: "action",
      headerName: "Action",
      renderCell: ({ row }) => (
        <Stack direction="row" alignItems="center" height="100%">
          <Link to={`/shop-management/${row.user_id}`}>
            <IconButton aria-label="view">
              <VisibilityRounded color="primary" />
            </IconButton>
          </Link>
        </Stack>
      ),
      minWidth: 50,
    },
  ];

  const handleClose = (status: string, shop_id: number) => {
    handleAsyncToast({
      promise: update({ shop_id, status }).unwrap(),
      success: () => "Status changed successfully",
    });
    setMenuAnchor({ anchorEl: null, rowId: null });
  };

  return (
    <>
      <HeaderTitle title="Shop Management" />
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="Shop Management" />
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
    </>
  );
};

export default ShopManagement;
