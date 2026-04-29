import { Button, Grid, Stack } from "@mui/material";
import RCForm from "../../form/RCForm";
import RCModal from "../../modal/RCModal";
import RCInput from "../../form/RCInput";
import { TSubCategory } from "../../../types";
import { FieldValues, SubmitHandler } from "react-hook-form";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import { zodResolver } from "@hookform/resolvers/zod";
import { UpdateSubCategoryValidation } from "../../../schemas";
import RCFileUploader from "../../form/RCFileUploader";
import { useUpdateSubCategoryMutation } from "../../../redux/features/subCategory/subCategoryApi";
import { useGetAllCategoryQuery } from "../../../redux/features/category/categoryApi";
import RCSelect, { TItem } from "../../form/RCSelect";

type TProps = {
  open: boolean;
  setOpen: React.Dispatch<React.SetStateAction<boolean>>;
  data: TSubCategory;
};

const UpdateSubCategoryModal = ({ open, setOpen, data }: TProps) => {
  const { data: categories } = useGetAllCategoryQuery(undefined);
  const [updateCategory] = useUpdateSubCategoryMutation();
  const categoryItems = categories?.data?.map((item) => ({
    label: item.category_name,
    value: item.id,
  }));

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    await handleAsyncToast({
      promise: updateCategory({ id: data.id, data: values }).unwrap(),
      success: () => {
        return "Sub category update successfully!";
      },
    });
    setOpen(false);
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Update Sub Category">
      <RCForm
        onSubmit={onSubmit}
        defaultValues={{
          category_id: data.category_id,
          sub_category_name: data.sub_category_name || "",
          icon: undefined,
          banner: undefined,
        }}
        resolver={zodResolver(UpdateSubCategoryValidation)}
      >
        <Grid container spacing={2}>
          <Grid item xs={12}>
            <RCSelect
              name="category_id"
              label="Category"
              items={categoryItems as TItem[]}
            />
          </Grid>
          <Grid item xs={12}>
            <RCInput name="sub_category_name" label="Name" />
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

export default UpdateSubCategoryModal;
