"use client";

import { updateOrderStatus } from "@/actions/cart";
import { success } from "@/constants";
import {
  Menu,
  MenuButton,
  MenuItem,
  MenuItems,
  Transition,
} from "@headlessui/react";
import { ChevronDownIcon } from "@heroicons/react/16/solid";
import { useTransitionRouter } from "next-view-transitions";
import { Fragment, useState } from "react";
import { toast } from "sonner";

const OrderStatusMenu = ({ data }) => {
  const [loading, setLoading] = useState(false);
  const router = useTransitionRouter();

  const handleStatus = async (value) => {
    setLoading(true);
    const toastId = toast.loading("Updating status...");

    try {
      const res = await updateOrderStatus(data?.id, { order_status: value });
      if (res.status === success) {
        router.refresh();
        toast.success("Status updated", { id: toastId });
      } else {
        toast.error(res.message || "Something went wrong!", { id: toastId });
      }
    } catch (error) {
      toast.error("Failed to update status", { id: toastId });
    } finally {
      setLoading(false);
    }
  };

  return (
    <Menu as="div" className="relative inline-block text-left">
      <MenuButton
        className={`inline-flex items-center gap-1 px-3 py-1.5 text-sm font-semibold uppercase focus:outline-none disabled:bg-transparent ${
          data?.order_status === "pending"
            ? "text-skyBlue"
            : data?.order_status === "processing"
            ? "text-[#9958EE]"
            : data?.order_status === "completed"
            ? "text-green"
            : data?.order_status === "cancelled"
            ? "text-red-500"
            : ""
        }`}
        disabled={loading}
      >
        {data?.order_status}
        <ChevronDownIcon
          className={`size-5 ${
            data?.order_status === "pending"
              ? "fill-skyBlue"
              : data?.order_status === "processing"
              ? "fill-[#9958EE]"
              : data?.order_status === "completed"
              ? "fill-green"
              : data?.order_status === "cancelled"
              ? "fill-red-500"
              : ""
          }`}
        />
      </MenuButton>

      <Transition
        as={Fragment}
        enter="transition ease-out duration-100"
        enterFrom="transform opacity-0 scale-95"
        enterTo="transform opacity-100 scale-100"
        leave="transition ease-in duration-75"
        leaveFrom="transform opacity-100 scale-100"
        leaveTo="transform opacity-0 scale-95"
      >
        <MenuItems
          anchor="bottom end"
          className="origin-top-right w-32 rounded-md border border-border shadow-md bg-black/5 backdrop-blur-xl p-1 text-xs text-tBlack font-medium focus:outline-none"
        >
          {["pending", "processing", "completed", "cancelled"].map((item) => (
            <MenuItem key={item} as={Fragment}>
              <button
                onClick={() => handleStatus(item)}
                className="flex w-full px-3 py-1.5 uppercase hover:bg-white rounded"
              >
                {item}
              </button>
            </MenuItem>
          ))}
        </MenuItems>
      </Transition>
    </Menu>
  );
};

export default OrderStatusMenu;
