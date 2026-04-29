import Image from "next/image";

const SizeSection = ({ sizeFields, register, appendSize, removeSize }) => {
  return (
    <section className="mt-6">
      <h3 className="text-sm">Size Options</h3>

      <div className="mt-3 border-t border-border pt-4 divide-y divide-dashed divide-tGray">
        {sizeFields.map((field, index) => (
          <div
            key={field.id}
            className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-[1fr_1fr_40px] gap-4 items-center py-4 first:pt-0 last:pb-0"
          >
            <input
              type="text"
              placeholder="Add size (e.g., S, M, L)"
              className="input-input"
              {...register(`sizes.${index}.size`)}
              required
            />
            {/* <input
              type="number"
              placeholder="Stock"
              className="input-input"
              {...register(`sizes.${index}.stock`)}
              required
            /> */}
            {index > 0 && (
              <button
                type="button"
                onClick={() => removeSize(index)}
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
            )}
          </div>
        ))}
      </div>
      <button
        type="button"
        onClick={() => appendSize("")}
        className="mt-4 bg-skyBlue text-white px-6 py-2 rounded-sm text-sm font-semibold hover:bg-sky-600 transition"
      >
        Add Size
      </button>
    </section>
  );
};

export default SizeSection;
