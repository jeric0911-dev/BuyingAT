import { Button, Grid, Stack } from "@mui/material";
import RCForm from "../../form/RCForm";
import RCModal from "../../modal/RCModal";
import RCInput from "../../form/RCInput";
import { TCategory, TUpdateModal } from "../../../types";
import { FieldValues, SubmitHandler } from "react-hook-form";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import { zodResolver } from "@hookform/resolvers/zod";
import { useUpdateCategoryMutation } from "../../../redux/features/category/categoryApi";
import { UpdateCategoryValidation } from "../../../schemas";
import RCFileUploader from "../../form/RCFileUploader";
import objectToFormData from "../../../utils/objectToFormData";

const UpdateCategoryModal = ({ open, setOpen, data }: TUpdateModal<TCategory>) => {
  const [updateCategory] = useUpdateCategoryMutation();

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    const body = objectToFormData(values)
    await handleAsyncToast({
      promise: updateCategory({ id: data.id, data: body }).unwrap(),
      success: () => {
        return "Category update successfully!";
      },
    });
    setOpen(false);
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Update Category">
      <RCForm
        onSubmit={onSubmit}
        defaultValues={{
          category_name: data.category_name || "",
          icon: undefined,
          banner: undefined,
        }}
        resolver={zodResolver(UpdateCategoryValidation)}
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

export default UpdateCategoryModal;
