import { Button, Grid, Stack } from "@mui/material";
import { TPage } from "../../../types";
import RCForm from "../../form/RCForm";
import RCModal from "../../modal/RCModal";
import RCInput from "../../form/RCInput";
import Editor from "../../editor/Editor";
import { FieldValues, SubmitHandler } from "react-hook-form";
import { useState } from "react";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import objectToFormData from "../../../utils/objectToFormData";
import { useUpdatePageMutation } from "../../../redux/features/pages/pagesApi";

type TProps = {
  open: boolean;
  setOpen: React.Dispatch<React.SetStateAction<boolean>>;
  data: TPage;
};

const UpdatePageModal = ({ data, open, setOpen }: TProps) => {
  const [fullDescription, setFullDescription] = useState(data.content);
  const [updatePage] = useUpdatePageMutation();

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    values.content = fullDescription;
    const formData = objectToFormData(values);
    await handleAsyncToast({
      promise: updatePage({ id: data.id, data: formData }).unwrap(),
      success: () => {
        setOpen(false);
        return "Page updated successfully!";
      },
    });
  };

  return (
    <RCModal open={open} setOpen={setOpen} maxWidth="md" title={data.title}>
      <RCForm onSubmit={onSubmit} defaultValues={{ title: data.title }}>
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

export default UpdatePageModal;
