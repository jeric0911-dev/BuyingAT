import { FieldValues, SubmitHandler } from "react-hook-form";
import { useAddCurrencyMutation } from "../../../redux/features/currency/currencyApi";
import { TAddModal } from "../../../types";
import RCForm from "../../form/RCForm";
import RCModal from "../../modal/RCModal";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import { zodResolver } from "@hookform/resolvers/zod";
import { Button, Grid, Stack } from "@mui/material";
import RCInput from "../../form/RCInput";
import { AddCurrencyValidation } from "../../../schemas";

const AddCurrencyModal = ({ open, setOpen }: TAddModal) => {
  const [addCurrency] = useAddCurrencyMutation();

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    values.status = 1;
    await handleAsyncToast({
      promise: addCurrency(values).unwrap(),
      success: () => {
        return "Currency added successfully!";
      },
    });
    setOpen(false);
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Add Category">
      <RCForm
        onSubmit={onSubmit}
        defaultValues={{
          currency_code: "",
          currency_symbol: "",
          value: "",
        }}
        resolver={zodResolver(AddCurrencyValidation)}
      >
        <Grid container spacing={2}>
          <Grid item xs={12}>
            <RCInput name="currency_code" label="Currency" />
          </Grid>
          <Grid item xs={12}>
            <RCInput name="currency_symbol" label="Symbol" />
          </Grid>
          <Grid item xs={12}>
            <RCInput type="number" name="value" label="USD To Rate" />
          </Grid>
        </Grid>
        <Stack direction="row" justifyContent="end" mt={4}>
          <Button type="submit">Submit</Button>
        </Stack>
      </RCForm>
    </RCModal>
  );
};

export default AddCurrencyModal;
