import { FieldValues, SubmitHandler } from "react-hook-form";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import RCModal from "../../modal/RCModal";
import RCForm from "../../form/RCForm";
import { Button, Grid, Stack } from "@mui/material";
import RCInput from "../../form/RCInput";
import { useAddBlogCategoryMutation } from "../../../redux/features/blogCategory/blogCategoryApi";
import { zodResolver } from "@hookform/resolvers/zod";
import { AddBlogCategoryValidation } from "../../../schemas";
import { TAddModal } from "../../../types";

const AddBlogCategoryModal = ({ open, setOpen }: TAddModal) => {
  const [addCategory] = useAddBlogCategoryMutation();

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    await handleAsyncToast({
      promise: addCategory(values).unwrap(),
      success: () => {
        return "Item added successfully!";
      },
    });
    setOpen(false);
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Add Blog Category">
      <RCForm
        onSubmit={onSubmit}
        defaultValues={{
          name: "",
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

export default AddBlogCategoryModal;
