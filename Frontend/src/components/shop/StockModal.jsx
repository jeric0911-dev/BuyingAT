import { useForm } from "react-hook-form";
import Modal from "../modal/Modal";
import { useState } from "react";
import { toast } from "sonner";
import { manageStockMain } from "@/actions/vendor";
import { success } from "@/constants";

const StockModal = ({ open, setOpen, data }) => {
  const [loading, setLoading] = useState(false);
  const { register, handleSubmit } = useForm({
    defaultValues: {
      stock: data?.stock,
    },
  });

  const onSubmit = async (values) => {
    setLoading(true);
    const toastId = toast.loading("Loading...");
    try {
      values.product_id = data.id;
      const res = await manageStockMain(values);

      if (res.status === success) {
        // router.refresh();
        toast.success(res.message, { id: toastId });
        // reset();
        setOpen(false);
      } else {
        toast.error(res.error || "Something went wrong!", { id: toastId });
      }
    } catch (error) {
      toast.error("Failed to update", { id: toastId });
    } finally {
      setLoading(false);
    }
  };

  return (
    <Modal
      open={open}
      handleClose={{
        setOpen,
        onClose() {
          // reset();
        },
      }}
      title={data?.product_title}
    >
      <form onSubmit={handleSubmit(onSubmit)}>
        <label className="block mt-6 text-sm">
          Stock
          <input
            {...register("stock")}
            type="number"
            className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
            placeholder="1"
            required
          />
        </label>
        <button
          type="submit"
          className="bg-skyBlue text-white px-8 py-3 text-xs font-bold rounded-sm mt-6"
          disabled={loading}
        >
          SUBMIT
        </button>
      </form>
    </Modal>
  );
};

export default StockModal;
