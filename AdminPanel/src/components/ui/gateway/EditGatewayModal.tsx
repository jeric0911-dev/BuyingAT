import { FieldValues, SubmitHandler } from "react-hook-form";
import { useEditGatewayMutation } from "../../../redux/features/settings/settingsApi";
import { TGateway, TUpdateModal } from "../../../types";
import RCModal from "../../modal/RCModal";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import RCForm from "../../form/RCForm";
import { Button, Grid, Stack } from "@mui/material";
import RCInput from "../../form/RCInput";
import RCSelect from "../../form/RCSelect";
import { useGetCurrenciesQuery } from "../../../redux/features/currency/currencyApi";
import RCAutocompleteSelect from "../../form/RcAutocompleteSelect";

const EditGatewayModal = ({ data, open, setOpen }: TUpdateModal<TGateway>) => {
  const { data: currencies } = useGetCurrenciesQuery(undefined);
  const [update] = useEditGatewayMutation();
  const currencyOptions =
    currencies?.data?.map((currency) => ({
      label: currency.currency_code,
      value: currency.currency_code,
    })) || [];

  const gatewayParameters =
    data?.gateway_parameters && JSON.parse(data?.gateway_parameters);
  const fields = gatewayParameters && Object.keys(gatewayParameters);
  const supportedCurrencies = data?.supported_currencies
    ? Object.values(JSON.parse(data.supported_currencies)).map((val) => ({
        label: val,
        value: val,
      }))
    : [];

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    values.supported_currencies = values.supported_currencies?.reduce(
      (acc: any, curr: any) => {
        acc[curr.value] = curr.value;
        return acc;
      },
      {}
    );
    handleAsyncToast({
      promise: update({ alias: data.alias, data: values }).unwrap(),
      success: () => "Gateway updated successfully!",
    });
    setOpen(false);
  };

  return (
    <RCModal open={open} setOpen={setOpen} title={data?.gateway_name}>
      <RCForm
        onSubmit={onSubmit}
        defaultValues={{
          ...gatewayParameters,
          status: data.status,
          supported_currencies: supportedCurrencies,
        }}
      >
        <Grid container spacing={2}>
          {fields?.map((item: string) => (
            <Grid key={item} item xs={12}>
              <RCInput name={item} label={item} />
            </Grid>
          ))}
          <Grid item xs={12}>
            <RCSelect
              name="status"
              label="Status"
              items={[
                { label: "Active", value: 1 },
                { label: "Inactive", value: 0 },
              ]}
            />
          </Grid>
          <Grid item xs={12}>
            <RCAutocompleteSelect
              name="supported_currencies"
              label="Currencies"
              options={currencyOptions}
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

export default EditGatewayModal;
