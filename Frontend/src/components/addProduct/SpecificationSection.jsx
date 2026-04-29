import Image from "next/image";

const SpecificationSection = ({
  specFields,
  register,
  appendSpec,
  removeSpec,
}) => {
  return (
    <section className="mt-6">
      <h3 className="text-sm">Specifications</h3>

      <div className="mt-3 border-t border-border pt-4 divide-y divide-dashed divide-tGray">
        {specFields.map((field, index) => (
          <div
            key={field.id}
            className="grid grid-cols-1 lg:grid-cols-[1fr_2fr_40px] gap-4 items-center py-4 first:pt-0 last:pb-0"
          >
            <input
              type="text"
              placeholder="Key (e.g., Resolution)"
              className="input-input"
              {...register(`specification.${index}.key`)}
              required
            />
            <input
              type="text"
              placeholder="Value (e.g., 1024x768)"
              className="input-input"
              {...register(`specification.${index}.value`)}
              required
            />
            {index > 0 && (
              <button
                type="button"
                onClick={() => removeSpec(index)}
                className="flex justify-center items-center hover:text-red-600"
              >
                <Image
                  src="/icon/cross.svg"
                  alt="Remove specification"
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
        onClick={() => appendSpec({ key: "", value: "" })}
        className="mt-4 bg-skyBlue text-white px-6 py-2 rounded-sm text-sm font-semibold hover:bg-sky-600 transition"
      >
        Add Specification
      </button>
    </section>
  );
};

export default SpecificationSection;
