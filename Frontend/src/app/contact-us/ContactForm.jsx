"use client";

import { contactUs } from "@/actions/others";
import handleAsyncToast from "@/utils/handleAsyncToast";
import { useState } from "react";
import { useForm } from "react-hook-form";

const ContactForm = () => {
  const [loading, setLoading] = useState(false);
  const { register, handleSubmit, reset } = useForm();

  const onSubmit = async (values) => {
    setLoading(true);
    handleAsyncToast({
      promise: contactUs(values),
      success: () => "Information submitted",
    });
    reset()
    setLoading(false);
  };

  return (
    <form
      onSubmit={handleSubmit(onSubmit)}
      className="w-full max-w-4xl mx-auto border border-border rounded p-8 md:pt-10 md:pb-12 md:px-[70px] shadow-[0px_8px_40px_0px_#0000001F]"
    >
      <p className="text-center text-2xl font-semibold text-tBlack">
        Contact Us
      </p>
      <div className="space-y-5 mt-10">
        <input
          {...register("name")}
          type="text"
          className="input-input w-full"
          placeholder="Name"
          required
        />
        <input
          {...register("email")}
          type="email"
          className="input-input w-full"
          placeholder="dbugstation@gmail.com"
          required
        />
        <textarea
          {...register("message")}
          className="h-36 input-base form-textarea"
          placeholder="Say something"
          required
        />
      </div>
      <button
        type="submit"
        style={{ "--hover-bg": `black`, "--hover-txt": "white" }}
        className="btn-hover-effect bg-skyBlue text-white px-6 py-3 rounded-sm mt-11 w-full"
        disabled={loading}
      >
        SEND
      </button>
    </form>
  );
};

export default ContactForm;
