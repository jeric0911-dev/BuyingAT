"use client";

import { changePassword } from "@/actions/auth";
import { success } from "@/constants";
import { useState } from "react";
import { useForm } from "react-hook-form";
import { toast } from "sonner";

const PasswordUpdateForm = () => {
  const [loading, setLoading] = useState(false);
  const {
    register,
    handleSubmit,
    reset,
    watch,
    formState: { errors },
  } = useForm();

  const onSubmit = async (values) => {
    setLoading(true);
    const toastId = toast.loading("Verifying...");
    const res = await changePassword(values);
    reset();
    setLoading(false);
    if (res.status === success) {
      toast.success("Password updated successfully!", { id: toastId });
    } else {
      toast.error(res.error || "Something went wrong!", { id: toastId });
    }
  };

  return (
    <section className="mt-6 border border-border rounded">
      <p className="px-6 py-4 text-sm font-medium">CHANGE PASSWORD</p>
      <hr />
      <form onSubmit={handleSubmit(onSubmit)} className="p-6 space-y-4">
        <label className="block text-sm">
          Current Password
          <input
            {...register("current_password")}
            type="password"
            className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
            required
          />
        </label>
        <label className="block text-sm">
          New Password
          <input
            {...register("password")}
            type="password"
            className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
            placeholder="8+ characters"
            required
          />
        </label>
        <label className="block text-sm">
          Confirm Password
          <input
            {...register("password_confirm", {
              required: true,
              validate: (p) =>
                p === watch("password") || "Passwords do not match",
            })}
            type="password"
            className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
            required
          />
          {errors.password_confirm && (
            <p className="text-red-500 text-xs">
              {errors.password_confirm.message}
            </p>
          )}
        </label>
        <button
          type="submit"
          style={{ '--hover-bg': `black`, '--hover-txt':"white" }}
          className="!mt-6 btn-hover-effect bg-skyBlue text-white px-6 py-3 rounded-sm"
          disabled={loading}
        >
          CHANGE PASSWORD
        </button>
      </form>
    </section>
  );
};

export default PasswordUpdateForm;
