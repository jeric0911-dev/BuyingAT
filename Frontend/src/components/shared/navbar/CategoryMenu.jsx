import Image from "next/image";
import { Link } from "next-view-transitions";

const CategoryMenu = ({ categories }) => {
  return (
    <div className="text-sm py-2 rounded-sm cursor-pointer group/main relative">
      <div className="flex justify-center items-center gap-2 group-hover/main:text-skyBlue group-hover/main:bg-lightGray p-5 py-3">
        All Category
        <span className="">
          <svg
            className="w-4 h-4 ml-1 font-nunito font-bold transform rotate-90"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              d="M9 5l7 7-7 7"
            ></path>
          </svg>
        </span>
      </div>
      <div className="hidden group-hover/main:block min-w-60 max-h-80 absolute top-full left-0 bg-white shadow-[0px_8px_40px_0px_#0000001F] rounded-sm space-y-2 py-3 z-[1]">
        {categories?.map((item) => (
          <div
            key={item.id}
            className="hover:bg-lightGray pl-4 pr-5 py-2 hover:font-bold hover:text-tBlack transition-all duration-200 ease-in-out group/item"
          >
            <Link
              href={`/products?category_id=${item.id}`}
              className="flex justify-between items-center"
            >
              <span>{item?.category_name}</span>
              {item.sub_categories?.length > 0 && (
                <Image
                  src="/icon/caretDown.svg"
                  alt="subcategory arrow"
                  width={14}
                  height={14}
                  className="-rotate-90"
                />
              )}
            </Link>

            {item?.sub_categories?.length > 0 && (
              <div className="absolute left-[calc(100%+1px)] top-0 hidden group-hover/item:block min-w-60 min-h-80 rounded-sm bg-white py-3 text-[#5F6C72] text-sm">
                {item?.sub_categories?.map((sub) => (
                  <Link
                    key={sub.id}
                    href={`/products?category_id=${item.id}&sub_category_id=${sub.id}`}
                    className="block pl-4 pr-5 py-2 hover:bg-lightGray hover:font-bold hover:text-tBlack hover:scale-102 transition-all duration-200 ease-in-out"
                  >
                    {sub.sub_category_name}
                  </Link>
                ))}
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
};

export default CategoryMenu;
