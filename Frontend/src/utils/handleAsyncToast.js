import { toast } from "sonner";

const handleAsyncToast = async ({ promise, success }) => {
  const toastId = toast.loading("Loading...");

  try {
    const result = await promise;
    if (result.status === "success") {
      toast.success(success(result), { id: toastId });
    } else {
      toast.error(result.message, { id: toastId });
    }
    return result;
  } catch (err) {
    toast.error(err?.data?.message || "Something went wrong", { id: toastId });

    return undefined;
  }
};

export default handleAsyncToast;
