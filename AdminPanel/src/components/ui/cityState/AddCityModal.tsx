import { FieldValues, SubmitHandler } from "react-hook-form";
import { useAddCityMutation } from "../../../redux/features/city-state/cityStateApi";
import { useGetAllCountryQuery } from "../../../redux/features/country/countryApi";
import RCForm from "../../form/RCForm";
import RCModal from "../../modal/RCModal";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import { zodResolver } from "@hookform/resolvers/zod";
import { AddCityValidation } from "../../../schemas";
import { Button, Grid, Stack } from "@mui/material";
import RCSelect, { TItem } from "../../form/RCSelect";
import RCInput from "../../form/RCInput";
import { TAddModal } from "../../../types";

const AddCityModal = ({ open, setOpen }: TAddModal) => {
  const { data: countries } = useGetAllCountryQuery(undefined);
  const [addCity] = useAddCityMutation();

  const countryItems = countries?.data?.map((item) => ({
    value: item.id,
    label: item.country_name,
  }));

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    await handleAsyncToast({
      promise: addCity(values).unwrap(),
      success: () => {
        return "Item added successfully!";
      },
    });
    setOpen(false);
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Add Country">
      <RCForm
        onSubmit={onSubmit}
        defaultValues={{
          city_name: "",
          country_id: "",
          status: 1,
        }}
        resolver={zodResolver(AddCityValidation)}
      >
        <Grid container spacing={2}>
          <Grid item xs={12}>
            <RCSelect
              name="country_id"
              label="Country"
              items={countryItems as TItem[]}
            />
          </Grid>
          <Grid item xs={12}>
            <RCInput name="city_name" label="City Name" />
          </Grid>
        </Grid>
        <Stack direction="row" justifyContent="end" mt={4}>
          <Button type="submit">Submit</Button>
        </Stack>
      </RCForm>
    </RCModal>
  );
};

export default AddCityModal;
