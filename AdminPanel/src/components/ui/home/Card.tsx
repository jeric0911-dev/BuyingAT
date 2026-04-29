import { CircularProgress, Stack, Typography } from "@mui/material";
import { Link } from "react-router-dom";

type TProps = {
  title: string;
  count: number;
  icon: string;
  isFetching: boolean;
  to?: string;
};

const Card = ({ count, icon, title, isFetching, to }: TProps) => {
  const linkProps = to ? { component: Link, to } : {};

  return (
    <Stack
      {...linkProps}
      direction="row"
      alignItems="center"
      gap="24px"
      borderRadius="10px"
      height="116px"
      bgcolor="white"
      pl="30px"
    >
      <img src={icon} alt="" width={60} height={60} />
      <Stack>
        <Typography fontSize="22px" fontWeight={800} color="#585960">
          {isFetching ? <CircularProgress size={16} /> : count}
        </Typography>
        <Typography fontSize="14px" color="#585960">
          {title}
        </Typography>
      </Stack>
    </Stack>
  );
};

export default Card;
