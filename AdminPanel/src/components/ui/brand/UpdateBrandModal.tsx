import { FieldValues, SubmitHandler } from "react-hook-form";
import { useGetAllCategoryQuery } from "../../../redux/features/category/categoryApi";
import { TBrand, TUpdateModal } from "../../../types";
import RCForm from "../../form/RCForm";
import RCModal from "../../modal/RCModal";
import objectToFormData from "../../../utils/objectToFormData";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import { Button, Grid, Stack } from "@mui/material";
import RCInput from "../../form/RCInput";
import RCFileUploader from "../../form/RCFileUploader";
import RCSelect, { TItem } from "../../form/RCSelect";
import { useUpdateBrandMutation } from "../../../redux/features/brand/brandApi";

const UpdateBrandModal = ({ data, open, setOpen }: TUpdateModal<TBrand>) => {
  const [updateBrand] = useUpdateBrandMutation();
  const { data: categories } = useGetAllCategoryQuery(undefined);

  const categoryItems = categories?.data?.map((item) => ({
    label: item.category_name,
    value: item.id,
  }));

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    const formData = objectToFormData(values);
    await handleAsyncToast({
      promise: updateBrand({ id: data.id, data: formData }).unwrap(),
      success: () => {
        return "Item updated successfully!";
      },
    });
    setOpen(false);
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Update Brand">
      <RCForm
        onSubmit={onSubmit}
        defaultValues={{
          category_id: data.category_id,
          brand_name: data.brand_name,
          banner: undefined,
          icon: undefined,
        }}
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
            <RCInput name="brand_name" label="Name" />
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

export default UpdateBrandModal;
