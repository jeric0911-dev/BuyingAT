"use client";

import { delFromWishList } from "@/actions/product";
import useAuth from "@/hooks/useAuth";
import { toggleWishlistItem } from "@/utils/localStorage";
import Image from "next/image";
import { Link } from "next-view-transitions";

const WishlistCard = ({ data }) => {
  const { setWishlist } = useAuth();

  const handleClick = async (id) => {
    await delFromWishList(id);
    toggleWishlistItem(id);
    setWishlist((prev) => prev.filter((item) => item !== id));
  };

  return (
    <div className="grid grid-cols-[1fr_80px_180px] md:grid-cols-[1fr_100px_200px] lg:grid-cols-[1fr_200px_220px] gap-5 text-sm h-[72px]">
      <div className="flex items-center gap-4 h-full">
        <Image
          src={`${process.env.NEXT_PUBLIC_IMG_URL}/${data?.product?.get_gallery_images?.[0]?.img}`}
          alt="#"
          width={72}
          height={72}
          className="object-cover"
        />
        <p className="text-tGray pr-10">{data?.product?.product_title}</p>
      </div>
      <div className="h-full leading-[72px]">${data?.product?.price}</div>
      {/* <div className="h-full leading-[72px] text-green-500 font-semibold">
        {status}
      </div> */}
      <div className="h-full flex items-center justify-between">
        <Link
          href={`/products/${data?.product_id}`}
          style={{ "--hover-bg": `black`, "--hover-txt": "white" }}
          className="btn-hover-effect px-5 md:px-6 py-2.5 md:py-3 bg-skyBlue rounded-sm text-white flex items-center gap-1 lg:gap-2"
        >
          <span className="text-xs md:text-sm">ADD TO CART</span>
          <Image
            src="/icon/cart-white.svg"
            alt="#"
            width={20}
            height={20}
            className="size-4 md:size-5"
          />
        </Link>
        <button
          onClick={() => handleClick(data?.product_id)}
          className="transition-transform hover:scale-110 active:scale-90"
        >
          <Image src="/icon/cross.svg" alt="#" width={24} height={24} />
        </button>
      </div>
    </div>
  );
};

export default WishlistCard;
