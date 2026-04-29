import { Checkbox, SxProps } from "@mui/material";
import { Controller, useFormContext } from "react-hook-form";

type TCheckProps = {
  name: string;
  size?: "small" | "medium" | "large";
  sx?: SxProps;
};

const RCCheck = ({ name, size, sx }: TCheckProps) => {
  const { control } = useFormContext();

  return (
    <Controller
      name={name}
      control={control}
      render={({ field }) => (
        <Checkbox
          {...field}
          sx={{ ...sx }}
          size={size || "small"}
          checked={!!field.value}
        />
      )}
    />
  );
};

export default RCCheck;
