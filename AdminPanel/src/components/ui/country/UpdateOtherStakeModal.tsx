import { FieldValues, SubmitHandler } from "react-hook-form";
import { TCountry, TUpdateModal } from "../../../types";
import RCForm from "../../form/RCForm";
import RCModal from "../../modal/RCModal";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import { Button, Grid, Stack } from "@mui/material";
import RCInput from "../../form/RCInput";
import { zodResolver } from "@hookform/resolvers/zod";
import { useUpdateCountryMutation } from "../../../redux/features/country/countryApi";
import { AddCountryValidation } from "../../../schemas";

const UpdateCountryModal = ({ data, open, setOpen }: TUpdateModal<TCountry>) => {
  const [updateCountry] = useUpdateCountryMutation();

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    await handleAsyncToast({
      promise: updateCountry({ id: data.id, data: values }).unwrap(),
      success: () => {
        return "Item updated successfully!";
      },
    });
    setOpen(false);
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Update Country">
      <RCForm
        onSubmit={onSubmit}
        defaultValues={{
          country_name: data.country_name,
          state: data.status,
        }}
        resolver={zodResolver(AddCountryValidation)}
      >
        <Grid container spacing={2}>
          <Grid item xs={12}>
            <RCInput name="country_name" label="Country Name" />
          </Grid>
        </Grid>
        <Stack direction="row" justifyContent="end" mt={4}>
          <Button type="submit">Submit</Button>
        </Stack>
      </RCForm>
    </RCModal>
  );
};

export default UpdateCountryModal;
