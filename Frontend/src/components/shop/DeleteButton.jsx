"use client";

import { deleteProduct } from "@/actions/vendor";
import { useTransitionRouter } from "next-view-transitions";
import { toast } from "sonner";

const DeleteButton = ({data}) => {
  const router = useTransitionRouter()

  const handleDelete = async () => {
    toast("Do you want to delete this product?", {
      action: {
        label: "OK",
        onClick: async () => {
          const toastId = toast.loading("Removing product...");
          const res = await deleteProduct(data?.id);
          if (res.status === "success") {
            router.refresh()
            toast.success("Product deleted successfully!", { id: toastId });
          } else {
            toast.error(res.message || "Failed to delete product", {
              id: toastId,
            });
          }
        },
      },
    });
  };

  return (
    <button
      onClick={handleDelete}
      className="size-full text-white rounded bg-redPink hover:bg-red-600 transition-colors duration-200"
    >
      Delete
    </button>
  );
};

export default DeleteButton;
