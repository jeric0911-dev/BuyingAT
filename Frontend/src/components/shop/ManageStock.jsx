import { useFieldArray, useForm } from "react-hook-form";
import Modal from "../modal/Modal";
import Image from "next/image";
import handleAsyncToast from "@/utils/handleAsyncToast";
import { manageStock } from "@/actions/vendor";
import { useTransitionRouter } from "next-view-transitions";

const ManageStock = ({ open, setOpen, data }) => {
  const router = useTransitionRouter();
  const { register, handleSubmit, control, reset } = useForm({
    defaultValues: {
      stock:
        data?.stocks?.map((item) => ({
          color_id: item.color_id ?? "",
          size_id: item.size_id ?? "",
          variant_id: item.variant_id ?? "",
          stock: item.stock ?? "",
        })) || [],
    },
  });
  const colors = data?.colors && data?.colors?.length > 0;
  const sizes = data?.sizes && data?.sizes?.length > 0;
  const variants = data?.variants && data?.variants?.length > 0;

  const { fields, append, remove } = useFieldArray({
    name: "stock",
    control,
  });

  const onSubmit = async (values) => {
    const formattedStock = values.stock.map((item) => ({
      product_id: data?.id,
      color_id: item.color_id ? parseInt(item.color_id) : null,
      size_id: item.size_id ? parseInt(item.size_id) : null,
      variant_id: item.variant_id ? parseInt(item.variant_id) : null,
      stock: parseInt(item.stock),
    }));
    handleAsyncToast({
      promise: manageStock({ stocks: formattedStock }),
      success: () => {
        router.refresh();
        setOpen(false);
        return "Stock updated!";
      },
    });
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
      <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col">
        <div className="divide-y divide-dashed border-t border-gray-200 pt-4">
          {fields.map((field, index) => (
            <div
              key={field.id}
              className="grid grid-cols-[1fr_1fr_1fr_20px] gap-4 items-center py-4"
            >
              {colors && (
                <select
                  {...register(`stock.${index}.color_id`)}
                  className="input-select"
                  required
                >
                  <option value="">Select color</option>
                  {data?.colors.map((item) => (
                    <option key={item.id} value={item.id}>
                      {item.color_name}
                    </option>
                  ))}
                </select>
              )}

              {sizes && (
                <select
                  {...register(`stock.${index}.size_id`)}
                  className="input-select"
                  required
                >
                  <option value="">Select size</option>
                  {data?.sizes.map((item) => (
                    <option key={item.id} value={item.id}>
                      {item.size}
                    </option>
                  ))}
                </select>
              )}

              {variants && (
                <select
                  {...register(`stock.${index}.variant_id`)}
                  className="input-select"
                  required
                >
                  <option value="">Select variant</option>
                  {data?.variants.map((item) => (
                    <option key={item.id} value={item.id}>
                      {item.variant_name}
                    </option>
                  ))}
                </select>
              )}

              <input
                type="number"
                placeholder="Stock"
                className="input-input"
                {...register(`stock.${index}.stock`, { required: true })}
                required
              />

              <button
                type="button"
                onClick={() => remove(index)}
                className="flex justify-center items-center hover:text-red-600"
              >
                <Image
                  src="/icon/cross.svg"
                  alt="Remove"
                  width={20}
                  height={20}
                  className="cursor-pointer"
                />
              </button>
            </div>
          ))}
        </div>

        <button
          type="button"
          onClick={() =>
            append({
              color_id: "",
              size_id: "",
              variant_id: "",
              stock: "",
            })
          }
          className="mt-4 bg-skyBlue text-white px-6 py-2 w-max rounded-sm text-sm font-semibold hover:bg-sky-600 transition"
        >
          Add Stock
        </button>

        <button
          type="submit"
          style={{ "--hover-bg": `black`, "--hover-txt": "white" }}
          className="btn-hover-effect bg-skyBlue hover:bg-skyBlueHover text-white text-sm font-bold py-3 w-full rounded-sm flex items-center justify-center gap-2 mt-10 disabled:cursor-not-allowed"
        >
          Submit
        </button>
      </form>
    </Modal>
  );
};

export default ManageStock;
