import { toast } from "sonner";
import Modal from "../modal/Modal";
import { boostProduct } from "@/actions/vendor";
import { success } from "@/constants";
import { useState } from "react";
import { useForm } from "react-hook-form";
import Image from "next/image";
import { useTransitionRouter } from "next-view-transitions";

const BoostModal = ({ data, open, setOpen }) => {
  const [loading, setLoading] = useState(false);
  const router = useTransitionRouter();
  const { register, handleSubmit, reset } = useForm({
    defaultValues: {
      product_id: data?.id,
      duration: "",
      advert_date: new Date(),
    },
  });

  const onSubmit = async (values) => {
    setLoading(true);
    const toastId = toast.loading("Loading...");
    try {
      values.product_id = data.id;
      const res = await boostProduct(values);

      if (res.status === success) {
        router.refresh();
        toast.success(res.message, { id: toastId });
        reset();
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
      title="Boost Your Listing"
    >
      <div className="flex items-center gap-7 mt-6">
        <Image
          src={`${process.env.NEXT_PUBLIC_IMG_URL}/${data?.get_gallery_images?.[0]?.img}`}
          alt=""
          width={145}
          height={100}
          className="object-cover rounded-md h-[100px]"
        />
        <div className="flex flex-col gap-4">
          <p className="text-xl text-dark font-semibold">
            {data?.product_title}
          </p>
          <p className="text-sm text-gray55 line-clamp-2">
            {data?.description}
          </p>
        </div>
      </div>
      <form
        onSubmit={handleSubmit(onSubmit)}
        className="flex flex-col gap-5 mt-6"
      >
        <label className="block text-sm">
          Duration
          <input
            {...register("duration", { valueAsNumber: true })}
            type="number"
            className="mt-2 input-input"
            placeholder="Enter duration in days"
            required
          />
        </label>

        <button
          type="submit"
          style={{ "--hover-bg": `black`, "--hover-txt": "white" }}
          className="btn-hover-effect bg-skyBlue text-white px-6 py-3 rounded-sm w-max self-end"
          disabled={loading}
        >
          SUBMIT
        </button>
      </form>
    </Modal>
  );
};

export default BoostModal;
