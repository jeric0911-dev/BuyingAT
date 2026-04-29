import { Button, Grid, Stack } from "@mui/material";
import { TAdmin, TUpdateModal } from "../../../types";
import RCForm from "../../form/RCForm";
import RCModal from "../../modal/RCModal";
import RCSelect from "../../form/RCSelect";
import RCInput from "../../form/RCInput";
import { FieldValues, SubmitHandler } from "react-hook-form";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import { useGetAllRoleQuery } from "../../../redux/features/rolePermission/rolePermissionApi";
import { useUpdateAdminMutation } from "../../../redux/features/admin/adminApi";
import { UpdateAdminValidation } from "../../../schemas";
import { zodResolver } from "@hookform/resolvers/zod";

const UpdateAdminModal = ({ data, open, setOpen }: TUpdateModal<TAdmin>) => {
  const { data: roles } = useGetAllRoleQuery(undefined);
  const [EditAdmin] = useUpdateAdminMutation();

  const roleOptions =
    roles?.data.map((item) => ({
      label: item.type,
      value: item.id,
    })) || [];

  const defaultValues = {
    username: data.username,
    email: data.email,
    password: "",
    admin_type_id: data.admin_type.id,
  };

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    await handleAsyncToast({
      promise: EditAdmin({ id: data.id, data: values }).unwrap(),
      success: () => {
        return "Admin updated successfully!";
      },
    });
    setOpen(false);
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Update Admin">
      <RCForm
        onSubmit={onSubmit}
        defaultValues={defaultValues}
        resolver={zodResolver(UpdateAdminValidation)}
      >
        <Grid container spacing={2}>
          <Grid item xs={12}>
            <RCSelect name="admin_type_id" label="Role" items={roleOptions} />
          </Grid>
          <Grid item xs={12}>
            <RCInput name="username" label="Name" />
          </Grid>
          <Grid item xs={12}>
            <RCInput name="email" label="Email" type="email" />
          </Grid>
          <Grid item xs={12}>
            <RCInput name="password" label="Password" />
          </Grid>
        </Grid>
        <Stack direction="row" justifyContent="end" mt={4}>
          <Button type="submit">Submit</Button>
        </Stack>
      </RCForm>
    </RCModal>
  );
};

export default UpdateAdminModal;
