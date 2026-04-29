import { FieldValues, SubmitHandler } from "react-hook-form";
import { useUpdateSocialMutation } from "../../../redux/features/social/socialApi";
import { TSocial } from "../../../types";
import RCForm from "../../form/RCForm";
import RCModal from "../../modal/RCModal";
import objectToFormData from "../../../utils/objectToFormData";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import { zodResolver } from "@hookform/resolvers/zod";
import { UpdateSocialValidation } from "../../../schemas";
import { Button, Grid, Stack } from "@mui/material";
import RCInput from "../../form/RCInput";
import RCFileUploader from "../../form/RCFileUploader";

type TProps = {
  open: boolean;
  setOpen: React.Dispatch<React.SetStateAction<boolean>>;
  data: TSocial;
};

const UpdateSocialModal = ({ open, setOpen, data }: TProps) => {
  const [updateSocial] = useUpdateSocialMutation();

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    const formData = objectToFormData(values);
    await handleAsyncToast({
      promise: updateSocial({ id: data.id, data: formData }).unwrap(),
      success: () => {
        return "Item updated successfully!";
      },
    });
    setOpen(false);
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Update Social">
      <RCForm
        onSubmit={onSubmit}
        defaultValues={{ link: data.link, icon: undefined }}
        resolver={zodResolver(UpdateSocialValidation)}
      >
        <Grid container spacing={2}>
          <Grid item xs={12}>
            <RCInput name="link" label="Link" />
          </Grid>
          <Grid item xs={12}>
            <RCFileUploader name="icon" label="Icon" />
          </Grid>
        </Grid>
        <Stack direction="row" justifyContent="end" mt={4}>
          <Button type="submit">Submit</Button>
        </Stack>
      </RCForm>
    </RCModal>
  );
};

export default UpdateSocialModal;
