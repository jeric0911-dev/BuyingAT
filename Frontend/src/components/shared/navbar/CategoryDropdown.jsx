import { Menu, MenuButton, MenuItem, MenuItems } from "@headlessui/react";
import Image from "next/image";
import { Link } from "next-view-transitions";
const categories = [
  {
    id: 1,
    category_name: "Electronics",
    subcategories: [
      { id: 101, subcategory_name: "Phones" },
      { id: 102, subcategory_name: "Laptops" },
    ],
  },
  {
    id: 2,
    category_name: "Clothing",
    subcategories: [],
  },
];
const CategoryDropdown = () => {
  return (
    <Menu>
      <MenuButton
        className="flex items-center gap-2 overflow-hidden rounded-sm px-5 py-3 text-sm text-[#5F6C72] hover:bg-lightGray data-[open]:bg-lightGray"
        aria-label="Open category dropdown"
      >
        All Category
        <Image src="/icon/caretDown.svg" alt="arrow" width={14} height={14} />
      </MenuButton>

      <MenuItems
        transition
        anchor="bottom start"
        className="min-w-60 min-h-96 mt-3 origin-top-left rounded-sm bg-white shadow-[0px_8px_40px_0px_#0000001F] py-3 text-[#5F6C72] text-sm transition duration-100 ease-out [--anchor-gap:var(--spacing-1)] focus:outline-none data-[closed]:scale-95 data-[closed]:opacity-0"
      >
        {categories?.map((item) => (
          <MenuItem key={item.id}>
            <div className="relative group">
              <Link
                href={`/products?category_id=${item.id}`}
                className="flex justify-between items-center max-w-60 pl-4 pr-5 py-2 hover:bg-lightGray hover:font-bold hover:text-tBlack transition-all duration-200 ease-in-out"
              >
                <span>{item?.category_name}</span>
                {item.subcategories?.length > 0 && (
                  <Image
                    src="/icon/caretDown.svg"
                    alt="subcategory arrow"
                    width={14}
                    height={14}
                    className="-rotate-90"
                  />
                )}
              </Link>

              {item?.subcategories?.length > 0 && (
                <div className="absolute left-full top-0 hidden group-hover:block w-60 rounded-sm bg-white shadow-[0px_8px_40px_0px_#0000001F] py-3 text-[#5F6C72] text-sm">
                  {item?.subcategories?.map((sub) => (
                    <Link
                      key={sub.id}
                      href={`/products?category_id=${item.id}&sub_category_id=${sub.id}`}
                      className="block pl-4 pr-5 py-2 hover:bg-lightGray hover:font-bold hover:text-tBlack hover:scale-102 transition-all duration-200 ease-in-out"
                    >
                      {sub.subcategory_name}
                    </Link>
                  ))}
                </div>
              )}
            </div>
          </MenuItem>
        ))}
      </MenuItems>
    </Menu>
  );
};

export default CategoryDropdown;
