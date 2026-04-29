import { navItemsPrivate, navItemsPublic } from "@/constants";
import {
  Dialog,
  DialogBackdrop,
  DialogPanel,
  DialogTitle,
} from "@headlessui/react";
import Image from "next/image";
import { Link } from "next-view-transitions";
import { MdOutlineLogout } from "react-icons/md";
import { MdOutlineLogin } from "react-icons/md";

const MenuItem = ({ link, handleClose, icon, label }) => {
  return (
    <Link
      key={link}
      href={link}
      onClick={handleClose}
      className="flex justify-between items-center py-4 px-1"
    >
      <div className="flex items-center gap-5">
        {icon}
        <span className="mt-1">{label}</span>
      </div>
      <Image src="/icon/arrow-gray.svg" alt="" width={15} height={15} />
    </Link>
  );
};

const DrawerMenu = ({
  open,
  setOpen,
  token,
  cart,
  cartCount,
  handleLogout,
  user,
  wishlist,
}) => {
  const handleClose = () => setOpen(false);

  return (
    <Dialog open={open} onClose={setOpen}>
      <DialogBackdrop
        transition
        className="fixed inset-0 bg-black/30 transition-opacity duration-500 ease-in-out data-[closed]:opacity-0"
      />
      <div className="fixed inset-0 overflow-hidden">
        <div className="absolute inset-0 overflow-hidden">
          <div className="pointer-events-none fixed inset-y-0 right-0 flex w-[80%] sm:w-[60%]">
            <DialogPanel
              transition
              className="pointer-events-auto relative w-full transform transition duration-500 ease-in-out data-[closed]:translate-x-full sm:duration-700"
            >
              <div className="flex h-full flex-col bg-white py-6 shadow-xl">
                <div className="px-4 sm:px-6 flex items-center">
                  <DialogTitle className="text-2xl font-semibold text-skyBlue absolute inset-x-0 text-center">
                    Menu
                  </DialogTitle>
                  <button onClick={handleClose} className="ms-auto mr-2 z-10">
                    <Image
                      src="/icon/modal-cross.svg"
                      alt=""
                      width={13}
                      height={13}
                    />
                  </button>
                </div>
                {/* -------------------------main content------------------ */}
                <>
                  <div className="mt-5 flex px-4 sm:px-6 items-center gap-6">
                    <Link
                      onClick={handleClose}
                      href={`${token ? "/shopping-cart" : "/login"}`}
                      className="relative"
                    >
                      {cartCount > 0 && (
                        <span className="absolute -top-1 -right-1 bg-yellow border-2 border-teal text-xs font-semibold rounded-full size-5 flex items-center justify-center">
                          {cartCount}
                        </span>
                      )}
                      <Image
                        src="/icon/cart-black.svg"
                        alt="#"
                        width={32}
                        height={32}
                      />
                    </Link>
                    <Link
                      onClick={handleClose}
                      href={`${token ? "/wishlist" : "/login"}`}
                      className="relative"
                    >
                      {wishlist?.length > 0 && (
                        <span className="absolute -top-1 -right-1.5 bg-yellow border-2 border-teal text-xs font-semibold rounded-full size-5 flex items-center justify-center">
                          {wishlist?.length}
                        </span>
                      )}
                      <Image
                        src="/icon/heart-black.svg"
                        alt="#"
                        width={32}
                        height={32}
                      />
                    </Link>
                  </div>

                  <div className="mt-5 grow px-4 sm:px-6 overflow-y-auto divide-y text-tBlack">
                    {token &&
                      navItemsPrivate.map(({ icon, label, link }) => {
                        const isVendor = user?.user_type === "vendor";
                        const shouldReplace =
                          isVendor && link === "/my-cards";
                        return (
                          <MenuItem
                            key={link}
                            link={shouldReplace ? "/my-shop" : link}
                            icon={icon}
                            label={shouldReplace ? "My Shop" : label}
                            handleClose={handleClose}
                          />
                        );
                      })}
                    {navItemsPublic.map(({ icon, label, link }) => (
                      <MenuItem
                        key={link}
                        link={link}
                        icon={icon}
                        label={label}
                        handleClose={handleClose}
                      />
                    ))}
                    {!token && (
                      <MenuItem
                        handleClose={handleClose}
                        icon={<MdOutlineLogin size={20} />}
                        label="Login / Register"
                        link="/login"
                      />
                    )}
                    {token && (
                      <button
                        onClick={() => {
                          handleLogout();
                          handleClose();
                        }}
                        className="flex justify-between items-center w-full py-4 px-1"
                      >
                        <div className="flex items-center gap-5">
                          <MdOutlineLogout size={20} />
                          <span className="mt-1">Logout</span>
                        </div>
                      </button>
                    )}
                  </div>
                </>
              </div>
            </DialogPanel>
          </div>
        </div>
      </div>
    </Dialog>
  );
};

export default DrawerMenu;
