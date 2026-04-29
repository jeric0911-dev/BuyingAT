import { FieldValues, SubmitHandler } from "react-hook-form";
import { useAddPackageCategoryMutation } from "../../../redux/features/packageCategory/packageCategoryApi";
import { TAddModal } from "../../../types";
import RCForm from "../../form/RCForm";
import RCModal from "../../modal/RCModal";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import RCInput from "../../form/RCInput";
import { Button, Grid, Stack } from "@mui/material";
import { zodResolver } from "@hookform/resolvers/zod";
import { AddPackageCategoryValidation } from "../../../schemas";
import RCSelect from "../../form/RCSelect";

const PCAddModal = ({ open, setOpen }: TAddModal) => {
  const [addCat] = useAddPackageCategoryMutation();

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    handleAsyncToast({
      promise: addCat(values).unwrap(),
      success: () => "Package category added successfully!",
    });
    setOpen(false);
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Add Package Category">
      <RCForm
        onSubmit={onSubmit}
        defaultValues={{ title: "", duration: "", status: 1 }}
        resolver={zodResolver(AddPackageCategoryValidation)}
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

export default PCAddModal;
