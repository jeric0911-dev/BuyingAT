import { SxProps } from "@mui/material";
import { DatePicker } from "@mui/x-date-pickers";
import dayjs from "dayjs";
import { Controller, useFormContext } from "react-hook-form";

type TProps = {
  name: string;
  label: string;
  size?: "small" | "medium";
  disablePast?: boolean;
  disableFuture?: boolean;
  variant?: "outlined" | "filled";
  sx?: SxProps;
};

const RCDatePicker = ({
  label,
  name,
  size = "small",
  disablePast = false,
  disableFuture = false,
  variant = "outlined",
  sx,
}: TProps) => {
  const { control } = useFormContext();

  return (
    <Controller
      name={name}
      control={control}
      defaultValue={dayjs}
      render={({ field: { onChange, value, ...field } }) => (
        <DatePicker
          {...field}
          label={label}
          timezone="system"
          disableFuture={disableFuture}
          disablePast={disablePast}
          value={value || Date.now()}
          onChange={(date) => onChange(date)}
          slotProps={{
            textField: {
              size,
              variant,
              fullWidth: true,
              sx: {
                ...sx,
                "& .MuiInputBase-input": {
                  fontSize: "14px",
                  fontWeight: "500",
                },
              },
            },
          }}
        />
      )}
    />
  );
};

export default RCDatePicker;
