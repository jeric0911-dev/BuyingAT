import { FieldValues, SubmitHandler } from "react-hook-form";
import RCForm from "../../form/RCForm";
import RCModal from "../../modal/RCModal";
import { AddChildCategoryValidation } from "../../../schemas";
import { Button, Grid, Stack } from "@mui/material";
import RCInput from "../../form/RCInput";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import { zodResolver } from "@hookform/resolvers/zod";
import RCFileUploader from "../../form/RCFileUploader";
import { useGetAllSubCategoryQuery } from "../../../redux/features/subCategory/subCategoryApi";
import RCSelect, { TItem } from "../../form/RCSelect";
import { useAddChildCategoryMutation } from "../../../redux/features/childCategory/childCategoryApi";
import objectToFormData from "../../../utils/objectToFormData";
import { TAddModal } from "../../../types";

const AddChildCategoryModal = ({ open, setOpen }: TAddModal) => {
  const { data } = useGetAllSubCategoryQuery(undefined);
  const [addChildCategory] = useAddChildCategoryMutation();
  const subCategoryItems = data?.data?.map((item) => ({
    label: item.sub_category_name,
    value: item.id,
  }));

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    values.status = 1;
    values.slug = "";
    await handleAsyncToast({
      promise: addChildCategory(objectToFormData(values)).unwrap(),
      success: () => {
        return "Item added successfully!";
      },
    });
    setOpen(false);
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Add Child Category">
      <RCForm
        onSubmit={onSubmit}
        defaultValues={{
          sub_category_id: "",
          child_category_name: "",
          icon: undefined,
          banner: undefined,
        }}
        resolver={zodResolver(AddChildCategoryValidation)}
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

export default AddChildCategoryModal;
