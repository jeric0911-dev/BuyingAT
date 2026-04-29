import { GridColDef, GridRowModel } from "@mui/x-data-grid";
import {
  useEditUserMutation,
  useGetUsersQuery,
} from "../redux/features/userManagement/userManagementApi";
import HeaderTitle from "../components/seo/HeaderTitle";
import { Box, Chip, IconButton, Menu, MenuItem, Stack, Tooltip } from "@mui/material";
import PageTitle from "../components/ui/shared/PageTitle";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import { useServerPagination } from "../hooks/useServerPagination";
import { TUser } from "../types";
import handleAsyncToast from "../utils/handleAsyncToast";
import { useState } from "react";
import { ArrowDropDownIcon } from "@mui/x-date-pickers";
import { VisibilityRounded, Warning, Security } from "@mui/icons-material";
import { useNavigate, useSearchParams } from "react-router-dom";

const UserManagement = () => {
  const [searchParams] = useSearchParams();
  const { handlePaginationModelChange, paginationModel, queryParams } =
    useServerPagination({ defaultPageSize: 10 });
  const params: Record<string, any> = { ...queryParams };
  searchParams.get("status") && (params["status"] = searchParams.get("status"));
  const { data, isFetching } = useGetUsersQuery(params);
  const [changeStatus] = useEditUserMutation();
  const rowsData: GridRowModel[] = data?.data || [];
  const [menuAnchor, setMenuAnchor] = useState<{
    anchorEl: null | HTMLElement;
    rowId: number | null;
  }>({ anchorEl: null, rowId: null });
  const router = useNavigate();

  const handleStatusChange = async (newStatus: 0 | 1, id: number) => {
    handleAsyncToast({
      promise: changeStatus({ user_id: id, status: newStatus }).unwrap(),
      success: () => "Status updated!",
    });
  };

  const handleRoute = (data: TUser) => {
    if (data.user_type === "vendor") {
      router(`/shop-management/${data.id}`);
    } else {
      router(`/user-management/${data.id}`);
    }
  };

  const columns: GridColDef<TUser>[] = [
    { field: "name", headerName: "Name", minWidth: 150, flex: 1 },
    { field: "email", headerName: "Email", minWidth: 200, flex: 1 },
    { field: "phone", headerName: "Phone", minWidth: 150, flex: 1 },
    {
      field: "user_package",
      headerName: "Package",
      renderCell: ({ row }) => row.user_package?.package_name,
      minWidth: 150,
      flex: 1,
    },
    {
      field: "user_type",
      headerName: "Type",
      minWidth: 130,
      renderCell: ({ value }) => (
        <Chip
          label={value?.charAt(0).toUpperCase() + value?.slice(1)}
          color={value === "vendor" ? "success" : "default"}
          variant="outlined"
        />
      ),
    },
    {
      field: "status",
      headerName: "Status",
      minWidth: 150,
      renderCell: ({ row }) => (
        <>
          <Chip
            label={row?.status === 1 ? "Active" : "Inactive"}
            onClick={(e) =>
              setMenuAnchor({ anchorEl: e.currentTarget, rowId: row.id })
            }
            color={row?.status === 1 ? "success" : "error"}
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
            {[
              { label: "Active", status: 1 },
              { label: "Inactive", status: 0 },
            ].map(({ status, label }) => (
              <MenuItem
                key={status}
                onClick={() => {
                  handleStatusChange(status as TUser["status"], row.id);
                  setMenuAnchor({ anchorEl: null, rowId: null });
                }}
                selected={row?.status === status}
              >
                {label}
              </MenuItem>
            ))}
          </Menu>
        </>
      ),
    },
    {
      field: "blacklist",
      headerName: "Violations",
      minWidth: 150,
      renderCell: ({ row }) => {
        const violationCount = row.violation_count || 0;
        const hasViolations = violationCount > 0;
        const isExcessive = violationCount >= 10;
        
        if (!hasViolations) {
          return (
            <Chip
              label="Clean"
              color="success"
              variant="outlined"
              size="small"
              icon={<Security />}
            />
          );
        }
        
        return (
          <Tooltip 
            title={
              <Box>
                <div><strong>Total Violations:</strong> {violationCount}</div>
                <div><strong>Last Violation:</strong> {row.last_violation_at ? new Date(row.last_violation_at).toLocaleDateString() : 'N/A'}</div>
                {row.blacklist && row.blacklist.length > 0 && (
                  <div>
                    <strong>Recent Types:</strong> {row.blacklist.slice(-3).map(v => v.type).join(', ')}
                  </div>
                )}
              </Box>
            }
            arrow
          >
            <Chip
              label={`${violationCount} violations`}
              color={isExcessive ? "error" : "warning"}
              variant="filled"
              size="small"
              icon={<Warning />}
              sx={{ 
                cursor: 'pointer',
                '&:hover': {
                  backgroundColor: isExcessive ? 'error.dark' : 'warning.dark'
                }
              }}
            />
          </Tooltip>
        );
      },
    },
    {
      field: "action",
      headerName: "Action",
      renderCell: ({ row }) => (
        <Stack direction="row" alignItems="center" height="100%">
          <IconButton onClick={() => handleRoute(row)} aria-label="view">
            <VisibilityRounded color="primary" />
          </IconButton>
        </Stack>
      ),
      minWidth: 50,
    },
  ];

  return (
    <>
      <HeaderTitle title="User Management" />
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="User Management" />
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

export default UserManagement;
