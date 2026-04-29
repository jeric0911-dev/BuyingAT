import { MenuItem, SxProps, TextField } from "@mui/material";
import { useEffect } from "react";
import { Controller, useFormContext, useWatch } from "react-hook-form";

type TSelectProps = {
  items: {
    label: string;
    value: string | number;
  }[];
  name: string;
  label: string;
  placeholder?: string;
  required?: boolean;
  size?: "small" | "medium";
  sx?: SxProps;
  onValueChange: React.Dispatch<React.SetStateAction<string>>;
};

const RCSelectWithWatch = ({
  items,
  name,
  label,
  size,
  required,
  sx,
  onValueChange,
}: TSelectProps) => {
  const { control, formState } = useFormContext();
  const isError = formState.errors[name] !== undefined;

  const inputValue = useWatch({
    control,
    name,
  });

  useEffect(() => {
    onValueChange(inputValue);
  }, [inputValue, onValueChange]);

  return (
    <Controller
      control={control}
      name={name}
      render={({ field }) => (
        <TextField
          {...field}
          sx={{
            ...sx,
            "& .MuiInputBase-input": { fontSize: "14px", py: "7px" },
          }}
          InputLabelProps={{ style: { fontSize: "14px" } }}
          select
          size={size || "small"}
          label={label}
          required={required}
          fullWidth={true}
          error={isError}
          helperText={
            isError ? (formState.errors[name]?.message as string) : ""
          }
        >
          {items.map(({ label, value }) => (
            <MenuItem key={label} value={value}>
              {label}
            </MenuItem>
          ))}
        </TextField>
      )}
    />
  );
};

export default RCSelectWithWatch;
