"use client";

import { updateUser } from "@/actions/auth";
import { success } from "@/constants";
import objectToFormData from "@/utils/objectToFormData";
import { CameraIcon } from "@heroicons/react/16/solid";
import Image from "next/image";
import { useState } from "react";
import { useForm } from "react-hook-form";
import { FaUserCircle } from "react-icons/fa";
import { toast } from "sonner";

const ProfileUpdateForm = ({ data, countries, states }) => {
  const [image, setImage] = useState(null);
  const [loading, setLoading] = useState(false);

  const { register, handleSubmit, watch } = useForm({
    defaultValues: {
      name: data.name,
      email: data.email,
      secondery_email: data.secondery_email,
      phone: data.phone,
      country_id: data?.country_id ?? 1,
      state_id: data?.state_id ?? 1,
      zip_code: data?.zip_code,
    },
  });

  const filteredStates = states?.filter(
    (item) => item?.country_id == watch("country_id")
  );

  const onSubmit = async (values) => {
    setLoading(true);
    const toastId = toast.loading("Updating...");
    const res = await updateUser(
      objectToFormData({ ...values, profile_img: image })
    );
    setLoading(false);
    if (res.status === success) {
      toast.success("Profile updated successfully!", { id: toastId });
    } else {
      toast.error(res.message || "Something went wrong!", { id: toastId });
    }
  };

  return (
    <form
      onSubmit={handleSubmit(onSubmit)}
      className="p-6 flex lg:flex-row flex-col gap-6"
    >
      <div className="relative rounded-full size-44 ring-2 ring-skyBlue">
        {data?.profile_img ? (
          <Image
            src={
              image
                ? URL.createObjectURL(image)
                : `${process.env.NEXT_PUBLIC_IMG_URL}/${data?.profile_img}`
            }
            alt={data?.name}
            fill
            className="rounded-full object-cover"
          />
        ) : image ? (
          <Image
            src={URL.createObjectURL(image)}
            alt={data?.name}
            fill
            className="rounded-full object-cover"
          />
        ) : (
          <FaUserCircle className="size-full" />
        )}
        <label htmlFor="Uimg">
          <input
            type="file"
            className="sr-only"
            id="Uimg"
            accept="image/*"
            onChange={(e) => {
              if (e.target?.files?.[0]) {
                setImage(e.target.files[0]);
              }
            }}
          />
          <div className="absolute size-8 flex justify-center items-center rounded-full right-4 bottom-0 cursor-pointer bg-skyBlue">
            <CameraIcon className="size-5 text-white" />
          </div>
        </label>
      </div>
      <div className="flex-1 space-y-4">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          {/* <label className="block text-sm">
            Display name
            <input
              type="text"
              className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
              placeholder="Kevin"
            />
          </label>
          <label className="block text-sm">
            Username
            <input
              type="text"
              className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
              placeholder="Display name"
            />
          </label> */}
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <label className="block text-sm">
            Full name
            <input
              {...register("name")}
              type="text"
              className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
              placeholder="Marco Campos"
              required
            />
          </label>
          <label className="block text-sm">
            Email
            <input
              {...register("email")}
              type="email"
              className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
              placeholder="Marco.campos@gmail.com"
              readOnly
            />
          </label>
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <label className="block text-sm">
            Secondary Email
            <input
              {...register("secondery_email")}
              type="email"
              className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
              placeholder="marco12345@gmail.com"
            />
          </label>
          <label className="block text-sm">
            Phone Number
            <input
              {...register("phone")}
              type="text"
              className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
              placeholder="+1-202-555-0118"
            />
          </label>
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <label className="block text-sm">
            Country/Region
            <select
              {...register("country_id")}
              className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-select focus:ring-0 focus:border-skyBlue text-sm"
            >
              {countries?.map((item, i) => (
                <option key={i} value={item.id}>
                  {item.country_name}
                </option>
              ))}
            </select>
          </label>
          <div className="grid grid-cols-2 gap-4">
            <label className="block text-sm">
              States
              <select
                {...register("state_id")}
                className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-select focus:ring-0 focus:border-skyBlue text-sm"
              >
                {filteredStates?.map((item, i) => (
                  <option key={i + 1} value={item.id}>
                    {item.state_name}
                  </option>
                ))}
              </select>
            </label>
            <label className="block text-sm">
              Zip Code
              <input
                {...register("zip_code")}
                type="text"
                className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
                placeholder="60007"
              />
            </label>
          </div>
        </div>
        <button
          type="submit"
          style={{ "--hover-bg": `black`, "--hover-txt": "white" }}
          className="!mt-6 btn-hover-effect bg-skyBlue text-white px-6 py-3 rounded-sm"
          disabled={loading}
        >
          SAVE CHANGES
        </button>
      </div>
    </form>
  );
};

export default ProfileUpdateForm;
