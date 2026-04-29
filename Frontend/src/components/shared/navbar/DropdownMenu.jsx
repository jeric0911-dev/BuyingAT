import { navItemsPrivate, shimmer } from "@/constants";
import { Menu, MenuButton, MenuItem, MenuItems } from "@headlessui/react";
import Image from "next/image";
import { Link } from "next-view-transitions";
import { MdOutlineLogout } from "react-icons/md";
import { FaUserCircle } from "react-icons/fa";
import toBase64 from "@/utils/toBase64";

const DropdownMenu = ({ handleLogout, user }) => {
  return (
    <Menu>
      <MenuButton
        className="size-8 rounded-full flex justify-center items-center overflow-hidden"
        aria-label="Open menu"
      >
        {user?.profile_img ? (
          <Image
            src={`${process.env.NEXT_PUBLIC_IMG_URL}/${user?.profile_img}
              
          `}
            alt=""
            width={0}
            height={0}
            sizes="100vw"
             placeholder={`data:image/svg+xml;base64,${toBase64(shimmer())}`}
            className="size-8 object-cover"
          />
        ) : (
          <FaUserCircle className="size-8 text-white" />
        )}
      </MenuButton>

      <MenuItems
        transition
        anchor="bottom end"
        className="w-72 mt-2 origin-top-right rounded bg-white shadow-[0px_4px_20px_0px_#0000001A] py-1 px-5 text-tBlack transition duration-100 ease-out [--anchor-gap:var(--spacing-1)] focus:outline-none data-[closed]:scale-95 data-[closed]:opacity-0"
      >
        {navItemsPrivate.map(({ icon, label, link }) => {
          const isVendor = user?.user_type === "vendor";
          const shouldReplace = isVendor && link === "/my-cards";
          return (
            <MenuItem key={link}>
              <Link
                href={shouldReplace ? "/my-shop" : link}
                className="flex justify-between items-center py-2 px-1 transition-all duration-200 group"
              >
                <div className="flex items-center gap-5 group-hover:text-skyBlue transition-colors duration-200">
                  {icon}
                  {shouldReplace ? "My Shop" : label}
                </div>
                <Image
                  src="/icon/arrow-gray.svg"
                  alt=""
                  width={15}
                  height={15}
                  className="transition-transform duration-200 group-hover:translate-x-1"
                />
              </Link>
            </MenuItem>
          );
        })}
        <MenuItem>
          <button
            onClick={handleLogout}
            className="flex justify-between items-center py-2 px-1 w-full transition-all duration-200 group"
          >
            <div className="flex items-center gap-5 group-hover:text-red-400 transition-colors duration-200">
              <MdOutlineLogout size={20} />
              Logout
            </div>
          </button>
        </MenuItem>
      </MenuItems>
    </Menu>
  );
};

export default DropdownMenu;
