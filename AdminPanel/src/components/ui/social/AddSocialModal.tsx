import { FieldValues, SubmitHandler } from "react-hook-form";
import { useAddSocialMutation } from "../../../redux/features/social/socialApi";
import objectToFormData from "../../../utils/objectToFormData";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import RCModal from "../../modal/RCModal";
import RCForm from "../../form/RCForm";
import { zodResolver } from "@hookform/resolvers/zod";
import { AddSocialValidation } from "../../../schemas";
import { Button, Grid, Stack } from "@mui/material";
import RCInput from "../../form/RCInput";
import RCFileUploader from "../../form/RCFileUploader";

type TProps = {
  open: boolean;
  setOpen: React.Dispatch<React.SetStateAction<boolean>>;
};

const AddSocialModal = ({ open, setOpen }: TProps) => {
  const [addSocial] = useAddSocialMutation();

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    const formData = objectToFormData(values);
    await handleAsyncToast({
      promise: addSocial(formData).unwrap(),
      success: () => {
        setOpen(false);
        return "Item added successfully!";
      },
    });
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Add Social">
      <RCForm
        onSubmit={onSubmit}
        defaultValues={{ link: "", icon: undefined }}
        resolver={zodResolver(AddSocialValidation)}
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

export default AddSocialModal;
