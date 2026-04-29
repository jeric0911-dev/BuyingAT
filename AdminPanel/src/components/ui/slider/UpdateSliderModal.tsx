import { FieldValues, SubmitHandler } from "react-hook-form";
import { useUpdateSliderMutation } from "../../../redux/features/others/othersApi";
import { TSlider } from "../../../types";
import RCModal from "../../modal/RCModal";
import objectToFormData from "../../../utils/objectToFormData";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import RCForm from "../../form/RCForm";
import { zodResolver } from "@hookform/resolvers/zod";
import { UpdateSliderValidation } from "../../../schemas";
import { Button, Grid, Stack } from "@mui/material";
import RCFileUploader from "../../form/RCFileUploader";
import RCInput from "../../form/RCInput";

type TProps = {
  open: boolean;
  setOpen: React.Dispatch<React.SetStateAction<boolean>>;
  data: TSlider;
};

const UpdateSliderModal = ({ data, open, setOpen }: TProps) => {
  const [updateSlider] = useUpdateSliderMutation();

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    const formData = objectToFormData(values);
    await handleAsyncToast({
      promise: updateSlider({ id: data.id, data: formData }).unwrap(),
      success: () => {
        return "Item updated successfully!";
      },
    });
    setOpen(false);
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Update Slider">
      <RCForm
        onSubmit={onSubmit}
        defaultValues={{
          img: undefined,
          link: data.link,
        }}
        resolver={zodResolver(UpdateSliderValidation)}
      >
        <Grid container spacing={2}>
          <Grid item xs={12}>
            <RCFileUploader name="img" label="Image" />
          </Grid>
          <Grid item xs={12}>
            <RCInput name="link" label="Link" type="url" />
          </Grid>
        </Grid>
        <Stack direction="row" justifyContent="end" mt={4}>
          <Button type="submit">Submit</Button>
        </Stack>
      </RCForm>
    </RCModal>
  );
};

export default UpdateSliderModal;
