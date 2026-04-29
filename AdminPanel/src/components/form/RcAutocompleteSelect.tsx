import { Autocomplete, Chip, SxProps, TextField } from "@mui/material";
import { Controller, useFormContext } from "react-hook-form";
import { TItem } from "./RCSelect";

type RCAutocompleteSelectProps = {
  name: string;
  label: string;
  options: TItem[];
  placeholder?: string;
  variant?: "outlined" | "filled" | "standard";
  size?: "small" | "medium";
  sx?: SxProps;
};

const RCAutocompleteSelect = ({
  name,
  label,
  options,
  placeholder,
  size = "small",
  variant = "outlined",
  sx,
}: RCAutocompleteSelectProps) => {
  const { control } = useFormContext();

  return (
    <Controller
      name={name}
      control={control}
      render={({ field, fieldState: { error } }) => (
        <Autocomplete
          {...field}
          multiple
          options={options}
          getOptionLabel={(option) => option.label}
          isOptionEqualToValue={(option, value) => option.value === value.value}
          onChange={(_, value) => field.onChange(value)}
          renderTags={(value, getTagProps) =>
            value.map((option, index) => (
              <Chip
                variant="filled"
                label={option.label}
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

export default RCAutocompleteSelect;
