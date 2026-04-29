"use client";

import { createShop } from "@/actions/auth";
import { success } from "@/constants";
import objectToFormData from "@/utils/objectToFormData";
import { useTransitionRouter } from "next-view-transitions";
import Image from "next/image";
import { useState } from "react";
import { useForm } from "react-hook-form";
import { toast } from "sonner";

const CreateShopForm = () => {
  const [bannerImg, setBannerImg] = useState(null);
  const [loading, setLoading] = useState(false);
  const router = useTransitionRouter();

  const { register, handleSubmit } = useForm();

  const handleBannerImgChange = (e) => {
    setBannerImg(e.target.files[0]);
  };

  const onSubmit = async (values) => {
    setLoading(true);
    const toastId = toast.loading("Creating shop...");
    const formData = objectToFormData({ ...values, banner: bannerImg });
    const res = await createShop(formData);
    setLoading(false);
    if (res.status === success) {
      toast.success(res.message, { id: toastId });
      router.push("/");
    } else {
      toast.error(res.message || "Something went wrong", { id: toastId });
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <label className="block mt-6 text-sm">
        Shop name
        <input
          {...register("name")}
          type="text"
          className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
          placeholder="Add shop name"
          required
        />
      </label>
      <p className="mt-4 text-sm">Banner Image</p>
      {!bannerImg ? (
        <label htmlFor="bannerImg" className="cursor-pointer">
          <input
            id="bannerImg"
            type="file"
            accept="image/*"
            onChange={(e) => {
              handleBannerImgChange(e);
            }}
            className="sr-only"
            required
          />
          <div className="h-[180px] w-full rounded bg-skyBlue/5 border border-border flex justify-center items-center mt-2">
            <Image src="/icon/plusBlue.svg" alt="#" width={44} height={44} />
          </div>
        </label>
      ) : (
        <div className="border border-border rounded h-[182px] w-full relative group mt-2">
          <Image
            src={URL.createObjectURL(bannerImg)}
            alt="#"
            width={0}
            height={0}
            sizes="100vw"
            className="rounded h-full w-auto mx-auto"
          />
          <div className="absolute inset-0 rounded bg-black/0 group-hover:bg-black/40 transition-all flex justify-center items-center">
            <Image
              onClick={() => setBannerImg(null)}
              src="/icon/deleteIconBlue.svg"
              alt="#"
              width={44}
              height={44}
              className="opacity-0 group-hover:opacity-100 transition-all"
            />
          </div>
        </div>
      )}
      <label className="block mt-4 text-sm">
        Description
        <textarea
          {...register("description")}
          className="mt-2 h-36 w-full border border-border rounded-sm px-4 form-textarea focus:ring-0 focus:border-skyBlue text-sm"
          placeholder="Add description"
          required
        />
      </label>
      <div className="flex justify-end mt-6">
        <button
          type="submit"
          className="bg-skyBlue text-white text-xs font-bold h-11 px-6"
          disabled={loading}
        >
          CREATE SHOP
        </button>
      </div>
    </form>
  );
};

export default CreateShopForm;
