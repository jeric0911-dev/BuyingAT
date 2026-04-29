"use client";

import { buyNow, checkout } from "@/actions/cart";
import { success } from "@/constants";
import { useTransitionRouter } from "next-view-transitions";
import Image from "next/image";
import { usePathname, useSearchParams } from "next/navigation";
import { toast } from "sonner";

const PlaceOrder = ({ product }) => {
  const router = useTransitionRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const product_id = searchParams.get("product_id");
  const delivery_address = searchParams.get("address");
  const order_note = searchParams.get("note");
  const matchedStock = product?.stocks?.find(
    (stock) =>
      (product?.colors?.length
        ? stock.color_id == searchParams.get("color")
        : true) &&
      (product?.sizes?.length
        ? stock.size_id == searchParams.get("size")
        : true) &&
      (product?.variants?.length
        ? stock.variant_id == searchParams.get("variant")
        : true)
  );

  const handlePlaceOrder = async () => {
    // Validate delivery address
    if (!delivery_address || delivery_address.trim().length < 10) {
      toast.error("Please enter a complete delivery address (at least 10 characters).");
      return;
    }

    const toastId = toast.loading("Processing order...");
    try {
      const res = await checkout({ delivery_address, order_note });
      if (res?.status === success) {
        toast.success(res.message || "Order placed successfully!", { id: toastId });
        // Clear cart count on successful order
        window.dispatchEvent(new Event('cartUpdated'));
        setTimeout(() => {
          router.replace("/my-orders");
        }, 1000);
      } else {
        toast.error(res?.message || "Failed to place order. Please try again.", { id: toastId });
      }
    } catch (error) {
      console.error("Error placing order:", error);
      toast.error("An error occurred while placing the order. Please try again.", { id: toastId });
    }
  };
  const handleBuyOrder = async () => {
    // Check if product data is valid
    if (!product || !product.id) {
      toast.error("Product data is missing. Please refresh the page and try again.");
      return;
    }

    const variant = product?.variants?.find(
      (item) => item.id == searchParams.get("variant")
    );

    const quantity = Number(searchParams.get("quantity")) || 1;
    const price = searchParams.get("variant") 
      ? Number(variant?.discounted_price) || Number(variant?.price) || 0
      : Number(product?.discounted_price) || Number(product?.price) || 0;
    
    console.log("Product data:", product);
    console.log("Variant data:", variant);
    console.log("Calculated price:", price);
    console.log("Calculated quantity:", quantity);

    // Determine if this is a card or product order
    const isCard = product?.card_title && product?.sport_type; // Cards have these fields, products don't

    // Validate required data based on order type
    if (isCard) {
      // Card validation
      if (!product.card_id) {
        toast.error("Card ID is missing. Please refresh the page and try again.");
        return;
      }
    } else {
      // Product validation
      if (!product.user_id) {
        toast.error("Product vendor information is missing. Please refresh the page and try again.");
        return;
      }
    }

    if (price <= 0) {
      toast.error("Product price is invalid. Please refresh the page and try again.");
      return;
    }
    
    const data = isCard ? {
      // Card order data
      card_id: product?.card_id, // Use card_id (SellerInventory ID) for card orders
      delivery_address,
      order_note,
      amount: quantity * price,
    } : {
      // Product order data
      product_id: searchParams.get("product_id"),
      quantity: quantity,
      vendor_id: product?.user_id,
      delivery_address,
      sku: matchedStock?.sku ?? product?.sku,
      order_note,
      amount: quantity * price,
    };
    console.log("Checkout: ", data);
    const toastId = toast.loading(isCard ? "Processing card order..." : "Processing product order...");
    const res = await buyNow(data);
    if (res.status === success) {
      toast.success(res.message, { id: toastId });
      router.replace(`${pathname}/success`);
    } else {
      toast.error(res.message || "Something went wrong!", { id: toastId });
    }
  };

  const handleClick = () => {
    if (!delivery_address)
      return toast.error("Please enter a complete delivery address.");
    if (product_id) {
      handleBuyOrder();
    } else {
      handlePlaceOrder();
    }
  };

  return (
    <button
      onClick={handleClick}
      style={{ "--hover-bg": `black`, "--hover-txt": "white" }}
      className="btn-hover-effect w-full py-3 bg-skyBlue text-white font-bold flex items-center justify-center gap-3 rounded-[4px] mt-6"
    >
      <span>PLACE ORDER</span>
      <Image src="/icon/right-arrow-white.svg" alt="#" width={24} height={24} />
    </button>
  );
};

export default PlaceOrder;
