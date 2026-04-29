import { FieldValues, SubmitHandler } from "react-hook-form";
import RCForm from "../../form/RCForm";
import RCModal from "../../modal/RCModal";
import { AddSubCategoryValidation } from "../../../schemas";
import { Button, Grid, Stack } from "@mui/material";
import RCInput from "../../form/RCInput";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import { zodResolver } from "@hookform/resolvers/zod";
import { useGetAllCategoryQuery } from "../../../redux/features/category/categoryApi";
import RCFileUploader from "../../form/RCFileUploader";
import { useAddSubCategoryMutation } from "../../../redux/features/subCategory/subCategoryApi";
import RCSelect, { TItem } from "../../form/RCSelect";
import objectToFormData from "../../../utils/objectToFormData";

type TProps = {
  open: boolean;
  setOpen: React.Dispatch<React.SetStateAction<boolean>>;
};

const AddSubCategoryModal = ({ open, setOpen }: TProps) => {
  const { data } = useGetAllCategoryQuery(undefined);
  const [addSubCategory] = useAddSubCategoryMutation();
  const categoryItems = data?.data?.map((item) => ({
    label: item.category_name,
    value: item.id,
  }));

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    values.status = 1;
    values.slug = "";

    await handleAsyncToast({
      promise: addSubCategory(objectToFormData(values)).unwrap(),
      success: () => {
        return "Sub category added successfully!";
      },
    });
    setOpen(false);
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Add Sub Category">
      <RCForm
        onSubmit={onSubmit}
        defaultValues={{
          category_id: "",
          sub_category_name: "",
          icon: undefined,
          banner: undefined,
        }}
        resolver={zodResolver(AddSubCategoryValidation)}
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

export default AddSubCategoryModal;
