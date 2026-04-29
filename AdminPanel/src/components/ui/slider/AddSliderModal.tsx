import { FieldValues, SubmitHandler } from "react-hook-form";
import RCForm from "../../form/RCForm";
import RCModal from "../../modal/RCModal";
import objectToFormData from "../../../utils/objectToFormData";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import { zodResolver } from "@hookform/resolvers/zod";
import { AddSliderValidation } from "../../../schemas";
import { Button, Grid, Stack } from "@mui/material";
import RCInput from "../../form/RCInput";
import RCFileUploader from "../../form/RCFileUploader";
import { useAddSliderMutation } from "../../../redux/features/frontend/advertisementApi";

type TProps = {
  open: boolean;
  setOpen: React.Dispatch<React.SetStateAction<boolean>>;
};

const AddSliderModal = ({ open, setOpen }: TProps) => {
  const [addSlider] = useAddSliderMutation();

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    const formData = objectToFormData(values);
    await handleAsyncToast({
      promise: addSlider(formData).unwrap(),
      success: () => {
        return "Item added successfully!";
      },
    });
    setOpen(false);
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Add Slider">
      <RCForm
        onSubmit={onSubmit}
        defaultValues={{
          img: undefined,
          link: "",
        }}
        resolver={zodResolver(AddSliderValidation)}
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

export default AddSliderModal;
