import { FieldValues, SubmitHandler } from "react-hook-form";
import HeaderTitle from "../components/seo/HeaderTitle";
import {
  useGetWebSettingsQuery,
  useUpdateWebSettingsMutation,
} from "../redux/features/webSettings/webSettingsApi";
import handleAsyncToast from "../utils/handleAsyncToast";
import objectToFormData from "../utils/objectToFormData";
import PageTitle from "../components/ui/shared/PageTitle";
import {
  Box,
  Button,
  CircularProgress,
  Grid,
  Stack,
  Typography,
} from "@mui/material";
import RCForm from "../components/form/RCForm";
import RCFileUploader from "../components/form/RCFileUploader";
import RCInput from "../components/form/RCInput";
import { zodResolver } from "@hookform/resolvers/zod";
import { WebSettingsValidation } from "../schemas";

const Settings = () => {
  const { data, isFetching } = useGetWebSettingsQuery(undefined);
  const [update] = useUpdateWebSettingsMutation();

  const defaultData = {
    login_page_title: data?.data.login_page_title || "",
    header_title: data?.data.header_title || "",
    web_app_logo: undefined,
    google_analytics_id: data?.data.google_analytics_id || "",
    pixel_id: data?.data.pixel_id || "",
    meta_title: data?.data.meta_title || "",
    meta_description: data?.data.meta_description || "",
    app_base_url: data?.data.app_base_url || "",
    frontend_url: data?.data.frontend_url || "",
    back_end_base_url: data?.data.back_end_base_url || "",
    front_end_base_url: data?.data.front_end_base_url || "",
    fav_icon: undefined,
  };

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    // if (!edit) {
    //   toast.error("You don't have permission");
    // } else {
    const formData = objectToFormData(values);
    await handleAsyncToast({
      promise: update(formData).unwrap(),
      success: () => "Settings updated successfully!",
    });
    // }
  };

  return (
    <div>
      <HeaderTitle title="Settings" />
      <PageTitle title="Settings" />
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
            resolver={zodResolver(WebSettingsValidation)}
          >
            <Typography color="primary" fontWeight="bold" mb={3}>
              General Web Settings
            </Typography>
            <Grid container spacing={2} mt={2}>
              <Grid item xs={12} md={6}>
                <img
                  src={`${import.meta.env.VITE_IMG_URL}/${
                    data?.data.web_app_logo
                  }`}
                  alt="logo"
                  height={40}
                />
                <RCFileUploader
                  name="web_app_logo"
                  label="Web App Logo"
                  sx={{ mt: 1 }}
                />
              </Grid>
              <Grid item xs={12} md={6}>
                <img
                  src={`${import.meta.env.VITE_IMG_URL}/${data?.data.fav_icon}`}
                  alt="fav icon"
                  height={40}
                />
                <RCFileUploader
                  name="fav_icon"
                  label="Fav Icon"
                  sx={{ mt: 1 }}
                />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="login_page_title" label="Login Page Title" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="header_title" label="Header Title" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="meta_title" label="Meta Title" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="meta_description" label="Meta Description" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput
                  name="google_analytics_id"
                  label="Google Analytics Id"
                />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="pixel_id" label="Pixel Id" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="app_base_url" label="Base URL" type="url" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="frontend_url" label="Frontend URL" type="url" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="back_end_base_url" label="Backend URL" type="url" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="front_end_base_url" label="Frontend Base URL" type="url" />
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
    </div>
  );
};

export default Settings;
