/* eslint-disable react-hooks/exhaustive-deps */
"use client";

import Image from "next/image";
import { shimmer } from "@/constants";
import { toast } from "sonner";
import { useCallback, useState } from "react";
import useAuth from "@/hooks/useAuth";
import { toggleWishlistItem } from "@/utils/localStorage";
import toBase64 from "@/utils/toBase64";
import { Link } from "next-view-transitions";

const CardCard = ({ data, showSeller = false }) => {
  const { token, wishlist, user, setWishlist } = useAuth();
  const [loading, setLoading] = useState(false);
  const findWishItem = wishlist?.includes(data?.id) ?? false;

  // Debug: Log the data to see if price_type is available
  console.log('CardCard data:', data);

  const handleWishList = useCallback(
    async (id) => {
      if (!token) {
        toast.warning("Please log in to add this to your wishlist", { id: 0 });
        return;
      }
      if (loading) return;

      if (data?.seller?.id === user?.id) {
        toast.error("You cannot add your own card to wishlist", { id: 0 });
        return;
      }

      setLoading(true);
      toast.loading("Processing...", { id: 0 });
      
      // For now, just use localStorage since we don't have card wishlist API yet
      toggleWishlistItem(id);
      setWishlist((prev) =>
        findWishItem ? prev.filter((item) => item !== id) : [id, ...prev]
      );
      
      toast.success(findWishItem ? "Removed from wishlist" : "Added to wishlist", { id: 0 });
      setLoading(false);
    },
    [
      token,
      loading,
      data?.seller?.id,
      user?.id,
      findWishItem,
      setWishlist,
      data?.id,
    ]
  );

  const getCardImage = () => {
    if (data?.images && data.images.length > 0) {
      return `${process.env.NEXT_PUBLIC_IMG_URL}/${data.images[0]}`;
    }
    return "/placeholder-card.jpg"; // Fallback image
  };

  return (
    <Link
      prefetch={false}
      href={`/cards/${data?.id}`}
      className="w-full relative"
    >
      <div className={`lg:min-w-[220px] xl:min-w-[230px] w-full h-[320px] border bg-white p-4 flex flex-col items-center justify-between group transition-all duration-300 hover:shadow-lg hover:-translate-y-1 ${data?.is_promoted ? 'border-emerald-400 ring-2 ring-emerald-200' : 'border-border'}`}>
        <div className="relative w-full flex justify-center h-[172px]">
          <Image
            src={getCardImage()}
            alt={data?.card_title || "Trading Card"}
            fill
            placeholder={`data:image/svg+xml;base64,${toBase64(shimmer())}`}
            className="object-cover rounded"
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
              <span className="tooltip">View Details</span>
              <Image
                src="/icon/cart-blue.svg"
                alt="view"
                width={48}
                height={48}
                className="!hidden group-hover:!block transition-all"
              />
            </div>
          </div>
        </div>
        
        {/* Price Type Badge */}
        {data?.price_type && (
          <div
            className="absolute top-3 right-3 text-white text-xs font-semibold px-2 py-1 rounded"
            style={{ backgroundColor: "#32A852" }}
          >
            {data.price_type}
          </div>
        )}

        {/* Spotlight Badge */}
        {data?.is_promoted && (
          <div className="absolute top-3 left-3 text-[10px] font-semibold px-2 py-1 rounded bg-emerald-600 text-white shadow">SPOTLIGHT</div>
        )}

        {/* Card Title */}
        <p className="text-sm font-medium line-clamp-2 self-start mt-2">
          {data?.card_title}
        </p>

        {/* Sport Type */}
        {data?.sport_type && (
          <p className="text-xs text-gray-500 self-start">
            {data.sport_type}
          </p>
        )}

        {/* Seller Info */}
        {/* {showSeller && data?.seller && (
          <p className="text-xs text-gray-600 self-start">
            by {data.seller.name}
          </p>
        )} */}

        {/* Price */}
        <p className="text-sm font-semibold text-skyBlue self-start mt-2">
          ${data?.price}
        </p>

        {/* Weight (if available) */}
        {/* {data?.weight && (
          <p className="text-xs text-gray-500 self-start">
            Weight: {data.weight}g
          </p>
        )} */}
      </div>
    </Link>
  );
};

export default CardCard;
