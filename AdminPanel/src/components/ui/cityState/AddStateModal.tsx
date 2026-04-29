import { FieldValues, SubmitHandler } from "react-hook-form";
import { useAddStateMutation } from "../../../redux/features/city-state/cityStateApi";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import RCModal from "../../modal/RCModal";
import RCForm from "../../form/RCForm";
import { Button, Grid, Stack } from "@mui/material";
import RCInput from "../../form/RCInput";
import { zodResolver } from "@hookform/resolvers/zod";
import { AddStateValidation } from "../../../schemas";
import { useGetAllCountryQuery } from "../../../redux/features/country/countryApi";
import RCSelect, { TItem } from "../../form/RCSelect";
import { TAddModal } from "../../../types";

const AddStateModal = ({ open, setOpen }: TAddModal) => {
  const { data: countries } = useGetAllCountryQuery(undefined);
  const [addState] = useAddStateMutation();

  const countryItems = countries?.data?.map((item) => ({
    value: item.id,
    label: item.country_name,
  }));

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    await handleAsyncToast({
      promise: addState(values).unwrap(),
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
          state_name: "",
          country_id: "",
          status: 1,
        }}
        resolver={zodResolver(AddStateValidation)}
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
            <RCInput name="state_name" label="State Name" />
          </Grid>
        </Grid>
        <Stack direction="row" justifyContent="end" mt={4}>
          <Button type="submit">Submit</Button>
        </Stack>
      </RCForm>
    </RCModal>
  );
};

export default AddStateModal;
