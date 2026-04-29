import { Box, Button, CircularProgress, Grid, Stack } from "@mui/material";
import handleAsyncToast from "../utils/handleAsyncToast";
import HeaderTitle from "../components/seo/HeaderTitle";
import PageTitle from "../components/ui/shared/PageTitle";
import {
  useAddUpdateFooterMutation,
  useGetFooterQuery,
} from "../redux/features/frontend/footerApi";
import { FieldValues, SubmitHandler } from "react-hook-form";
import objectToFormData from "../utils/objectToFormData";
import RCForm from "../components/form/RCForm";
import RCFileUploader from "../components/form/RCFileUploader";
import RCInput from "../components/form/RCInput";
import { zodResolver } from "@hookform/resolvers/zod";
import { UpdateFooterValidation } from "../schemas";
import GetPermission from "../utils/getPermission";
import { TPermissions } from "../types";
import { toast } from "sonner";

const Footer = () => {
  const { data, isFetching } = useGetFooterQuery(undefined);
  const [update] = useAddUpdateFooterMutation();
  const { edit } = GetPermission("footer") as TPermissions;

  const defaultData = {
    footer_logo: undefined,
    number: data?.data.number,
    address: data?.data.address,
    mail: data?.data.mail,
    copyright: data?.data.copyright,
    google_play: data?.data.google_play,
    app_store: data?.data.app_store,
  };

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    if (!edit) {
      toast.error("You don't have permission");
    } else {
      const formData = objectToFormData(values);
      await handleAsyncToast({
        promise: update(formData).unwrap(),
        success: () => {
          return "Footer updated successfully!";
        },
      });
    }
  };

  return (
    <>
      <HeaderTitle title="Footer" />
      <PageTitle title="Footer" />
      <Box
        p={3}
        bgcolor="white"
        mt={3}
        borderRadius="8px"
        border="1px solid #E0E2E7"
      >
        {!isFetching ? (
          <RCForm
            onSubmit={onSubmit}
            defaultValues={defaultData}
            resolver={zodResolver(UpdateFooterValidation)}
          >
            <Grid container spacing={2} mt={1}>
              <Grid item xs={12}>
                <img
                  src={`${import.meta.env.VITE_IMG_URL}/${
                    data?.data?.footer_logo
                  }`}
                  alt="footer logo"
                  style={{ maxHeight: 150, width: "auto" }}
                />
                <RCFileUploader name="footer_logo" label="Footer Logo" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="number" label="Number" type="tel" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="address" label="Address" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="mail" label="Mail" type="email" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="copyright" label="Copyright" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="google_play" label="Google Play" type="link" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="app_store" label="App Store" type="link" />
              </Grid>
            </Grid>
            <Stack direction="row" justifyContent="end" mt={4}>
              <Button type="submit">Save Changes</Button>
            </Stack>
          </RCForm>
        ) : (
          <CircularProgress size={30} sx={{ mt: 1 }} />
        )}
      </Box>
    </>
  );
};

export default Footer;
