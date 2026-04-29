import {
  FormControl,
  FormControlLabel,
  FormLabel,
  Radio,
  RadioGroup,
  SxProps,
} from "@mui/material";
import { Controller, useFormContext } from "react-hook-form";

type TRadioOption = {
  label: string;
  value: string;
};

type TRCRadioGroupProps = {
  name: string;
  sx?: SxProps;
  label: string;
  row?: boolean;
  defaultValue: string;
  options: TRadioOption[];
  size?: "small" | "medium";
};

const RCRadioGroup = ({
  name,
  label,
  options,
  defaultValue,
  row,
  size,
  sx,
}: TRCRadioGroupProps) => {
  const { control } = useFormContext();

  return (
    <FormControl sx={sx}>
      <FormLabel
        sx={{ color: "text.primary", fontWeight: 500, fontSize: "14px" }}
      >
        {label}
      </FormLabel>
      <Controller
        name={name}
        control={control}
        defaultValue={defaultValue || ""}
        render={({ field }) => (
          <RadioGroup row={row} {...field}>
            {options.map((option) => (
              <FormControlLabel
                key={option.value}
                value={option.value}
                control={<Radio size={size || "small"} />}
                label={option.label}
              />
            ))}
          </RadioGroup>
        )}
      />
    </FormControl>
  );
};

export default RCRadioGroup;
