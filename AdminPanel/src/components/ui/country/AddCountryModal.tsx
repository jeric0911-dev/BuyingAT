import { FieldValues, SubmitHandler } from "react-hook-form";
import RCForm from "../../form/RCForm";
import RCModal from "../../modal/RCModal";
import { Button, Grid, Stack } from "@mui/material";
import RCInput from "../../form/RCInput";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import { zodResolver } from "@hookform/resolvers/zod";
import { AddCountryValidation } from "../../../schemas";
import { useAddCountryMutation } from "../../../redux/features/country/countryApi";
import { TAddModal } from "../../../types";

const AddCountryModal = ({ open, setOpen }: TAddModal) => {
  const [addCountry] = useAddCountryMutation();

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    await handleAsyncToast({
      promise: addCountry(values).unwrap(),
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
          country_name: "",
          status: 1,
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

export default AddCountryModal;
