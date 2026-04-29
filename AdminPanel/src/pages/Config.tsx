import {
  Box,
  Button,
  CircularProgress,
  Grid,
  Stack,
  Typography,
} from "@mui/material";
import HeaderTitle from "../components/seo/HeaderTitle";
import PageTitle from "../components/ui/shared/PageTitle";
import { FieldValues, SubmitHandler } from "react-hook-form";
import handleAsyncToast from "../utils/handleAsyncToast";
import RCForm from "../components/form/RCForm";
import RCInput from "../components/form/RCInput";
import {
  useEditMailConfigMutation,
  useEditPusherConfigMutation,
  useGetMailConfigQuery,
  useGetPusherConfigQuery,
} from "../redux/features/settings/settingsApi";
import GetPermission from "../utils/getPermission";
import { TPermissions } from "../types";
import { toast } from "sonner";

const Config = () => {
  const { data: mailConfig, isFetching: mailFetching } =
    useGetMailConfigQuery(undefined);
  const { data: pusherConfig, isFetching: pusherFetching } =
    useGetPusherConfigQuery(undefined);
  const [updateMail] = useEditMailConfigMutation();
  const [updatePusher] = useEditPusherConfigMutation();
  const { edit } = GetPermission("configs") as TPermissions;

  const onMailSubmit: SubmitHandler<FieldValues> = async (values) => {
    if (!edit) {
      toast.error("You don't have permission");
    } else {
      handleAsyncToast({
        promise: updateMail(values).unwrap(),
        success: () => {
          return "Updated successfully!";
        },
      });
    }
  };
  const onPusherSubmit: SubmitHandler<FieldValues> = async (values) => {
    if (!edit) {
      toast.error("You don't have permission");
    } else {
      handleAsyncToast({
        promise: updatePusher(values).unwrap(),
        success: () => {
          return "Updated successfully!";
        },
      });
    }
  };

  return (
    <>
      <HeaderTitle title="Credentials" />
      <PageTitle title="Credentials" />
      <Box
        bgcolor="white"
        border="1px solid #E0E2E7"
        borderRadius={2}
        p={3}
        mt={3}
      >
        <Typography variant="h6" color="GrayText" fontWeight="bold">
          Mail Config
        </Typography>
        {!mailFetching ? (
          <RCForm
            onSubmit={onMailSubmit}
            defaultValues={{
              host: mailConfig?.data.host,
              encryption: mailConfig?.data.encryption,
              mail_from_address: mailConfig?.data.mail_from_address,
              mail_from_name: mailConfig?.data.mail_from_name,
              mailer: mailConfig?.data.mailer,
              password: mailConfig?.data.password,
              port: mailConfig?.data.port,
              username: mailConfig?.data.username,
            }}
          >
            <Grid container spacing={2} mt={1}>
              <Grid item xs={12} md={6}>
                <RCInput name="mailer" label="Mailer" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="host" label="Host" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="port" label="Port" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="username" label="User Name" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="password" label="Password" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="encryption" label="Encryption" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="mail_from_address" label="Mail From Address" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="mail_from_name" label="Mail From Name" />
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
      <Box
        bgcolor="white"
        border="1px solid #E0E2E7"
        borderRadius={2}
        p={3}
        mt={3}
      >
        <Typography variant="h6" color="GrayText" fontWeight="bold">
          Pusher Config
        </Typography>
        {!pusherFetching ? (
          <RCForm
            onSubmit={onPusherSubmit}
            defaultValues={{
              pusher_app_cluster: pusherConfig?.data.pusher_app_cluster,
              pusher_app_id: pusherConfig?.data.pusher_app_id,
              pusher_app_key: pusherConfig?.data.pusher_app_key,
              pusher_app_secret: pusherConfig?.data.pusher_app_secret,
              pusher_host: pusherConfig?.data.pusher_host,
              pusher_port: pusherConfig?.data.pusher_port,
              pusher_scheme: pusherConfig?.data.pusher_scheme,
            }}
          >
            <Grid container spacing={2} mt={1}>
              <Grid item xs={12} md={6}>
                <RCInput name="pusher_app_id" label="App ID" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="pusher_app_key" label="App Key" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="pusher_app_secret" label="App Secret" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="pusher_host" label="Host" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="pusher_port" label="Port" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="pusher_scheme" label="Scheme" />
              </Grid>
              <Grid item xs={12} md={6}>
                <RCInput name="pusher_app_cluster" label="App Cluster" />
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

export default Config;
