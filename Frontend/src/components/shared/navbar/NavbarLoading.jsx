import Container from "../Container";
import Image from "next/image";

const NavbarLoading = () => {
  return (
    <div className="h-20 w-full bg-transparent lg:bg-skyBlue">
      <Container>
        <nav className="flex items-center gap-10 size-full">
          <div className="w-[220px] h-[42px] lg:w-[188px] lg:h-[44px] bg-tGray animate-pulse rounded" />
          {/* ------------------ hidden on small device----------------- */}
          <>
            <form className="relative hidden lg:block flex-grow h-10">
              <input
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
              <div className="relative">
                <Image
                  src="/icon/cart-white.svg"
                  alt="#"
                  width={32}
                  height={32}
                />
              </div>
              <div className="relative">
                <Image src="/icon/heart.svg" alt="#" width={32} height={32} />
              </div>
              <div className="size-8 rounded-full bg-tGray animate-pulse" />
            </div>
            <div className="w-24 h-10 hidden lg:block rounded-sm bg-tGray animate-pulse" />
          </>

          {/* ------------------- hidden on large device---------------- */}
          <div className="flex lg:hidden items-center gap-4 ms-auto">
            <div className="size-8 rounded-full bg-tGray animate-pulse" />
            <Image src="/icon/menu.svg" alt="menu" width={27} height={27} />
          </div>
        </nav>
      </Container>
    </div>
  );
};

export default NavbarLoading;
