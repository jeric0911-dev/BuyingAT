import { Autocomplete, Chip, SxProps, TextField } from "@mui/material";
import { Controller, useFormContext } from "react-hook-form";

type TRCAutocompleteProps = {
  name: string;
  options?: string[];
  label: string;
  placeholder?: string;
  freeSolo?: boolean;
  variant?: "outlined" | "filled" | "standard";
  size?: "small" | "medium";
  required?: boolean;
  readOnly?: boolean;
  sx?: SxProps;
};

const RCAutocomplete = ({
  name,
  options = [],
  label,
  placeholder,
  freeSolo = true,
  variant = "outlined",
  size = "small",
  required = false,
  readOnly = false,
  sx,
}: TRCAutocompleteProps) => {
  const { control } = useFormContext();

  return (
    <Controller
      control={control}
      name={name}
      render={({ field, fieldState: { error } }) => (
        <Autocomplete
          {...field}
          multiple
          options={options}
          freeSolo={freeSolo}
          readOnly={readOnly}
          onChange={(_, data) => field.onChange(data)}
          renderTags={(value: string[], getTagProps) =>
            value.map((option: string, index: number) => (
              <Chip
                variant="filled"
                label={option}
                {...getTagProps({ index })}
              />
            ))
          }
          renderInput={(params) => (
            <TextField
              {...params}
              variant={variant}
              label={label}
              placeholder={placeholder}
              size={size}
              fullWidth
              required={required}
              sx={{
                ...sx,
                "& .MuiInputBase-input": { fontSize: "14px" },
              }}
              InputLabelProps={{ style: { fontSize: "14px" } }}
              error={!!error?.message}
              helperText={error?.message}
            />
          )}
        />
      )}
    />
  );
};

export default RCAutocomplete;
