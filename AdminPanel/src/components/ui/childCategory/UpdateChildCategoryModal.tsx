import { Button, Grid, Stack } from "@mui/material";
import RCForm from "../../form/RCForm";
import RCModal from "../../modal/RCModal";
import RCInput from "../../form/RCInput";
import { TChildCategory, TUpdateModal } from "../../../types";
import { FieldValues, SubmitHandler } from "react-hook-form";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import { zodResolver } from "@hookform/resolvers/zod";
import { UpdateChildCategoryValidation } from "../../../schemas";
import RCFileUploader from "../../form/RCFileUploader";
import { useGetAllSubCategoryQuery } from "../../../redux/features/subCategory/subCategoryApi";
import RCSelect, { TItem } from "../../form/RCSelect";
import { useUpdateChildCategoryMutation } from "../../../redux/features/childCategory/childCategoryApi";
import objectToFormData from "../../../utils/objectToFormData";

const UpdateChildCategoryModal = ({ open, setOpen, data }: TUpdateModal<TChildCategory>) => {
  const { data: subCategories } = useGetAllSubCategoryQuery(undefined);
  const [updateChildCategory] = useUpdateChildCategoryMutation();
  const subCategoryItems = subCategories?.data?.map((item) => ({
    label: item.sub_category_name,
    value: item.id,
  }));

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    await handleAsyncToast({
      promise: updateChildCategory({
        id: data.id,
        data: objectToFormData(values),
      }).unwrap(),
      success: () => {
        return "Child category update successfully!";
      },
    });
    setOpen(false);
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Update Child Category">
      <RCForm
        onSubmit={onSubmit}
        defaultValues={{
          sub_category_id: data.sub_category_id,
          child_category_name: data.child_category_name || "",
          icon: undefined,
          banner: undefined,
        }}
        resolver={zodResolver(UpdateChildCategoryValidation)}
      >
        <Grid container spacing={2}>
          <Grid item xs={12}>
            <RCSelect
              name="sub_category_id"
              label="Sub Category"
              items={subCategoryItems as TItem[]}
            />
          </Grid>
          <Grid item xs={12}>
            <RCInput name="child_category_name" label="Name" />
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

export default UpdateChildCategoryModal;
