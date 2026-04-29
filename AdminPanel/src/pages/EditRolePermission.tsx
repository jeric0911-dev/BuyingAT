import { useParams } from "react-router-dom";
import {
  useGetSingleRoleQuery,
  useUpdateRoleMutation,
} from "../redux/features/rolePermission/rolePermissionApi";
import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import { useMemo } from "react";
import { paths } from "../constants";
import { TPermissions } from "../types";
import RCCheck from "../components/form/RCCheck";
import { FieldValues, SubmitHandler } from "react-hook-form";
import handleAsyncToast from "../utils/handleAsyncToast";
import HeaderTitle from "../components/seo/HeaderTitle";
import PageTitle from "../components/ui/shared/PageTitle";
import RCForm from "../components/form/RCForm";
import { Box, Button, Grid, Stack } from "@mui/material";
import RCInput from "../components/form/RCInput";
import MyDataGrid from "../components/dataGrid/MyDataGrid";

const generateDefaultValues = (data: any) => ({
  type: data?.data.type || "",
  ...data?.data.role_parameters.reduce((acc: any, role: any) => {
    acc[role.name] = {
      view: role.view,
      edit: role.edit,
      delete: role.delete,
    };
    return acc;
  }, {}),
});

const EditRolePermission = () => {
  const { id } = useParams();
  const { data, isFetching } = useGetSingleRoleQuery(id as string);

  console.log('Fetched single role data from backend:', data);

  const [updateRole] = useUpdateRoleMutation();
  const rowsData: GridValidRowModel[] = useMemo(
    () => paths.map((path, i) => ({ id: i, name: path })),
    []
  );

  const columns: GridColDef<TPermissions>[] = [
    { field: "name", headerName: "Route Name", minWidth: 200, flex: 1 },
    {
      field: "view",
      headerName: "view",
      renderCell: ({ row }) => <RCCheck name={`${row.name}.view`} />,
      minWidth: 200,
      flex: 1,
    },
    {
      field: "edit",
      headerName: "Edit",
      renderCell: ({ row }) => <RCCheck name={`${row.name}.edit`} />,
      minWidth: 200,
      flex: 1,
    },
    {
      field: "delete",
      headerName: "Delete",
      renderCell: ({ row }) => <RCCheck name={`${row.name}.delete`} />,
      minWidth: 200,
      flex: 1,
    },
  ];

  const defaultValues = useMemo(() => generateDefaultValues(data), [data]);

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    const { type, ...rest } = values;
    const role_parameters = Object.entries(rest).map(
      ([name, { view, edit, delete: del }]) => ({
        name,
        view,
        edit,
        delete: del,
      })
    );
    await handleAsyncToast({
      promise: updateRole({ id, data: { type, role_parameters } }).unwrap(),
      success: () => {
        return "Role Permission update successfully!";
      },
    });
  };

  return (
    <>
      <HeaderTitle title="Edit Role/Permission" />
      <PageTitle title="Edit Role Permission" />
      {!isFetching && (
        <RCForm onSubmit={onSubmit} defaultValues={defaultValues}>
          <Grid container spacing={2} mt={3}>
            <Grid item xs={12}>
              <RCInput name="type" label="Role Name" />
            </Grid>
          </Grid>
          <Box
            mt="20px"
            border="1px soid #E0E7E2"
            borderRadius={2}
            bgcolor="white"
            overflow="hidden"
          >
            <MyDataGrid
              rows={rowsData}
              columns={columns}
              loading={isFetching}
              disableColumnSorting
            />
          </Box>
          <Stack direction="row" justifyContent="end" mt={4}>
            <Button type="submit">Submit</Button>
          </Stack>
        </RCForm>
      )}
    </>
  );
};

export default EditRolePermission;
