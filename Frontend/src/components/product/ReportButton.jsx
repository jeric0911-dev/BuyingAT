"use client";

import { useState } from "react";
import Modal from "../modal/Modal";
import { useForm } from "react-hook-form";
import Image from "next/image";
import handleAsyncToast from "@/utils/handleAsyncToast";
import { reportProduct } from "@/actions/vendor";
import Cookies from "js-cookie";
import { authKey } from "@/constants";
import { toast } from "sonner";

const ReportButton = ({ data }) => {
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const token = Cookies.get(authKey);

  const { register, handleSubmit, watch, reset } = useForm({
    defaultValues: { car_id: data?.id, title: "", description: "" },
  });

  const onSubmit = async (values) => {
    setLoading(true);
    handleAsyncToast({
      promise: reportProduct(values),
      success: () => "Report sent successfully",
    });
    setLoading(false);
    setOpen(false);
    reset()
  };

  return (
    <>
      <button
        className="bg-orange rounded flex justify-center items-center px-[18px] h-14 flex-1"
        onClick={() => {
          if (!token) return toast.error("You must login to report!");
          setOpen(true);
        }}
        aria-label="Report Product"
      >
        <Image src="/icon/report.svg" alt="report" width={20} height={20} />
      </button>

      <Modal
        open={open}
        handleClose={{
          setOpen,
          onClose() {
            reset();
          },
        }}
        title="Report Product"
      >
        <p className="text-lg text-tBlack mt-4 text-center max-w-[30ch] mx-auto">
          Report false or misleading information about this post
        </p>

        <form onSubmit={handleSubmit(onSubmit)} className="mt-4 flex flex-col">
          <label className="block text-sm" htmlFor="reason">
            Reasons
            <select
              id="reason"
              {...register("title")}
              className="mt-2 input-select"
              required
            >
              <option value="">-- Select a reason --</option>
              <option value="misleading">
                Misleading or False Information
              </option>
              <option value="inappropriate">Inappropriate Content</option>
              <option value="scam">Scam or Fraud</option>
              <option value="prohibited">Prohibited or Illegal Item</option>
              <option value="duplicate">Duplicate Listing</option>
              <option value="wrong-category">Wrong Category</option>
              <option value="counterfeit">Counterfeit or Fake Product</option>
              <option value="stolen">Stolen Item</option>
              <option value="abusive">Harassment or Abusive Seller</option>
              <option value="other">Other (please specify)</option>
            </select>
          </label>
          <label className="block text-sm mt-4" htmlFor="description">
            Description
            <textarea
              id="description"
              {...register("description")}
              className="mt-2 h-36 input-base form-textarea"
              placeholder="Say something"
            />
          </label>
          <label
            htmlFor="report"
            className="flex items-center gap-4 mt-6 w-max"
          >
            <input
              {...register("terms")}
              type="checkbox"
              id="report"
              className="form-checkbox rounded text-skyBlue focus:ring-0"
              required
            />
            <p className="text-tBlack text-sm">
              I accept all terms and conditions
            </p>
          </label>
          <button
            type="submit"
            style={{ "--hover-bg": `black`, "--hover-txt": "white" }}
            className="btn-hover-effect bg-skyBlue text-white px-6 py-3 rounded-sm mt-10 w-full"
            disabled={loading || !watch("terms")}
          >
            Send Report
          </button>
        </form>
      </Modal>
    </>
  );
};

export default ReportButton;
