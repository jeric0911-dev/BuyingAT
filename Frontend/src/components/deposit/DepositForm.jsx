"use client";

import { paypal, razorpayPay, sslCommerz, stripe } from "@/actions/others";
import { useState } from "react";
import { useForm } from "react-hook-form";
import Razorpay from "./Razorpay";
import { useTransitionRouter } from "next-view-transitions";

const DepositForm = ({ gateways, user }) => {
  const router = useTransitionRouter();
  const [loading, setLoading] = useState(false);
  const [razorpay, setRazorpay] = useState({
    status: false,
    checkout_data: {},
  });

  const { register, handleSubmit, watch } = useForm();
  const gateway = watch("gateway");
  const currencies = gateways?.find((item) => item.alias === watch("gateway"));
  const currencyOption =
    currencies && Object.keys(JSON.parse(currencies?.supported_currencies));

  const onSubmit = async (values) => {
    setLoading(true);
    if (gateway === "sslcommerz") {
      delete values.gateway;
      const res = await sslCommerz({
        ...values,
        customer_name: user?.name,
        customer_email: user?.email,
        customer_phone: user?.phone ?? "015xxxxxxxx",
      });
      router.replace(res.data);
    } else if (gateway === "razorpay") {
      delete values.gateway;
      const res = await razorpayPay(values);
      setRazorpay((p) => ({
        ...p,
        status: true,
        checkout_data: res.data,
      }));
      router.replace("/wallet");
    } else if (gateway === "paypal") {
      delete values.gateway;
      const res = await paypal(values);
      router.replace(res.redirect_url);
    } else if (gateway === "stripe") {
      delete values.gateway;
      const res = await stripe(values);
      router.replace(res.redirect_url);
    }
    setLoading(false);
  };

  return (
    <>
      <form
        onSubmit={handleSubmit(onSubmit)}
        className="w-full max-w-md mx-auto border border-border rounded p-8 shadow-[0px_8px_40px_0px_#0000001F] space-y-6"
      >
        <p className="text-center text-xl font-semibold text-tBlack">
          Recharge
        </p>
        <div className="space-y-4">
          <select
            {...register("gateway")}
            className="input-select text-tBlack"
            aria-label="Select Gateway"
            required
          >
            <option value="">Select Gateway</option>
            {gateways?.map((item) => (
              <option key={item?.id} value={item.alias}>
                {item.gateway_name}
              </option>
            ))}
          </select>
          <select
            {...register("currency")}
            className="input-select text-tBlack"
            aria-label="Select Currency"
            required
          >
            <option value="">Select Currency</option>
            {currencyOption?.map((item, i) => (
              <option key={i} value={item}>
                {item}
              </option>
            ))}
          </select>
          <input
            {...register("amount")}
            type="number"
            className="input-input"
            placeholder="Credit Amount (10)"
            required
          />
        </div>
        {/* <p className="text-center text-sm text-[#5F6C72]">
          Conversion Rate 1 USD = 125 BDT
        </p> */}
        <button
          type="submit"
          className="w-full h-12 bg-skyBlue uppercase rounded-sm text-white text-sm font-bold hover:bg-skyBlueHover"
          disabled={loading}
        >
          Submit
        </button>
      </form>
      {razorpay && (
        <Razorpay
          open={razorpay?.status}
          checkout_data={razorpay.checkout_data}
        />
      )}
    </>
  );
};

export default DepositForm;
