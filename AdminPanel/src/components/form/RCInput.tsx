import { SxProps, TextField } from "@mui/material";
import { Controller, useFormContext } from "react-hook-form";

type TInputProps = {
  name: string;
  label: string;
  type?: string;
  size?: "small" | "medium";
  placeholder?: string;
  required?: boolean;
  multiline?: boolean;
  rows?: number;
  readOnly?: boolean;
  variant?: "standard" | "outlined" | "filled";
  sx?: SxProps;
};

const RCInput = ({
  name,
  label,
  type,
  size,
  placeholder,
  required,
  variant,
  multiline,
  readOnly,
  rows,
  sx,
}: TInputProps) => {
  const { control } = useFormContext();

  return (
    <Controller
      control={control}
      name={name}
      render={({ field, fieldState: { error } }) => (
        <TextField
          {...field}
          onChange={(e) => {
            const value =
              type === "number" ? parseFloat(e.target.value) : e.target.value;
            field.onChange(value);
          }}
          sx={{
            ...sx,
            "& .MuiInputBase-input": { fontSize: "14px" },
          }}
          InputLabelProps={{ style: { fontSize: "14px" } }}
          label={label}
          multiline={multiline}
          rows={rows}
          type={type || "text"}
          variant={variant || "outlined"}
          size={size || "small"}
          fullWidth={true}
          placeholder={placeholder}
          required={required}
          inputProps={{ readOnly }}
          error={!!error?.message}
          helperText={error?.message}
        />
      )}
    />
  );
};

export default RCInput;
