import { Box, Typography } from "@mui/material";
import { TProduct } from "../../../types";

const SizeBox = ({ sizes }: { sizes: TProduct["sizes"] }) => {
  return (
    <Box>
      <Typography variant="body2" fontWeight={500}>
        Sizes & Stock
      </Typography>
      <Box display="flex" flexWrap="wrap" gap={2} mt={1.5}>
        {sizes?.map((item, i) => (
          <Box
            key={i}
            sx={{
              border: "1px solid",
              borderColor: "divider",
              borderRadius: 1,
              px: 2,
              py: 1,
              display: "flex",
              flexDirection: "column",
              alignItems: "center",
              minWidth: 70,
            }}
          >
            <Typography variant="button" textTransform="uppercase">
              {item.size}
            </Typography>
          </Box>
        ))}
      </Box>
    </Box>
  );
};

export default SizeBox;
