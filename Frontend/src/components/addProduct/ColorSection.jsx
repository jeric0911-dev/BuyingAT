import Image from "next/image";

const ColorSection = ({ colorFields, register, appendColor, removeColor }) => {
  return (
    <section className="mt-6">
      <h3 className="text-sm">Color Options</h3>

      <div className="mt-3 divide-y divide-dashed divide-tGray border-t border-gray-200 pt-4">
        {colorFields.map((field, index) => (
          <div
            key={field.id}
            className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4 items-center py-4 first:pt-0 last:pb-0"
          >
            <input
              type="color"
              className="h-11 w-full rounded border border-gray-300 p-1"
              {...register(`colors.${index}.color`)}
              required
            />
            <input
              type="text"
              placeholder="Color name"
              className="input-input"
              {...register(`colors.${index}.color_name`)}
              required
            />
            <input
              type="file"
              accept="image/*"
              multiple
              className="h-11 w-full border border-gray-300 rounded-sm text-sm file:mr-4 file:h-11 file:px-4 file:border-0 file:text-sm file:bg-border"
              {...register(`colors.${index}.image`, {
                validate: (files) =>
                  files.length <= 3 || "You can upload a maximum of 3 files",
              })}
              onChange={(e) => {
                if (e.target.files.length > 3) {
                  alert("You can upload a maximum of 3 files.");
                  e.target.value = "";
                }
              }}
            />
            {index > 0 && (
              <button
                type="button"
                onClick={() => removeColor(index)}
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
        onClick={() => appendColor()}
        className="mt-4 bg-skyBlue text-white px-6 py-2 rounded-sm text-sm font-semibold hover:bg-sky-600 transition"
      >
        Add Color
      </button>
    </section>
  );
};

export default ColorSection;
