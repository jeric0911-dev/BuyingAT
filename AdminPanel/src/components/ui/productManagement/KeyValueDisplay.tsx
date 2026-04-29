import { Box, Typography } from "@mui/material";

const KeyValueDisplay = ({ data }: any) => {
  return (
    <>
      {data?.map((item: any, i: any) => {
        const key = Object.keys(item)[0];
        const value = item[key];
        return (
          <Box
            key={i}
            sx={{
              display: "grid",
              gridTemplateColumns: "2fr 2px 3fr",
              gap: 2,
              py: 1,
              borderTop: "1px dashed",
              borderColor: "divider",
              "&:last-child": {
                borderBottom: "1px dashed",
                borderColor: "divider",
              },
            }}
          >
            <Typography variant="body2" color="text.primary">
              {key}
            </Typography>
            <Typography variant="body2">:</Typography>
            <Typography variant="body2" color="text.secondary">
              {value}
            </Typography>
          </Box>
        );
      })}
    </>
  );
};

export default KeyValueDisplay;
