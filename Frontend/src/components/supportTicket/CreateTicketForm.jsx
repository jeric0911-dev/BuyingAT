"use client";

import { createTicket } from "@/actions/vendor";
import { success } from "@/constants";
import objectToFormData from "@/utils/objectToFormData";
import { useTransitionRouter } from "next-view-transitions";
import { useState } from "react";
import { useForm } from "react-hook-form";
import { toast } from "sonner";

const CreateTicketForm = () => {
  const [loading, setLoading] = useState(false);
  const router = useTransitionRouter();
  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm();

  const onSubmit = async (values) => {
    const toastId = toast.loading("Creating ticket...");
    setLoading(true);
    const res = await createTicket(objectToFormData(values));
    setLoading(false);
    if (res.status === success) {
      toast.success("Ticket created successfully", {
        id: toastId,
      });
      reset();
      router.push(`/support-ticket/${res.data.ticket.id}`);
    } else {
      toast.error(res.message || "Failed to create ticket", {
        id: toastId,
      });
    }
  };

  return (
    <form
      onSubmit={handleSubmit(onSubmit)}
      className="grid grid-cols-1 lg:grid-cols-2 gap-6"
    >
      <label className="block text-sm">
        Subject
        <input
          {...register("subject")}
          type="text"
          className="mt-2 input-input"
          required
        />
      </label>
      <label className="block text-sm overflow-hidden">
        Priority
        <select
          {...register("priority")}
          className="input-select text-tBlack mt-2 overflow-hidden"
          aria-label="Select Priority"
          required
        >
          <option value="">Select Priority</option>
          <option value="high">High</option>
          <option value="medium">Medium</option>
          <option value="low">Low</option>
        </select>
      </label>
      <label className="block text-sm lg:col-span-2">
        Message
        <textarea
          {...register("message")}
          className="input-base form-textarea mt-2 resize-none h-40"
          required
        />
      </label>
      <label className="block text-sm lg:col-span-2">
        Attachment
        <input
          {...register("attachment", {
            validate: {
              fileSize: (fileList) =>
                !fileList[0] ||
                fileList[0].size <= 5 * 1024 * 1024 ||
                "File size must be less than 5MB",
            },
          })}
          type="file"
          className="mt-2 w-full border border-border rounded-sm cursor-pointer file:mr-4 file:h-11 file:px-4 file:border-0 file:text-sm file:bg-slate-100"
        />
        {errors.attachment && (
          <p className="mt-1 text-sm text-red-500">
            {errors.attachment.message}
          </p>
        )}
      </label>
      <button
        type="submit"
        style={{ "--hover-bg": `black`, "--hover-txt": "white" }}
        className="!mt-6 lg:col-span-2 btn-hover-effect bg-skyBlue text-white px-6 py-3 rounded-sm"
        disabled={loading}
      >
        SUBMIT
      </button>
    </form>
  );
};

export default CreateTicketForm;
