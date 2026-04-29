import { FieldValues, SubmitHandler } from "react-hook-form";
import { TPackage, TUpdateModal } from "../../../types";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import RCModal from "../../modal/RCModal";
import RCForm from "../../form/RCForm";
import { Button, Grid, Stack } from "@mui/material";
import RCInput from "../../form/RCInput";
import RCAutocomplete from "../../form/RCAutocomplete";
import { useEditPackageMutation } from "../../../redux/features/package/packageApi";
import { useGetPackageCategoriesQuery } from "../../../redux/features/packageCategory/packageCategoryApi";
import RCSelect, { TItem } from "../../form/RCSelect";

const UpdatePackageModal = ({
  open,
  setOpen,
  data,
}: TUpdateModal<TPackage>) => {
  const { data: categories } = useGetPackageCategoriesQuery(undefined);
  const [updatePackage] = useEditPackageMutation();

  const categoryOptions = categories?.data?.map((item) => ({
    label: item.title,
    value: item.id,
  }));

  const defaultValues = {
    title: data.title || "",
    price: data.price || "",
    package_category_id: data.package_category_id,
    product_count: data.product_count,
    advert_count: data.advert_count,
    package_advantage: data.package_advantage.map((item) => item.title) || [],
  };

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    values.price = Number(values.price);
    handleAsyncToast({
      promise: updatePackage({ id: data.id, data: values }).unwrap(),
      success: () => {
        return "Package updated successfully";
      },
    });
    setOpen(false);
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Update Package">
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

export default UpdatePackageModal;
