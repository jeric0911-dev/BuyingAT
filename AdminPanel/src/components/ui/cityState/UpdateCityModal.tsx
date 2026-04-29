import { FieldValues, SubmitHandler } from "react-hook-form";
import { useUpdateCityMutation } from "../../../redux/features/city-state/cityStateApi";
import { useGetAllCountryQuery } from "../../../redux/features/country/countryApi";
import { TCityState, TUpdateModal } from "../../../types";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import RCModal from "../../modal/RCModal";
import RCForm from "../../form/RCForm";
import { zodResolver } from "@hookform/resolvers/zod";
import { AddCityValidation } from "../../../schemas";
import { Button, Grid, Stack } from "@mui/material";
import RCSelect, { TItem } from "../../form/RCSelect";
import RCInput from "../../form/RCInput";

const UpdateCityModal = ({ data, open, setOpen }: TUpdateModal<TCityState>) => {
  const { data: countries } = useGetAllCountryQuery(undefined);
  const [updateCity] = useUpdateCityMutation();

  const countryItems = countries?.data?.map((item) => ({
    value: item.id,
    label: item.country_name,
  }));

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    await handleAsyncToast({
      promise: updateCity(values).unwrap(),
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
          city_name: data.city_name || "",
          country_id: data.country_id || "",
          status: data.status,
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

export default UpdateCityModal;
