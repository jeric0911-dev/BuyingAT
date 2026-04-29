"use client";

import { payOrderWithWallet } from "@/actions/cart";
import { useTransitionRouter } from "next-view-transitions";
import { useState } from "react";
import { toast } from "sonner";

const PayNowButton = ({ orderId, disabled }) => {
  const [loading, setLoading] = useState(false);
  const router = useTransitionRouter();

  const handlePay = async () => {
    setLoading(true);
    const t = toast.loading("Processing payment...");
    try {
      const res = await payOrderWithWallet(orderId);
      if (res?.status === "success") {
        toast.success("Payment successful", { id: t });
        router.refresh();
      } else {
        toast.error(res?.message || "Payment failed", { id: t });
      }
    } catch (e) {
      toast.error(e?.message || "Payment failed", { id: t });
    } finally {
      setLoading(false);
    }
  };

  return (
    <button
      onClick={handlePay}
      disabled={loading || disabled}
      className="bg-skyBlue text-white px-4 py-2 rounded-md hover:bg-skyBlueHover shadow-sm border border-skyBlue/20 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
    >
      {loading ? "Paying..." : "Pay Now"}
    </button>
  );
};

export default PayNowButton;


