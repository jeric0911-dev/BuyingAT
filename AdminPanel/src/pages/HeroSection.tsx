import { FieldValues, SubmitHandler } from "react-hook-form";
import {
  useAddUpdateHeroSectionMutation,
  useGetHeroSectionQuery,
} from "../redux/features/frontend/heroSectionApi";
import objectToFormData from "../utils/objectToFormData";
import handleAsyncToast from "../utils/handleAsyncToast";
import HeaderTitle from "../components/seo/HeaderTitle";
import PageTitle from "../components/ui/shared/PageTitle";
import { Box, Button, CircularProgress, Grid, Stack } from "@mui/material";
import RCForm from "../components/form/RCForm";
import RCFileUploader from "../components/form/RCFileUploader";
import RCInput from "../components/form/RCInput";
import { zodResolver } from "@hookform/resolvers/zod";
import { UpdateHeroValidation } from "../schemas";
import GetPermission from "../utils/getPermission";
import { TPermissions } from "../types";
import { toast } from "sonner";

const HeroSection = () => {
  const { data, isFetching } = useGetHeroSectionQuery(undefined);
  const [update] = useAddUpdateHeroSectionMutation();
  const { edit } = GetPermission("hero-section") as TPermissions;

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    if (!edit) {
      toast.error("You don't have permission");
    } else {
      const formData = objectToFormData(values);
      handleAsyncToast({
        promise: update(formData).unwrap(),
        success: () => {
          return "Hero section updated successfully!";
        },
      });
    }
  };

  return (
    <>
      <HeaderTitle title="Hero Section" />
      <PageTitle title="Hero Section" />
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
            defaultValues={{
              banner: undefined,
              hero_title: data?.data.hero_title,
              hero_description: data?.data.hero_description,
            }}
            resolver={zodResolver(UpdateHeroValidation)}
          >
            <Grid container spacing={2} mt={1}>
              <Grid item xs={12}>
                <img
                  src={`${import.meta.env.VITE_IMG_URL}/${data?.data?.banner}`}
                  alt="banner image"
                  style={{ height: 150, width: "auto" }}
                />
                <RCFileUploader name="banner" label="Banner" />
              </Grid>
              <Grid item xs={12}>
                <RCInput name="hero_title" label="Hero Title" />
              </Grid>
              <Grid item xs={12}>
                <RCInput name="hero_description" label="Hero Description" />
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

export default HeroSection;
