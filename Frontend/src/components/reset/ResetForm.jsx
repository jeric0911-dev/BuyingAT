"use client";

import { resetPassword } from "@/actions/auth";
import { success } from "@/constants";
import { useTransitionRouter } from "next-view-transitions";
import Image from "next/image";
import { useState } from "react";
import { useForm } from "react-hook-form";
import { toast } from "sonner";

const ResetForm = () => {
  const [loading, setLoading] = useState(false);
  const router = useTransitionRouter();
  const {
    register,
    handleSubmit,
    watch,
    formState: { errors },
  } = useForm();

  const onSubmit = async (values) => {
    setLoading(true);
    const toastId = toast.loading("Loading...");
    const data = {
      ...values,
      otp: JSON.parse(localStorage.getItem("otp")),
      email: JSON.parse(localStorage.getItem("email"))?.email,
    };
    const res = await resetPassword(data);
    setLoading(false);
    if (res.status === success) {
      localStorage.removeItem("otp");
      localStorage.removeItem("email");
      toast.success(res.message, { id: toastId });
      router.push("/login");
    } else {
      toast.error(res.message || "Something went wrong!", { id: toastId });
    }
  };

  return (
    <form
      onSubmit={handleSubmit(onSubmit)}
      className="w-full max-w-[424px] border border-border rounded shadow-[0_8px_40px_0px_rgba(0,0,0,0.12)] p-8 pt-0 mt-4"
    >
      <div>
        <p className="mt-8 text-xl font-semibold text-center">Reset Password</p>
        <p className="mt-3 text-sm text-tGray text-center">
          Please enter your new password below to reset your account password.
        </p>
        {/* --------------------passwordField----------------- */}
        <label className="block mt-6 text-sm">
          Password
          <input
            {...register("password")}
            type="password"
            className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
            placeholder="8+ characters"
            required
          />
        </label>
        {/* --------------------confirmPasswordField----------------- */}
        <label className="block mt-4 text-sm">
          Confirm Password
          <input
            {...register("password_confirm", {
              required: true,
              validate: (p) =>
                p === watch("password") || "Passwords do not match",
            })}
            type="password"
            className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
            placeholder="**********"
            required
          />
          {errors.password_confirm && (
            <p className="text-red-500 text-xs">
              {errors.password_confirm.message}
            </p>
          )}
        </label>
        {/* --------------------submitButton----------------- */}
        <button
          type="submit"
          className="bg-skyBlue hover:bg-skyBlueHover text-white text-sm font-bold py-3 w-full rounded-sm flex items-center justify-center gap-2 mt-6 disabled:cursor-not-allowed"
          disabled={loading}
        >
          <span>SEND CODE</span>
          <Image
            src="/icon/right-arrow-white.svg"
            alt="#"
            width={20}
            height={20}
          />
        </button>
      </div>
    </form>
  );
};

export default ResetForm;
