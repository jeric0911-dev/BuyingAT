"use client";

import { unpublishProduct } from "@/actions/vendor";
import { useTransitionRouter } from "next-view-transitions";
import { toast } from "sonner";

const UnpublishButton = ({ data }) => {
  const router = useTransitionRouter();

  const handleUnpublish = async () => {
    toast("Do you want to unpublish this product?", {
      action: {
        label: "OK",
        onClick: async () => {
          const toastId = toast.loading("Unpublish product...");
          const res = await unpublishProduct(data?.id);
          if (res.status === "success") {
            router.refresh();
            toast.success("Product unpublished successfully!", { id: toastId });
          } else {
            toast.error(res.message || "Failed to unpublish product", {
              id: toastId,
            });
          }
        },
      },
    });
  };

  return (
    <button
      onClick={handleUnpublish}
      className="size-full text-green rounded border border-green bg-green/10"
    >
      Unpublish
    </button>
  );
};

export default UnpublishButton;
