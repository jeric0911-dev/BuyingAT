"use client";

import { replayTicket } from "@/actions/vendor";
import { success } from "@/constants";
import objectToFormData from "@/utils/objectToFormData";
import { useState } from "react";
import { useForm } from "react-hook-form";
import { toast } from "sonner";

const ReplayMessageForm = ({ data }) => {
  const [loading, setLoading] = useState(false);
  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm({ defaultValues: { message: "", file: null } });

  const onSubmit = async (values) => {
    const toastId = toast.loading("Sending message...");
    setLoading(true);
    const res = await replayTicket(
      objectToFormData({ ...values, ticket_id: data?.[0]?.ticket_id })
    );
    setLoading(false);
    if (res.status === success) {
      toast.success("Message sent", { id: toastId });
      reset();
    } else {
      toast.error(res.message || "Failed to sent message", {
        id: toastId,
      });
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="p-5 flex flex-col gap-6">
      <label className="block text-sm">
        Message
        <textarea
          {...register("message")}
          className="input-base form-textarea mt-2 resize-none h-40 w-full"
          required
        />
      </label>
      <label className="block text-sm">
        Attachment
        <input
          {...register("file", {
            validate: {
              fileSize: (fileList) =>
                Array.from(fileList).every(
                  (file) => file.size <= 5 * 1024 * 1024
                ) || "Each file must be less than 5MB",
            },
          })}
          type="file"
          multiple
          className="mt-2 w-full border border-border rounded-sm cursor-pointer file:mr-4 file:h-11 file:px-4 file:border-0 file:text-sm file:bg-slate-100"
        />
        {errors.attachment && (
          <p className="mt-1 text-sm text-red-500">{errors.file.message}</p>
        )}
      </label>
      <button
        type="submit"
        style={{ "--hover-bg": `black`, "--hover-txt": "white" }}
        className="!mt-6 lg:col-span-2 btn-hover-effect bg-skyBlue text-white px-6 py-3 rounded-sm"
        disabled={loading || !data?.[0]?.support_ticket?.status}
      >
        SUBMIT
      </button>
    </form>
  );
};

export default ReplayMessageForm;
