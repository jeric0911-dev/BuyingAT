import { TBlogCategory, TUpdateModal } from "../../../types";
import RCForm from "../../form/RCForm";
import RCModal from "../../modal/RCModal";
import { Button, Grid, Stack } from "@mui/material";
import RCInput from "../../form/RCInput";
import { FieldValues, SubmitHandler } from "react-hook-form";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import { useUpdateBlogCategoryMutation } from "../../../redux/features/blogCategory/blogCategoryApi";
import { zodResolver } from "@hookform/resolvers/zod";
import { AddBlogCategoryValidation } from "../../../schemas";

const UpdateBlogCategoryModal = ({ data, open, setOpen }: TUpdateModal<TBlogCategory>) => {
  const [updateCategory] = useUpdateBlogCategoryMutation();

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    await handleAsyncToast({
      promise: updateCategory({ id: data.id, data: values }).unwrap(),
      success: () => {
        return "Item updated successfully!";
      },
    });
    setOpen(false);
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Update Blog Category">
      <RCForm
        onSubmit={onSubmit}
        defaultValues={{
          name: data.name,
        }}
        resolver={zodResolver(AddBlogCategoryValidation)}
      >
        <Grid container spacing={2}>
          <Grid item xs={12}>
            <RCInput name="name" label="Name" />
          </Grid>
        </Grid>
        <Stack direction="row" justifyContent="end" mt={4}>
          <Button type="submit">Submit</Button>
        </Stack>
      </RCForm>
    </RCModal>
  );
};

export default UpdateBlogCategoryModal;
