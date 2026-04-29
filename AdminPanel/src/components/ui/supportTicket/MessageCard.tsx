import dayjs from "dayjs";
import { Box, Typography, Avatar } from "@mui/material";
import { Link } from "react-router-dom";
import { TMessage } from "../../../types";
import { AttachmentOutlined } from "@mui/icons-material";

const MessageCard = ({ data }: { data: TMessage }) => {
  const isUser = !!data?.user_id;
  const borderColor = isUser ? "#0EA5E9" : "#E46A11";
  const bgColor = isUser ? "rgba(14,165,233,0.1)" : "rgba(228,106,17,0.1)";
  const textColor = isUser ? "#0EA5E9" : "#E46A11";
  const profileImage = isUser
    ? data?.user?.profile_img
      ? `${import.meta.env.VITE_IMG_URL}/${data?.user?.profile_img}`
      : "/icon/user-mobile.svg"
    : "/icon/user-mobile.svg";

  return (
    <Box
      sx={{
        border: `1px solid ${borderColor}`,
        backgroundColor: bgColor,
        borderRadius: "8px",
        p: 2,
        display: "grid",
        gridTemplateColumns: { xs: "1fr", lg: "200px 1fr" },
        gap: 2,
      }}
    >
      <Box
        sx={{
          display: "flex",
          alignItems: "center",
          gap: 2,
          pr: { lg: 2 },
          borderRight: { lg: `1px solid ${borderColor}` },
        }}
      >
        <Avatar
          src={profileImage}
          sx={{
            width: 34,
            height: 34,
            border: `2px solid ${borderColor}`,
          }}
        />
        <Typography variant="h6" fontSize="1.25rem" sx={{ color: textColor }}>
          {isUser ? data?.user?.name : "Admin"}
        </Typography>
      </Box>

      <Box sx={{ pl: { lg: 2 } }}>
        <Typography variant="body2" fontWeight={600} color="#3B3B3B" mb={1}>
          Posted on{" "}
          {dayjs(data?.created_at).format("dddd, D MMMM YYYY [@] hh:mm A")}
        </Typography>

        <Typography variant="body2" color="#555555">
          {data?.message}
        </Typography>

        {Array.isArray(data?.attachments) &&
          data.attachments.length > 0 &&
          data.attachments.map((item, index) => (
            <Link
              key={item.id}
              to={`${import.meta.env.VITE_IMG_URL}/${item.file}`}
              target="_blank"
              rel="noopener noreferrer"
              style={{
                display: "flex",
                alignItems: "center",
                marginTop: "8px",
                color: "#0EA5E9",
                textDecoration: "none",
              }}
            >
              <AttachmentOutlined
                sx={{ color: `${isUser ? "primary.main" : "#E46A11"}` }}
              />
              <Typography variant="body2" ml={1} sx={{ color: "#0EA5E9" }}>
                Attachment {index + 1}
              </Typography>
            </Link>
          ))}
      </Box>
    </Box>
  );
};

export default MessageCard;
