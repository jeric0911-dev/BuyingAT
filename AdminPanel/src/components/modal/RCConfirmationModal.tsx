import { Button, Stack, Typography } from "@mui/material";
import RCModal from "./RCModal";

type TProps = {
  open: boolean;
  setOpen: React.Dispatch<React.SetStateAction<boolean>>;
  handleDelete: () => void;
};

const RCConfirmationModal = ({ open, setOpen, handleDelete }: TProps) => {
  return (
    <RCModal open={open} setOpen={setOpen} title="Confirmation Dialog">
      <Typography variant="h3" align="center" gutterBottom>
        Are you sure?
      </Typography>
      <Typography align="center" gutterBottom>
        This will permanently delete the item.
      </Typography>
      <Stack direction="row" justifyContent="end" gap={2} mt={4}>
        <Button
          variant="outlined"
          sx={{ color: "#0C143B" }}
          onClick={() => setOpen(false)}
        >
          Cancel
        </Button>
        <Button
          onClick={() => {
            setOpen(false);
            handleDelete();
          }}
        >
          Confirm
        </Button>
      </Stack>
    </RCModal>
  );
};

export default RCConfirmationModal;
