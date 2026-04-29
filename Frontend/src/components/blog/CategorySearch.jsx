import { getBlogCategories } from "@/actions/others";
import { Link } from "next-view-transitions";

const CategorySearch = async ({ searchParams }) => {
  const { data: categories } = await getBlogCategories();

  return (
    <div className="border border-border p-6 rounded-md mt-6">
      <p className="font-medium" id="category-heading">
        CATEGORY
      </p>
      <div
        className="mt-4 space-y-3"
        role="radiogroup"
        aria-labelledby="category-heading"
      >
        {[{ id: 0, name: "All" }, ...categories].map((item) => (
          <Link
            href={item.id === 0 ? "/blogs" : `/blogs?category=${item.id}`}
            key={item.id}
            className="text-sm text-[#475156] flex items-center gap-2"
          >
            <input
              type="radio"
              name="category"
              id={`category-${item.id}`}
              className="form-radio border-border text-skyBlue focus:ring-0"
              checked={
                searchParams?.category
                  ? item.id == searchParams.category
                  : item.id === 0
              }
              readOnly
            />
            <label htmlFor={`category-${item.id}`} className="cursor-pointer">
              {item?.name}
            </label>
          </Link>
        ))}
      </div>
    </div>
  );
};

export default CategorySearch;
