import {
  Button,
  FormControl,
  FormHelperText,
  SxProps,
} from "@mui/material";
import { Controller, useFormContext } from "react-hook-form";
import CloudUploadIcon from "@mui/icons-material/CloudUpload";

type TProps = {
  name: string;
  label: string;
  variant?: "outlined" | "contained";
  size?: "small" | "medium" | "large";
  sx?: SxProps;
};

const MultiFileUploader = ({ label, name, variant, sx, size }: TProps) => {
  const { control, formState } = useFormContext();
  const isError = formState.errors[name] !== undefined;

  return (
    <Controller
      name={name}
      control={control}
      render={({ field: { onChange, value, ...field } }) => (
        <FormControl error={isError} fullWidth>
          <Button
            component="label"
            role={undefined}
            variant={variant || "outlined"}
            tabIndex={-1}
            startIcon={<CloudUploadIcon />}
            size={size}
            fullWidth
            sx={{
              ...sx,
              py: "5.5px",
              justifyContent: "start",
              borderRadius: "4px",
              color: "primary.main",
            }}
          >
            {value ? value.name : label || "Upload file"}
            <input
              {...field}
              type="file"
              multiple
              onChange={(e) =>
                onChange((e.target as HTMLInputElement).files)
              }
              style={{ display: "none" }}
            />
          </Button>
          <FormHelperText>
            {isError ? (formState.errors[name]?.message as string) : ""}
          </FormHelperText>
        </FormControl>
      )}
    />
  );
};

export default MultiFileUploader
