import { MenuItem, SxProps, TextField } from "@mui/material";
import { Controller, useFormContext } from "react-hook-form";

export type TItem = {
  label: string;
  value: any
};

type TSelectProps = {
  items: TItem[];
  name: string;
  label: string;
  placeholder?: string;
  required?: boolean;
  readOnly?: boolean;
  size?: "small" | "medium";
  sx?: SxProps;
};

const RCSelect = ({ items, name, label, size, required, readOnly, sx }: TSelectProps) => {
  const { control, formState } = useFormContext();
  const isError = formState.errors[name] !== undefined;

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
          inputProps={{readOnly: readOnly}}
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

export default RCSelect;
