import { Box, Paper, Typography } from "@mui/material";
import { TProduct } from "../../../types";

const ColorBox = ({ colors }: { colors: TProduct["colors"] }) => {
  return (
    <Box>
      <Typography variant="body2" fontWeight={500}>
        Color
      </Typography>
      <Box display="flex" flexWrap="wrap" gap={2} mt={2}>
        {colors?.map((item, i) => (
          <Paper
            key={i}
            elevation={2}
            sx={{
              display: "flex",
              alignItems: "center",
              gap: 2,
              px: 2,
              py: 1,
              borderRadius: 2,
              minWidth: 180,
            }}
          >
            <Box
              sx={{
                width: 32,
                height: 32,
                borderRadius: "50%",
                backgroundColor: item.color,
                border: "1px solid #ccc",
              }}
            />
            <Box>
              <Typography variant="body2" fontWeight={600}>
                {item.color_name}
              </Typography>
            </Box>
          </Paper>
        ))}
      </Box>
    </Box>
  );
};

export default ColorBox;
