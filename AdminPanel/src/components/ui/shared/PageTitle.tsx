import { Typography } from "@mui/material";

const PageTitle = ({ title }: { title: string }) => {
  return (
    <Typography variant="h5" fontWeight="bold" component="h1" color="#2E2F38">
      {title}
    </Typography>
  );
};

export default PageTitle;
