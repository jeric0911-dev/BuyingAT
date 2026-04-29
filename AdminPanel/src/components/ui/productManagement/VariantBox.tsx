import { Box, Typography } from "@mui/material";
import { TProduct } from "../../../types";

const VariantBox = ({ variants }: { variants: TProduct["variants"] }) => {
  return (
    <Box>
      <Typography variant="body2" fontWeight={500}>
        Variants
      </Typography>

      <Box display="flex" flexDirection="column" gap={2} mt={1.5}>
        {variants?.map((item, i) => (
          <Box
            key={i}
            sx={{
              border: "1px solid",
              borderColor: "divider",
              borderRadius: 2,
              p: 2,
              display: "flex",
              flexDirection: "column",
              gap: 0.5,
              backgroundColor: "background.paper",
            }}
          >
            <Typography variant="subtitle2" textTransform="capitalize">
              {item.variant_name}
            </Typography>

            <Box display="flex" gap={2} flexWrap="wrap" alignItems="center">
              <Typography variant="body2">
                Price: <strong>${item.price}</strong>
              </Typography>

              <Typography variant="body2" color="primary">
                Discounted: <strong>${item.discounted_price}</strong>
              </Typography>
            </Box>
          </Box>
        ))}
      </Box>
    </Box>
  );
};

export default VariantBox;
