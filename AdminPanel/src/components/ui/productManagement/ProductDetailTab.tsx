import { Box, Tabs, Tab, Typography } from "@mui/material";
import { useState } from "react";
import { TProduct } from "../../../types";
import KeyValueDisplay from "./KeyValueDisplay";
import getParsedJson from "../../../utils/getParsedJson";

const tabLabels = ["Description", "Specification", "Additional Information"];

const ProductDetailTab = ({ data }: { data: TProduct }) => {
  const [value, setValue] = useState(0);

  const handleChange = (_event: React.SyntheticEvent, newValue: number) => {
    setValue(newValue);
  };

  return (
    <Box mt={4} border={1} borderColor="divider" borderRadius={1}>
      <Tabs
        value={value}
        onChange={handleChange}
        variant="scrollable"
        scrollButtons
        allowScrollButtonsMobile
        indicatorColor="primary"
        textColor="primary"
        // centered
        sx={{
          borderBottom: 1,
          borderColor: "divider",
          "& .MuiTab-root": {
            fontSize: "0.875rem",
            fontWeight: 500,
            px: 3,
            textTransform: "uppercase",
          },
        }}
      >
        {tabLabels.map((label) => (
          <Tab key={label} label={label} />
        ))}
      </Tabs>

      <Box p={2}>
        {value === 0 && (
          <Typography mt={2} fontSize="0.875rem" color="text.secondary">
            {data?.product_description}
          </Typography>
        )}
        {value === 1 && (
          <KeyValueDisplay
            data={getParsedJson(data?.additional_info?.specification)}
          />
        )}
        {value === 2 && (
          <KeyValueDisplay
            data={getParsedJson(data?.additional_info?.additional_info)}
          />
        )}
      </Box>
    </Box>
  );
};

export default ProductDetailTab;
