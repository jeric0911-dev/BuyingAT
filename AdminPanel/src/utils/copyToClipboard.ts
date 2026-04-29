import { toast } from "sonner";

const copyToClipboard = (value: string) => {
  navigator.clipboard.writeText(value);
  toast.info("Copied");
};

export default copyToClipboard;
