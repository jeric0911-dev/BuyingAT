/* eslint-disable react-hooks/exhaustive-deps */
import { razorpayCallback } from "@/actions/others";
import { useTransitionRouter } from "next-view-transitions";
import { useEffect } from "react";
import { useRazorpay } from "react-razorpay";

const Razorpay = ({ checkout_data, open }) => {
  const { Razorpay } = useRazorpay();
  const router = useTransitionRouter()

  useEffect(() => {
    if (open) handlePayment();
  }, [open]);

  const handlePayment = () => {
    const options = {
      key: checkout_data.key,
      amount: checkout_data.amount,
      currency: checkout_data.currency,
      order_id: checkout_data.id,
      handler: async (res) => {
        const data = await razorpayCallback({
          order_id: res.razorpay_order_id,
          currency: checkout_data.currency,
          amount: checkout_data.amount,
        });
        if (data.status === "success") {
          router.replace("/wallet");
        }
      },
      modal: {
        ondismiss: () => {
          router.push(checkout_data.cancel_url);
        },
      },
      theme: { color: "#32A852" },
    };

    const razorpayInstance = new Razorpay(options);
    razorpayInstance.open();
  };

  return null;
};

export default Razorpay;
