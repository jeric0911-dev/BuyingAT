import { FieldValues, SubmitHandler } from "react-hook-form";
import { useAddPackageMutation } from "../../../redux/features/package/packageApi";
import RCForm from "../../form/RCForm";
import RCModal from "../../modal/RCModal";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import { Button, Grid, Stack } from "@mui/material";
import RCInput from "../../form/RCInput";
import RCAutocomplete from "../../form/RCAutocomplete";
import { useGetPackageCategoriesQuery } from "../../../redux/features/packageCategory/packageCategoryApi";
import RCSelect, { TItem } from "../../form/RCSelect";

type TProps = {
  open: boolean;
  setOpen: React.Dispatch<React.SetStateAction<boolean>>;
};

const defaultValues = {
  title: "",
  price: "",
  package_category_id: "",
  product_count: "",
  advert_count: "",
  package_advantage: [],
};

const AddPackageModal = ({ open, setOpen }: TProps) => {
  const { data } = useGetPackageCategoriesQuery(undefined);
  const [addPackage] = useAddPackageMutation();

  const categoryOptions = data?.data?.map((item) => ({
    label: item.title,
    value: item.id,
  }));

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    values.price = Number(values.price);
    handleAsyncToast({
      promise: addPackage(values).unwrap(),
      success: () => {
        setOpen(false);
        return "Package added successfully";
      },
    });
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Add Package">
      <RCForm onSubmit={onSubmit} defaultValues={defaultValues}>
        <Grid container spacing={2}>
          <Grid item xs={12}>
            <RCSelect
              name="package_category_id"
              label="Package Category"
              items={categoryOptions as TItem[]}
            />
          </Grid>
          <Grid item xs={12}>
            <RCInput name="title" label="Title" />
          </Grid>
          <Grid item xs={12}>
            <RCInput name="price" label="Price" type="number" />
          </Grid>
          <Grid item xs={12}>
            <RCInput name="product_count" label="Product Limit" type="number" />
          </Grid>
          <Grid item xs={12}>
            <RCInput name="advert_count" label="Feature Limit" type="number" />
          </Grid>
          <Grid item xs={12}>
            <RCAutocomplete
              name="package_advantage"
              label="Package Advantage"
            />
          </Grid>
        </Grid>
        <Stack direction="row" justifyContent="end" mt={4}>
          <Button type="submit">Submit</Button>
        </Stack>
      </RCForm>
    </RCModal>
  );
};

export default AddPackageModal;
