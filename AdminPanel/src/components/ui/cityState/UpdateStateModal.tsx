import { FieldValues, SubmitHandler } from "react-hook-form";
import { useUpdateStateMutation } from "../../../redux/features/city-state/cityStateApi";
import { useGetAllCountryQuery } from "../../../redux/features/country/countryApi";
import { TCityState, TUpdateModal } from "../../../types";
import RCForm from "../../form/RCForm";
import RCModal from "../../modal/RCModal";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import { zodResolver } from "@hookform/resolvers/zod";
import { AddStateValidation } from "../../../schemas";
import { Button, Grid, Stack } from "@mui/material";
import RCSelect, { TItem } from "../../form/RCSelect";
import RCInput from "../../form/RCInput";

const UpdateStateModal = ({ data, open, setOpen }: TUpdateModal<TCityState>) => {
  const { data: countries } = useGetAllCountryQuery(undefined);
  const [updateState] = useUpdateStateMutation();

  const countryItems = countries?.data?.map((item) => ({
    value: item.id,
    label: item.country_name,
  }));

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    await handleAsyncToast({
      promise: updateState({ id: data.id, data: values }).unwrap(),
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
          state_name: data.state_name || "",
          country_id: data.country_id || "",
          status: data.status,
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

export default UpdateStateModal;
