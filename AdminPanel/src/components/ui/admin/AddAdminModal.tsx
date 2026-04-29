import { Button, Grid, Stack } from "@mui/material";
import RCForm from "../../form/RCForm";
import RCModal from "../../modal/RCModal";
import { zodResolver } from "@hookform/resolvers/zod";
import RCInput from "../../form/RCInput";
import { FieldValues, SubmitHandler } from "react-hook-form";
import { useGetAllRoleQuery } from "../../../redux/features/rolePermission/rolePermissionApi";
import { useAddAdminMutation } from "../../../redux/features/admin/adminApi";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import { AddAdminValidation } from "../../../schemas";
import RCSelect from "../../form/RCSelect";
import { TAddModal } from "../../../types";

const defaultValues = {
  username: "",
  email: "",
  password: "",
  admin_type_id: "",
};

const AddAdminModal = ({ open, setOpen }: TAddModal) => {
  const { data } = useGetAllRoleQuery(undefined);
  const [addAdmin] = useAddAdminMutation();

  const roleOptions =
    data?.data.map((item) => ({
      label: item.type,
      value: item.id,
    })) || [];

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    await handleAsyncToast({
      promise: addAdmin(values).unwrap(),
      success: () => {
        setOpen(false);
        return "Admin added successfully!";
      },
    });
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Add Admin">
      <RCForm
        onSubmit={onSubmit}
        defaultValues={defaultValues}
        resolver={zodResolver(AddAdminValidation)}
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

export default AddAdminModal;
