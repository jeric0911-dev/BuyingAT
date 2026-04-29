import { FieldValues, SubmitHandler } from "react-hook-form";
import { useEditPackageCategoryMutation } from "../../../redux/features/packageCategory/packageCategoryApi";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import { TPackageCategory, TUpdateModal } from "../../../types";
import RCModal from "../../modal/RCModal";
import RCForm from "../../form/RCForm";
import { Button, Grid, Stack } from "@mui/material";
import RCInput from "../../form/RCInput";
import RCSelect from "../../form/RCSelect";

const PCUpdateModal = ({
  data,
  open,
  setOpen,
}: TUpdateModal<TPackageCategory>) => {
  const [editCat] = useEditPackageCategoryMutation();

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    handleAsyncToast({
      promise: editCat({ id: data.id, data: values }).unwrap(),
      success: () => "Package category updated successfully!",
    });
    setOpen(false);
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Edit Package Category">
      <RCForm
        onSubmit={onSubmit}
        defaultValues={{
          title: data.title,
          duration: data.duration,
          status: data.status,
        }}
      >
        <Grid container spacing={2}>
          <Grid item xs={12}>
            <RCInput name="title" label="Title" />
          </Grid>
          <Grid item xs={12}>
            <RCInput name="duration" label="Duration (In days)" type="number" />
          </Grid>
          <Grid item xs={12}>
            <RCSelect
              name="status"
              label="Status"
              items={[
                { label: "Active", value: 1 },
                { label: "Inactive", value: 0 },
              ]}
            />
          </Grid>
        </Grid>
        <Stack direction="row" justifyContent="end" mt={4}>
          <Button type="submit">Submit</Button>
        </Stack>
      </RCForm>
    </RCModal>
  );
};

export default PCUpdateModal;
