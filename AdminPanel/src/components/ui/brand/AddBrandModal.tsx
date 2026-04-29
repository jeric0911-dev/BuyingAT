import { FieldValues, SubmitHandler } from "react-hook-form";
import RCForm from "../../form/RCForm";
import RCModal from "../../modal/RCModal";
import { Button, Grid, Stack } from "@mui/material";
import RCInput from "../../form/RCInput";
import RCFileUploader from "../../form/RCFileUploader";
import objectToFormData from "../../../utils/objectToFormData";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import { useGetAllCategoryQuery } from "../../../redux/features/category/categoryApi";
import RCSelect, { TItem } from "../../form/RCSelect";
import { useAddBrandMutation } from "../../../redux/features/brand/brandApi";
import { TAddModal } from "../../../types";

const AddBrandModal = ({ open, setOpen }: TAddModal) => {
  const [addStake] = useAddBrandMutation();
  const { data } = useGetAllCategoryQuery(undefined);

  const categoryItems = data?.data?.map((item) => ({
    label: item.category_name,
    value: item.id,
  }));

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    const formData = objectToFormData(values);
    await handleAsyncToast({
      promise: addStake(formData).unwrap(),
      success: () => {
        return "Item added successfully!";
      },
    });
    setOpen(false);
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Add Brand">
      <RCForm
        onSubmit={onSubmit}
        defaultValues={{
          brand_name: "",
          icon: undefined,
          banner: undefined,
          category_id: "",
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
            <RCInput name="brand_name" label="Title" />
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

export default AddBrandModal;
