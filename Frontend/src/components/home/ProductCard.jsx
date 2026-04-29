/* eslint-disable react-hooks/exhaustive-deps */
"use client";

import Image from "next/image";
import StarRating from "../shared/StarRating";
import { shimmer, success } from "@/constants";
import { toast } from "sonner";
import { addToWishList, delFromWishList } from "@/actions/product";
import { useCallback, useState } from "react";
import useAuth from "@/hooks/useAuth";
import { toggleWishlistItem } from "@/utils/localStorage";
import toBase64 from "@/utils/toBase64";
import { Link } from "next-view-transitions";

const ProductCard = ({ data, star }) => {
  const { token, wishlist, user, setWishlist } = useAuth();
  const [loading, setLoading] = useState(false);
  const findWishItem = wishlist?.includes(data?.id) ?? false;

  const handleWishList = useCallback(
    async (id) => {
      if (!token) {
        toast.warning("Please log in to add this to your wishlist", { id: 0 });
        return;
      }
      if (loading) return;

      if (data?.user_id === user?.id) {
        toast.error("You cannot add your own product to wishlist", { id: 0 });
        return;
      }

      setLoading(true);
      toast.loading("Processing...", { id: 0 });
      const res = findWishItem
        ? await delFromWishList(id)
        : await addToWishList(id);

      if (res.status === success) {
        toast.success(res.message, { id: 0 });
        toggleWishlistItem(id);
        setWishlist((prev) =>
          findWishItem ? prev.filter((item) => item !== id) : [id, ...prev]
        );
      }

      setLoading(false);
    },
    [
      token,
      loading,
      data?.user_id,
      user?.id,
      findWishItem,
      setWishlist,
      data?.id,
    ]
  );

  return (
    <Link
      prefetch={false}
      href={`/products/${data?.id}`}
      className="w-full relative"
    >
      <div
        className={`lg:min-w-[220px] xl:min-w-[230px] w-full ${
          star ? "h-[320px]" : "h-[296px]"
        } border bg-white border-border p-4 flex flex-col items-center justify-between group transition-all duration-300 hover:shadow-lg hover:-translate-y-1`}
      >
        <div
          className={`relative w-full flex justify-center ${
            star ? "h-[172px]" : "h-[188px]"
          }`}
        >
          <Image
            src={`${process.env.NEXT_PUBLIC_IMG_URL}/${data?.get_gallery_images[0]?.img}`}
            alt="img"
            fill
            placeholder={`data:image/svg+xml;base64,${toBase64(shimmer())}`}
            className="object-cover"
          />
          <div className="absolute inset-0 group-hover:!bg-black/50 transition-all flex justify-center items-center gap-2">
            <div className="has-tooltip">
              <span className="tooltip">Wishlist</span>
              <Image
                onClick={(e) => {
                  e.preventDefault();
                  e.stopPropagation();
                  handleWishList(data?.id);
                }}
                src={`/icon/${
                  findWishItem ? "favorite-red.svg" : "favorite.svg"
                }`}
                alt="fav"
                width={48}
                height={48}
                className={`!hidden group-hover:!block transition-all cursor-pointer`}
              />
            </div>
            <div className="has-tooltip">
              <span className="tooltip">View Options</span>
              <Image
                src="/icon/cart-blue.svg"
                alt="cart"
                width={48}
                height={48}
                className="!hidden group-hover:!block transition-all"
              />
            </div>
          </div>
        </div>
        {star && (
          <div className="self-start flex items-center gap-1 mt-4">
            <StarRating value={data?.ratings_avg_rating} />
            <p className="text-xs text-tGray">({data?.ratings_count})</p>
          </div>
        )}
        <p className="text-sm font-medium line-clamp-2 self-start mt-2">
          {data?.product_title}
        </p>
        <p className="text-sm font-semibold text-skyBlue self-start mt-2 flex items-center gap-1">
          $
          {data?.discounted_price && data.discounted_price < data.price
            ? data.discounted_price
            : data?.price}
          {data?.discounted_price && data.discounted_price < data.price && (
            <>
              <span className="line-through text-tGray font-normal">
                ${data.price}
              </span>
              <span className="text-tBlack text-xs font-semibold bg-yellow px-[10px] py-[3px] rounded-sm absolute top-3 left-3">
                {Math.round(
                  ((data.price - data.discounted_price) / data.price) * 100
                )}
                % OFF
              </span>
            </>
          )}
        </p>
      </div>
    </Link>
  );
};

export default ProductCard;
