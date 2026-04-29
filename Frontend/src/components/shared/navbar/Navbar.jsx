"use client";

import Image from "next/image";
import Container from "../Container";
import { Link, useTransitionRouter } from "next-view-transitions";
import { useState } from "react";
import DrawerMenu from "./DrawerMenu";
import { toast } from "sonner";
import { logoutUser } from "@/actions/auth";
import DropdownMenu from "./DropdownMenu";
import { useForm } from "react-hook-form";
import useAuth from "@/hooks/useAuth";
import toBase64 from "@/utils/toBase64";
import { shimmer } from "@/constants";

const Navbar = ({ settings }) => {
  const [drawerOpen, setDrawerOpen] = useState(false);
  const router = useTransitionRouter();
  const { token, user, wishlist, cart, cartCount } = useAuth();
  const { register, handleSubmit, reset } = useForm();

  const onSubmit = (values) => {
    if (values.search !== "") {
      router.push(`/products?search=${values.search}`);
      reset();
    } else {
      router.push("/products");
    }
  };

  const handleLogout = async () => {
    const toastId = toast.loading("Logging out...");
    const res = await logoutUser();
    if (res.status === "success") {
      localStorage.clear();
      toast.success(res.message, { id: toastId });
      window.location.href = "/";
    } else {
      toast.error(res.message || "Something went wrong! Try again", {
        id: toastId,
      });
    }
  };

  return (
    <>
      <div className="h-20 w-full bg-transparent lg:bg-skyBlue">
        <Container>
          <nav className="flex items-center gap-10 size-full">
            <Link href="/profile">
              <Image
                src={`${process.env.NEXT_PUBLIC_IMG_URL}/${settings?.web_app_logo}`}
                alt="classified"
                width={220}
                height={44}
                placeholder={`data:image/svg+xml;base64,${toBase64(shimmer())}`}
                // className="w-[220px] h-[42px] lg:w-[188px] lg:h-[44px]"
                className="w-[220px] lg:w-[188px]"
              />
            </Link>
            {/* ------------------ hidden on small device----------------- */}
            <>
              <form
                onSubmit={handleSubmit(onSubmit)}
                className="relative hidden lg:block flex-grow h-10"
              >
                <input
                  {...register("search")}
                  type="text"
                  className="form-input focus:ring-0 focus:border-skyBlue h-full w-full border border-border rounded-sm text-sm px-4"
                  placeholder="Search for anything..."
                />
                <button type="submit" aria-label="Search button">
                  <Image
                    src="/icon/search.svg"
                    alt="#"
                    width={20}
                    height={20}
                    className="absolute right-0 top-0 my-[10px] mr-4"
                  />
                </button>
              </form>
              <div className="hidden lg:flex items-center gap-6">
                <Link
                  href={`${token ? "/shopping-cart" : "/login"}`}
                  className="relative"
                >
                  {cartCount > 0 && (
                    <span className="absolute -top-1 -right-1 bg-yellow border-2 border-teal text-xs font-semibold rounded-full size-5 flex items-center justify-center">
                      {cartCount}
                    </span>
                  )}
                  <Image
                    src="/icon/cart-white.svg"
                    alt="#"
                    width={32}
                    height={32}
                  />
                </Link>
                <Link
                  href={`${token ? "/wishlist" : "/login"}`}
                  className="relative"
                >
                  {wishlist?.length > 0 && (
                    <span className="absolute -top-1 -right-1.5 bg-yellow border-2 border-teal text-xs font-semibold rounded-full size-5 flex items-center justify-center">
                      {wishlist?.length}
                    </span>
                  )}
                  <Image src="/icon/heart.svg" alt="#" width={32} height={32} />
                </Link>
                {!token ? (
                  <Link href="/login">
                    <Image
                      src="/icon/user.svg"
                      alt="#"
                      width={32}
                      height={32}
                    />
                  </Link>
                ) : (
                  <DropdownMenu handleLogout={handleLogout} user={user} />
                )}
              </div>
              {/* <Link
                href={`${
                  token
                    ? user.user_type === "vendor"
                      ? "/my-shop"
                      : "/shop/create-shop"
                    : "/login"
                }`}
                className="btn-hover-effect bg-tBlack text-white text-xs font-bold px-5 py-3 rounded-sm hidden lg:block"
                style={{ "--hover-bg": `#EBC80C`, "--hover-txt": "#053B5F" }}
              >
                SELL NOW
              </Link> */}
            </>

            {/* ------------------- hidden on large device---------------- */}
            <div className="flex lg:hidden items-center gap-4 ms-auto">
              <Link href={token ? "/profile" : "/login"}>
                <Image
                  src={`${
                    user?.profile_img
                      ? `${process.env.NEXT_PUBLIC_IMG_URL}/${user?.profile_img}`
                      : "/icon/user-mobile.svg"
                  }`}
                  alt="user"
                  width={34}
                  height={34}
                  className="rounded-full"
                />
              </Link>
              <button
                onClick={() => setDrawerOpen(true)}
                aria-label="Open menu"
              >
                <Image src="/icon/menu.svg" alt="menu" width={27} height={27} />
              </button>
              <DrawerMenu
                open={drawerOpen}
                setOpen={setDrawerOpen}
                token={token}
                cart={cart}
                cartCount={cartCount}
                wishlist={wishlist}
                user={user}
                handleLogout={handleLogout}
              />
            </div>
          </nav>
        </Container>
      </div>
    </>
  );
};

export default Navbar;

