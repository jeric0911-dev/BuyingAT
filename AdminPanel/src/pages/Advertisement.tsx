import { FieldValues, SubmitHandler } from "react-hook-form";
import {
  useAddAdvertisementMutation,
  useGetAdvertisementQuery,
} from "../redux/features/frontend/advertisementApi";
import objectToFormData from "../utils/objectToFormData";
import handleAsyncToast from "../utils/handleAsyncToast";
import HeaderTitle from "../components/seo/HeaderTitle";
import PageTitle from "../components/ui/shared/PageTitle";
import { Box, Button, CircularProgress, Grid, Stack } from "@mui/material";
import RCForm from "../components/form/RCForm";
import RCInput from "../components/form/RCInput";
import RCFileUploader from "../components/form/RCFileUploader";
import GetPermission from "../utils/getPermission";
import { TPermissions } from "../types";
import { toast } from "sonner";

const Advertisement = () => {
  const { data, isFetching } = useGetAdvertisementQuery(undefined);
  const [update] = useAddAdvertisementMutation();
  const { edit } = GetPermission("advertisement") as TPermissions;

  const defaultData = {
    link_1: data?.data?.link_1 || "",
    link_2: data?.data?.link_2 || "",
    link_3: data?.data?.link_3 || "",
    link_4: data?.data?.link_4 || "",
    link_5: data?.data?.link_5 || "",
    link_6: data?.data?.link_6 || "",
    link_7: data?.data?.link_7 || "",
    link_8: data?.data?.link_8 || "",
    img_1: undefined,
    img_2: undefined,
    img_3: undefined,
    img_4: undefined,
    img_5: undefined,
    img_6: undefined,
    img_7: undefined,
    img_8: undefined,
  };

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    if (!edit) {
      toast.error("You don't have permission");
    } else {
      const formData = objectToFormData(values);
      await handleAsyncToast({
        promise: update(formData).unwrap(),
        success: () => {
          return "Advertisement updated successfully!";
        },
      });
    }
  };

  return (
    <>
      <HeaderTitle title="Advertisement" />
      <PageTitle title="Advertisement" />
      <Box
        p={3}
        bgcolor="white"
        mt={3}
        borderRadius="8px"
        border="1px solid #E0E2E7"
      >
        {!isFetching ? (
          <RCForm onSubmit={onSubmit} defaultValues={defaultData}>
            <Grid container spacing={2} mt={1}>
              <Grid item xs={12} md={6}>
                <img
                  src={`${import.meta.env.VITE_IMG_URL}/${data?.data?.img_1}`}
                  alt="advertisement"
                  style={{ maxHeight: 150, width: "auto" }}
                />
                <RCFileUploader name="img_1" label="Image One" />
                <RCInput
                  name="link_1"
                  label="Link One"
                  type="url"
                  sx={{ mt: 1 }}
                />
              </Grid>
              <Grid item xs={12} md={6}>
                <img
                  src={`${import.meta.env.VITE_IMG_URL}/${data?.data?.img_2}`}
                  alt="advertisement"
                  style={{ maxHeight: 150, width: "auto" }}
                />
                <RCFileUploader name="img_2" label="Image Two" />
                <RCInput
                  name="link_2"
                  label="Link Two"
                  type="url"
                  sx={{ mt: 1 }}
                />
              </Grid>
              <Grid item xs={12} md={6}>
                <img
                  src={`${import.meta.env.VITE_IMG_URL}/${data?.data?.img_3}`}
                  alt="advertisement"
                  style={{ maxHeight: 150, width: "auto" }}
                />
                <RCFileUploader name="img_3" label="Image Three" />
                <RCInput
                  name="link_3"
                  label="Link Three"
                  type="url"
                  sx={{ mt: 1 }}
                />
              </Grid>
              <Grid item xs={12} md={6}>
                <img
                  src={`${import.meta.env.VITE_IMG_URL}/${data?.data?.img_4}`}
                  alt="advertisement"
                  style={{ maxHeight: 150, width: "auto" }}
                />
                <RCFileUploader name="img_4" label="Image Four" />
                <RCInput
                  name="link_4"
                  label="Link Four"
                  type="url"
                  sx={{ mt: 1 }}
                />
              </Grid>
              <Grid item xs={12} md={6}>
                <img
                  src={`${import.meta.env.VITE_IMG_URL}/${data?.data?.img_5}`}
                  alt="advertisement"
                  style={{ maxHeight: 150, width: "auto" }}
                />
                <RCFileUploader name="img_5" label="Image Five" />
                <RCInput
                  name="link_5"
                  label="Link Five"
                  type="url"
                  sx={{ mt: 1 }}
                />
              </Grid>
              <Grid item xs={12} md={6}>
                <img
                  src={`${import.meta.env.VITE_IMG_URL}/${data?.data?.img_6}`}
                  alt="advertisement"
                  style={{ maxHeight: 150, width: "auto" }}
                />
                <RCFileUploader name="img_6" label="Image Six" />
                <RCInput
                  name="link_6"
                  label="Link Six"
                  type="url"
                  sx={{ mt: 1 }}
                />
              </Grid>
              <Grid item xs={12} md={6}>
                <img
                  src={`${import.meta.env.VITE_IMG_URL}/${data?.data?.img_7}`}
                  alt="advertisement"
                  style={{ maxHeight: 150, width: "auto" }}
                />
                <RCFileUploader name="img_7" label="Image Seven" />
                <RCInput
                  name="link_7"
                  label="Link Seven"
                  type="url"
                  sx={{ mt: 1 }}
                />
              </Grid>
              <Grid item xs={12} md={6}>
                <img
                  src={`${import.meta.env.VITE_IMG_URL}/${data?.data?.img_8}`}
                  alt="advertisement"
                  style={{ maxHeight: 150, width: "auto" }}
                />
                <RCFileUploader name="img_8" label="Image Eight" />
                <RCInput
                  name="link_8"
                  label="Link Eight"
                  type="url"
                  sx={{ mt: 1 }}
                />
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

export default Advertisement;
