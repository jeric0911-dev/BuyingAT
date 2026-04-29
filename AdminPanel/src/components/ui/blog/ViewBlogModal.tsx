import { Box, Typography } from "@mui/material";
import { TBlog, TUpdateModal } from "../../../types";
import RCModal from "../../modal/RCModal";

const ViewBlogModal = ({ data, open, setOpen }: TUpdateModal<TBlog>) => {
  return (
    <RCModal open={open} setOpen={setOpen} title="Blog Details" maxWidth="md">
      <img
        src={`${import.meta.env.VITE_IMG_URL}/${data?.blog_thumb_img}`}
        alt=""
        style={{
          width: "100%",
          height: "250px",
          objectFit: "cover",
          borderRadius: "16px",
        }}
      />
      <Typography variant="h6">{data.blog_title}</Typography>
      <Box mt={3} dangerouslySetInnerHTML={{ __html: data.blog_content }} />
    </RCModal>
  );
};

export default ViewBlogModal;
