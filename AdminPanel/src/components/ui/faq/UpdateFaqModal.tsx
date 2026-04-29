import { FieldValues, SubmitHandler } from "react-hook-form";
import { useUpdateFaqMutation } from "../../../redux/features/faq/faqApi";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import RCModal from "../../modal/RCModal";
import RCForm from "../../form/RCForm";
import { Button, Grid, Stack } from "@mui/material";
import RCInput from "../../form/RCInput";
import { zodResolver } from "@hookform/resolvers/zod";
import { AddFaqValidation } from "../../../schemas";
import { TFaq, TUpdateModal } from "../../../types";

const UpdateFaqModal = ({ open, setOpen, data }: TUpdateModal<TFaq>) => {
  const [updateFaq] = useUpdateFaqMutation();

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    handleAsyncToast({
      promise: updateFaq({ id: data.id, data: values }).unwrap(),
      success: () => {
        setOpen(false);
        return "Faq updated successfully";
      },
    });
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Update Faq">
      <RCForm
        onSubmit={onSubmit}
        defaultValues={{
          qua: data.qua,
          ans: data.ans,
        }}
        resolver={zodResolver(AddFaqValidation)}
      >
        <Grid container spacing={2}>
          <Grid item xs={12}>
            <RCInput name="qua" label="Question" />
          </Grid>
          <Grid item xs={12}>
            <RCInput name="ans" label="Answer" multiline />
          </Grid>
        </Grid>
        <Stack direction="row" justifyContent="end" mt={4}>
          <Button type="submit">Submit</Button>
        </Stack>
      </RCForm>
    </RCModal>
  );
};

export default UpdateFaqModal;
