"use client";

import { updateUserBillingAddress } from "@/actions/auth";
import { success } from "@/constants";
import { useState } from "react";
import { useForm } from "react-hook-form";
import { toast } from "sonner";

const BillingAddressForm = ({ data, countries, states }) => {
  const [loading, setLoading] = useState(false);

  const { register, handleSubmit, watch } = useForm({
    defaultValues: {
      first_name: data?.first_name,
      last_name: data?.last_name,
      company_name: data?.company_name,
      address: data?.address,
      country_id: data?.country_id ?? 1,
      state_id: data?.state_id ?? 1,
      city_id: data?.city_id ?? 1,
      zip_code: data?.zip_code,
      email: data?.email,
      phone: data?.phone,
    },
  });

  const filteredStates = states?.filter(
    (item) => item?.country_id == watch("country_id")
  );

  const onSubmit = async (values) => {
    setLoading(true);
    const toastId = toast.loading("Updating...");
    const res = await updateUserBillingAddress(values);
    setLoading(false);
    if (res.status === success) {
      toast.success("Billing Address updated successfully!", { id: toastId });
    } else {
      toast.error(res.message || "Something went wrong!", { id: toastId });
    }
  };

  return (
    <aside className="border border-border rounded">
      <p className="px-6 py-4 text-sm font-medium">BILLING ADDRESS</p>
      <hr />
      <form onSubmit={handleSubmit(onSubmit)} className="p-6 space-y-4">
        <div className="grid grid-cols-2 gap-4">
          <label className="block text-sm">
            First Name
            <input
              {...register("first_name")}
              type="text"
              className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
              placeholder="Marco"
              required
            />
          </label>
          <label className="block text-sm">
            Last Name
            <input
              {...register("last_name")}
              type="text"
              className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
              placeholder="Campos"
              required
            />
          </label>
        </div>
        <label className="block text-sm">
          Company Name (Optional)
          <input
            {...register("company_name")}
            type="text"
            className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
          />
        </label>
        <label className="block text-sm">
          Address
          <input
            {...register("address")}
            type="text"
            className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
            placeholder="15B Altabrisa Missan II"
          />
        </label>
        <label className="block text-sm">
          Region/State
          <select
            {...register("country_id")}
            className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-select focus:ring-0 focus:border-skyBlue text-sm"
            required
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
              required
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
              placeholder="97130"
              required
            />
          </label>
        </div>
        <label className="block text-sm">
          Email
          <input
            {...register("email")}
            type="email"
            className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
            placeholder="marco12345@gmail.com"
            required
          />
        </label>
        <label className="block text-sm">
          Phone Number
          <input
            {...register("phone")}
            type="text"
            className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
            placeholder="+1-202-555-0118"
            required
          />
        </label>
        <button
          type="submit"
          style={{ "--hover-bg": `black`, "--hover-txt": "white" }}
          className={`!mt-6 btn-hover-effect bg-skyBlue text-white px-6 py-3 rounded-sm ${
            loading && "opacity-50 cursor-not-allowed"
          }`}
          disabled={loading}
        >
          SAVE CHANGES
        </button>
      </form>
    </aside>
  );
};

export default BillingAddressForm;
