"use client";

import { useState } from "react";
import Cookies from "js-cookie";
import { authKey, success } from "@/constants";
import { postComment } from "@/actions/others";
import { toast } from "sonner";
import { useTransitionRouter } from "next-view-transitions";

const MakeComment = ({ id }) => {
  const [text, setText] = useState("");
  const [loading, setLoading] = useState(false);
  const token = Cookies.get(authKey);
  const router = useTransitionRouter()

  const handleComment = async (e) => {
    e.preventDefault();
    setLoading(true);
    if (!token) {
      router.push("/login");
    } else {
      const toastId = toast.loading("Posting...");
      const res = await postComment({ blog_id: id, comment: text });
      setLoading(false);
      if (res.status === success) {
        setText("");
        router.refresh();
        toast.success("Comment posted!", { id: toastId });
      } else {
        toast.error(res.message || "Something went wrong!", { id: toastId });
      }
    }
  };

  return (
    <form onSubmit={handleComment} className="mt-12">
      <p className="text-xl font-medium">Comment</p>
      <textarea
        onChange={(e) => setText(e.target.value)}
        value={text}
        className="form-textarea w-full px-4 py-2 mt-6 text-sm border-border rounded-sm focus:ring-0 focus:border-skyBlue"
        rows="6"
        placeholder="What’s your thought about this blog..."
        required
      />
      <button
        type="submit"
        className="mt-6 bg-skyBlue text-white text-sm px-6 py-3 rounded-sm"
        disabled={loading}
      >
        SUBMIT
      </button>
    </form>
  );
};

export default MakeComment;
