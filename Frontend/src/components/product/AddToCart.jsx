"use client";

import { addToCart } from "@/actions/cart";
import { addToWishList, delFromWishList } from "@/actions/product";
import { success } from "@/constants";
import getSearchParams from "@/utils/getSearchParams";
import Image from "next/image";
import { useSearchParams } from "next/navigation";
import { useEffect, useMemo, useState } from "react";
import {
  FacebookShareButton,
  FacebookIcon,
  TwitterShareButton,
  TwitterIcon,
  PinterestShareButton,
  PinterestIcon,
} from "react-share";
import { toast } from "sonner";
import { FiShoppingCart } from "react-icons/fi";
import { createConversion } from "@/actions/others";
import ReportButton from "./ReportButton";
import useAuth from "@/hooks/useAuth";
import { toggleCartItem, toggleWishlistItem } from "@/utils/localStorage";
import { useTransitionRouter } from "next-view-transitions";

const AddToCart = ({ data }) => {
  const { wishlist, user, token, setWishlist, setCart } = useAuth();
  const [count, setCount] = useState(1);
  const [currentUrl, setCurrentUrl] = useState("");
  const searchParams = useSearchParams();
  const router = useTransitionRouter();
  const [cartAnimation, setCartAnimation] = useState(false);
  const [loading, setLoading] = useState(false);

  const is_saved = wishlist?.find((item) => item === data?.id);

  useEffect(() => {
    if (typeof window !== "undefined") {
      setCurrentUrl(window.location.href);
    }
  }, []);

  const selectedColor = searchParams.get("color");
  const selectedSize = searchParams.get("size");
  const selectedVariant = searchParams.get("variant");

  const matchedStock = useMemo(() => {
    return data?.stocks?.length > 0
      ? data?.stocks?.find(
          (stock) =>
            (data?.colors?.length ? stock.color_id == selectedColor : true) &&
            (data?.sizes?.length ? stock.size_id == selectedSize : true) &&
            (data?.variants?.length
              ? stock.variant_id == selectedVariant
              : true)
        )
      : { stock: parseInt(data?.stock ?? "0", 10) };
  }, [data, selectedColor, selectedSize, selectedVariant]);

  const stockMessage = (() => {
    if (
      (data?.colors?.length && !selectedColor) ||
      (data?.sizes?.length && !selectedSize) ||
      (data?.variants?.length && !selectedVariant)
    ) {
      return { text: "", type: "neutral" };
    }
    if (!matchedStock || matchedStock.stock <= 0) {
      return { text: "Out of stock", type: "error" };
    }
    return { text: "", type: "success" };
  })();

  const handleFav = async () => {
    if (!token)
      return toast.warning("Please log in to add this to your wishlist");

    const res = is_saved
      ? await delFromWishList(data?.id)
      : await addToWishList(data?.id);

    if (res.status === success) {
      toast.success(res.message);
      toggleWishlistItem(data?.id);
      setWishlist((prev) =>
        is_saved
          ? prev.filter((item) => item !== data?.id)
          : [data?.id, ...prev]
      );
    }
  };

  const handleAddToCart = async () => {
    if (!token) return toast.warning("Please log in");
    if (!count) return toast.error("Select a quantity");
    if (data?.sizes?.length && !selectedSize)
      return toast.error("Select a size");
    if (data?.colors?.length && !selectedColor)
      return toast.error("Select a color");
    if (data?.variants?.length && !selectedVariant)
      return toast.error("Select a variant");
    if (!matchedStock || matchedStock.stock < count) {
      return toast.error("Selected combination is out of stock");
    }

    const toastId = toast.loading("Adding to cart...");

    setCartAnimation(true);
    const res = await addToCart({
      vendor_id: data?.user_id,
      product_id: data?.id,
      quantity: count,
      sku: matchedStock?.sku ?? data?.sku,
    });
    setCartAnimation(false);

    if (res.status === success) {
      toggleCartItem(res?.data?.id);
      setCart((prev) =>
        prev.includes(res?.data?.id) ? prev : [res?.data?.id, ...prev]
      );
      // Trigger cart refresh event to update cart count
      window.dispatchEvent(new Event('cartUpdated'));
      toast.success("Item added to cart", { id: toastId });
    } else {
      toast.error(res.message || "Something went wrong", { id: toastId });
    }
  };

  const handleBuyNow = () => {
    if (!token) return toast.warning("Please log in");
    if (!count) return toast.error("Select a quantity");
    if (data?.sizes?.length && !selectedSize)
      return toast.error("Select a size");
    if (data?.colors?.length && !selectedColor)
      return toast.error("Select a color");
    if (data?.variants?.length && !selectedVariant)
      return toast.error("Select a variant");
    if (!matchedStock || matchedStock.stock < count) {
      return toast.error("Selected combination is out of stock");
    }

    const query = getSearchParams({
      product_id: data?.id,
      quantity: count,
      size: selectedSize,
      color: selectedColor,
      variant: selectedVariant,
    }).toString();

    router.push(`/shopping-cart/checkout?${query}`);
  };

  const handleMessage = async () => {
    if (!token) return toast.error("You must login before messaging");
    const toastId = toast.loading("Loading...");
    setLoading(true);
    const res = await createConversion({
      sender_id: user?.id,
      receiver_id: data?.get_product_user?.id,
      product_id: data?.id,
    });
    setLoading(false);
    if (res.status === success) {
      toast.success(res.message, { id: toastId });
      router.push(`/chats/${res?.data?.id}`);
    } else {
      toast.error(res.message || "Something went wrong!", { id: toastId });
    }
  };

  useEffect(() => {
    if (matchedStock && count > matchedStock.stock) {
      setCount(matchedStock.stock > 0 ? matchedStock.stock : 1);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [matchedStock]);

  return (
    <>
      <div className="w-full md:w-auto">
        <p className="text-xs text-red-600 mt-2">{stockMessage?.text}</p>
      </div>
      <div className="flex flex-col md:flex-row md:items-center flex-wrap gap-4 mt-8">
        <div className="flex items-center gap-4">
          <button
            onClick={handleMessage}
            className="bg-skyBlue rounded flex justify-center items-center px-4 h-14 flex-1 disabled:cursor-not-allowed"
            disabled={loading || user?.id == data?.get_product_user?.id}
          >
            <Image src="/icon/chat.svg" alt="chat" width={24} height={24} />
          </button>
          <ReportButton data={data} />
          <div className="flex items-center gap-10 px-5 h-14 border border-border rounded-[3px] w-auto">
            <Image
              onClick={() => setCount((pre) => (pre > 1 ? pre - 1 : 1))}
              src="/icon/minus.svg"
              alt="#"
              width={16}
              height={16}
              className="transition-transform duration-200 hover:scale-125 active:scale-95 cursor-pointer"
            />
            <span className="w-4">{count}</span>
            <Image
              onClick={() => {
                if (!matchedStock || matchedStock.stock === 0) return;
                setCount((pre) =>
                  matchedStock && pre < matchedStock.stock ? pre + 1 : pre
                );
              }}
              src="/icon/plus.svg"
              alt="#"
              width={16}
              height={16}
              className="transition-transform duration-200 hover:scale-125 active:scale-95 cursor-pointer"
            />
          </div>
        </div>

        <button
          onClick={handleAddToCart}
          type="button"
          aria-label="add to cart"
          disabled={cartAnimation || stockMessage.type === "error"}
          style={{ "--hover-bg": `black`, "--hover-txt": "white" }}
          className="btn-hover-effect px-6 h-14 bg-skyBlue rounded-[3px] text-white flex items-center justify-center gap-3 flex-grow w-full md:w-auto"
        >
          <span>CART DISABLED</span>
          <FiShoppingCart className="text-xl" />
        </button>

        <button
          onClick={handleBuyNow}
          type="button"
          aria-label="buy now"
          className="border border-skyBlue px-8 h-14 font-bold text-skyBlue rounded-[3px] w-full md:w-auto transition-transform duration-200 hover:scale-110 active:scale-95 cursor-pointer"
          disabled={stockMessage.type === "error"}
        >
          BUY NOW
        </button>
      </div>

      <div className="mt-6 flex justify-between items-center">
        <button
          onClick={handleFav}
          className="flex items-center gap-[6px] disabled:cursor-not-allowed disabled:bg-transparent"
          disabled={data?.user_id == user?.id}
        >
          <Image
            src={`/icon/${is_saved ? "heart-red.svg" : "heart-gray.svg"}`}
            alt="#"
            width={24}
            height={24}
          />
          <span className="text-tGray text-sm">Add to Wishlist</span>
        </button>
        <div className="flex items-center gap-3">
          <span className="text-sm text-tGray">Share product:</span>
          <FacebookShareButton url={currentUrl} aria-label="Share on Facebook">
            <FacebookIcon size={18} className="rounded-full" />
          </FacebookShareButton>
          <TwitterShareButton url={currentUrl} aria-label="Share on Twitter">
            <TwitterIcon size={18} className="rounded-full" />
          </TwitterShareButton>
          <PinterestShareButton
            url={currentUrl}
            media={`${currentUrl}/exampleImage`}
            aria-label="Share on Pinterest"
          >
            <PinterestIcon size={18} className="rounded-full" />
          </PinterestShareButton>
        </div>
      </div>
    </>
  );
};

export default AddToCart;
