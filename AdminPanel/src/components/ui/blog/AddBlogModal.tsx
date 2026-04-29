import { Button, Grid, Stack } from "@mui/material";
import RCForm from "../../form/RCForm";
import RCModal from "../../modal/RCModal";
import { useAddBlogMutation } from "../../../redux/features/blog/blogApi";
import { FieldValues, SubmitHandler } from "react-hook-form";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import objectToFormData from "../../../utils/objectToFormData";
import RCInput from "../../form/RCInput";
import RCFileUploader from "../../form/RCFileUploader";
import Editor from "../../editor/Editor";
import { useState } from "react";
import { useGetAllBlogCategoryQuery } from "../../../redux/features/blogCategory/blogCategoryApi";
import RCSelect, { TItem } from "../../form/RCSelect";
import { zodResolver } from "@hookform/resolvers/zod";
import { AddBlogValidation } from "../../../schemas";
import { TAddModal } from "../../../types";

const defaultValues = {
  blog_title: "",
  keyword: "",
  meta_description: "",
  blog_category_id: 0,
  cover_img: undefined,
  blog_thumb_img: undefined,
};

const AddBlogModal = ({ open, setOpen }: TAddModal) => {
  const { data } = useGetAllBlogCategoryQuery(undefined);
  const [addBlog] = useAddBlogMutation();
  const [fullDescription, setFullDescription] = useState("");

  const categoryItems = data?.data.map((item) => ({
    label: item.name,
    value: item.id,
  }));

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    values.blog_content = fullDescription;
    const formData = objectToFormData(values);
    handleAsyncToast({
      promise: addBlog(formData).unwrap(),
      success: () => {
        return "Blog added successfully!";
      },
    });
    setOpen(false);
  };

  return (
    <RCModal open={open} setOpen={setOpen} maxWidth="md" title="Add Blog">
      <RCForm
        onSubmit={onSubmit}
        defaultValues={defaultValues}
        resolver={zodResolver(AddBlogValidation)}
      >
        <Grid container spacing={2}>
          <Grid item xs={12}>
            <RCSelect
              name="blog_category_id"
              label="Category"
              items={categoryItems as TItem[]}
            />
          </Grid>
          <Grid item xs={12}>
            <RCInput name="blog_title" label="Title" />
          </Grid>
          <Grid item xs={12}>
            <RCFileUploader name="blog_thumb_img" label="Thumb Image" />
          </Grid>
          <Grid item xs={12}>
            <RCFileUploader name="cover_img" label="Cover Image" />
          </Grid>
          <Grid item xs={12}>
            <RCInput name="meta_description" label="Meta Description" />
          </Grid>
          <Grid item xs={12}>
            <RCInput name="keyword" label="Meta Keyword" />
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

export default AddBlogModal;
