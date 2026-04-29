import { FieldValues, SubmitHandler } from "react-hook-form";
import RCForm from "../../form/RCForm";
import RCModal from "../../modal/RCModal";
import { AddCategoryValidation } from "../../../schemas";
import { Button, Grid, Stack } from "@mui/material";
import RCInput from "../../form/RCInput";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import { zodResolver } from "@hookform/resolvers/zod";
import { useAddCategoryMutation } from "../../../redux/features/category/categoryApi";
import RCFileUploader from "../../form/RCFileUploader";
import objectToFormData from "../../../utils/objectToFormData";
import { TAddModal } from "../../../types";

const AddCategoryModal = ({ open, setOpen }: TAddModal) => {
  const [addCategory] = useAddCategoryMutation();

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    values.status = 1;
    values.slug = "";
    const body = objectToFormData(values);
    await handleAsyncToast({
      promise: addCategory(body).unwrap(),
      success: () => {
        return "Category added successfully!";
      },
    });
    setOpen(false);
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Add Category">
      <RCForm
        onSubmit={onSubmit}
        defaultValues={{
          category_name: "",
          icon: undefined,
          banner: undefined,
        }}
        resolver={zodResolver(AddCategoryValidation)}
      >
        <Grid container spacing={2}>
          <Grid item xs={12}>
            <RCInput name="category_name" label="Name" />
          </Grid>
          <Grid item xs={12}>
            <RCFileUploader name="icon" label="Icon" />
          </Grid>
          <Grid item xs={12}>
            <RCFileUploader name="banner" label="Banner" />
          </Grid>
        </Grid>
        <Stack direction="row" justifyContent="end" mt={4}>
          <Button type="submit">Submit</Button>
        </Stack>
      </RCForm>
    </RCModal>
  );
};

export default AddCategoryModal;
