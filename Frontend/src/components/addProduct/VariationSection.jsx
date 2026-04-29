import Image from "next/image";

const VariationSection = ({ vrFields, register, appendVr, removeVr }) => {
  return (
    <section className="mt-6">
      <h3 className="text-sm">Variation Information</h3>

      <div className="mt-3 border-t border-border pt-4 divide-y divide-dashed divide-tGray">
        {vrFields.map((field, index) => (
          <div
            key={field.id}
            className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-[1fr_1fr_1fr_1fr_40px] gap-4 items-center py-4 first:pt-0 last:pb-0"
          >
            <input
              type="text"
              placeholder="Variant name (e.g., 128GB Blue)"
              className="input-input"
              {...register(`variations.${index}.variant_name`)}
              required
            />
            <input
              type="number"
              placeholder="Price"
              className="input-input"
              {...register(`variations.${index}.price`)}
              required
            />
            <input
              type="number"
              placeholder="Discounted Price"
              className="input-input"
              {...register(`variations.${index}.discounted_price`)}
              required
            />
            {/* <input
              type="number"
              placeholder="Stock"
              className="input-input"
              {...register(`variations.${index}.stock`)}
              required
            /> */}
            {index > 0 && (
              <button
                type="button"
                onClick={() => removeVr(index)}
                className="flex justify-center items-center hover:text-red-600"
              >
                <Image
                  src="/icon/cross.svg"
                  alt="Remove variation"
                  width={20}
                  height={20}
                  className="cursor-pointer"
                />
              </button>
            )}
          </div>
        ))}
      </div>
      <button
        type="button"
        onClick={() => appendVr()}
        className="mt-4 bg-skyBlue text-white px-6 py-2 rounded-sm text-sm font-semibold hover:bg-sky-600 transition"
      >
        Add More
      </button>
    </section>
  );
};

export default VariationSection;
