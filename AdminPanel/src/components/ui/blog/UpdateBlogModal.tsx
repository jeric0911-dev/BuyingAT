import { FieldValues, SubmitHandler } from "react-hook-form";
import { useUpdateBlogMutation } from "../../../redux/features/blog/blogApi";
import { TBlog, TUpdateModal } from "../../../types";
import RCForm from "../../form/RCForm";
import RCModal from "../../modal/RCModal";
import objectToFormData from "../../../utils/objectToFormData";
import handleAsyncToast from "../../../utils/handleAsyncToast";
import { Button, Grid, Stack } from "@mui/material";
import RCInput from "../../form/RCInput";
import RCFileUploader from "../../form/RCFileUploader";
import Editor from "../../editor/Editor";
import { useState } from "react";
import { useGetAllBlogCategoryQuery } from "../../../redux/features/blogCategory/blogCategoryApi";
import RCSelect, { TItem } from "../../form/RCSelect";
import { zodResolver } from "@hookform/resolvers/zod";
import { UpdateBlogValidation } from "../../../schemas";

const UpdateBlogModal = ({ data, open, setOpen }: TUpdateModal<TBlog>) => {
  const { data: categories } = useGetAllBlogCategoryQuery(undefined);
  const [updateBlog] = useUpdateBlogMutation();
  const [fullDescription, setFullDescription] = useState(data.blog_content);

  const categoryItems = categories?.data.map((item) => ({
    label: item.name,
    value: item.id,
  }));

  const defaultValues = {
    blog_title: data.blog_title || "",
    keyword: data.keyword || "",
    meta_description: data.meta_description || "",
    blog_category_id: data.blog_category_id || 0,
    cover_img: undefined,
    blog_thumb_img: undefined,
  };

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    values.blog_content = fullDescription;
    const formData = objectToFormData(values);
    handleAsyncToast({
      promise: updateBlog({ id: data.id, data: formData }).unwrap(),
      success: () => {
        setOpen(false);
        return "Blog updated successfully!";
      },
    });
  };

  return (
    <RCModal open={open} setOpen={setOpen} title="Update Blog" maxWidth="md">
      <RCForm
        onSubmit={onSubmit}
        defaultValues={defaultValues}
        resolver={zodResolver(UpdateBlogValidation)}
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

export default UpdateBlogModal;
