import { Box, Button, CircularProgress, Grid, Stack, Typography } from "@mui/material";
import HeaderTitle from "../components/seo/HeaderTitle";
import PageTitle from "../components/ui/shared/PageTitle";
import {
  useEditGoogleCredentialMutation,
  useGoogleCredentialQuery,
} from "../redux/features/settings/settingsApi";
import { FieldValues, SubmitHandler } from "react-hook-form";
import handleAsyncToast from "../utils/handleAsyncToast";
import RCForm from "../components/form/RCForm";
import { zodResolver } from "@hookform/resolvers/zod";
import { AddGoogleCredentialValidation } from "../schemas";
import RCInput from "../components/form/RCInput";

const SocialCredential = () => {
  const { data: google, isFetching: gf } = useGoogleCredentialQuery(undefined);
  const [editGoogleCredential] = useEditGoogleCredentialMutation();

  const googleSubmit: SubmitHandler<FieldValues> = async (values) => {
    // if (!edit) {
    //   toast.error("You don't have permission");
    // } else {
    // }
    handleAsyncToast({
      promise: editGoogleCredential(values).unwrap(),
      success: () => {
        return "Updated successfully!";
      },
    });
  };

  return (
    <>
      <HeaderTitle title="Social Credentials" />
      <PageTitle title="Social Credentials" />
      <Box
        bgcolor="white"
        border="1px solid #E0E2E7"
        borderRadius={2}
        p={3}
        mt={3}
      >
        <Typography variant="h6" color="GrayText" fontWeight="bold">
          Google Credential
        </Typography>
        {!gf ? (
          <RCForm
            onSubmit={googleSubmit}
            defaultValues={{
              google_client_id: google?.data.google_client_id,
              google_client_secret: google?.data.google_client_secret,
              google_redirect_uri: google?.data.google_redirect_uri,
            }}
            resolver={zodResolver(AddGoogleCredentialValidation)}
          >
            <Grid container spacing={2} mt={1}>
              <Grid item xs={12} md={6}>
                <RCInput name="google_client_id" label="Client ID" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="google_client_secret" label="Client Secret" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="google_redirect_uri" label="Redirect URL" />
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

export default SocialCredential;
