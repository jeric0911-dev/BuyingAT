import { useState } from "react";
import RCModal from "../../modal/RCModal";
import RCForm from "../../form/RCForm";
import { FieldValues, SubmitHandler } from "react-hook-form";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import { Button, Grid, Stack } from "@mui/material";
import RCInput from "../../form/RCInput";
import Editor from "../../editor/Editor";
import { useAddPageMutation } from "../../../redux/features/pages/pagesApi";
import { zodResolver } from "@hookform/resolvers/zod";
import { AddPageValidation } from "../../../schemas";
import objectToFormData from "../../../utils/objectToFormData";

type TProps = {
  open: boolean;
  setOpen: React.Dispatch<React.SetStateAction<boolean>>;
};

const AddPageModal = ({ open, setOpen }: TProps) => {
  const [fullDescription, setFullDescription] = useState("");
  const [addPage] = useAddPageMutation();

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    values.content = fullDescription;
    const formData = objectToFormData(values);
    await handleAsyncToast({
      promise: addPage(formData).unwrap(),
      success: () => {
        setOpen(false);
        return "Page added successfully!";
      },
    });
  };

  return (
    <RCModal open={open} setOpen={setOpen} maxWidth="md" title="Add Page">
      <RCForm
        onSubmit={onSubmit}
        defaultValues={{ title: "" }}
        resolver={zodResolver(AddPageValidation)}
      >
        <Grid container spacing={2}>
          <Grid item xs={12}>
            <RCInput name="title" label="Title" />
          </Grid>
          <Grid item xs={12}>
            <Editor
              fullDescription={fullDescription}
              setFullDescription={setFullDescription}
            />
          </Grid>
        </Grid>
        <Stack direction="row" justifyContent="end" mt={4}>
          <Button type="submit">Submit</Button>
        </Stack>
      </RCForm>
    </RCModal>
  );
};

export default AddPageModal;
