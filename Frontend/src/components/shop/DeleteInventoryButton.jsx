"use client";

import { deleteSellerInventory } from "@/actions/sellerInventory";
import { useTransitionRouter } from "next-view-transitions";
import { toast } from "sonner";

const DeleteInventoryButton = ({ data }) => {
  const router = useTransitionRouter();

  const handleDelete = async () => {
    toast("Do you want to delete this card?", {
      action: {
        label: "OK",
        onClick: async () => {
          const toastId = toast.loading("Removing card...");
          const res = await deleteSellerInventory(data?.id);
          if (res.status === "success") {
            router.refresh();
            toast.success("Card deleted successfully!", { id: toastId });
          } else {
            toast.error(res.message || "Failed to delete card", {
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

export default DeleteInventoryButton;
