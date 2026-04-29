"use client";

import { closeTicket } from "@/actions/vendor";
import { success } from "@/constants";
import { useState } from "react";
import { toast } from "sonner";

const CloseTicketButton = ({ data }) => {
  const [loading, setLoading] = useState(false);
  const handleCloseTicket = async () => {
    setLoading(true);
    const toastId = toast.loading("Closing ticket...");
    const res = await closeTicket(data?.[0]?.ticket_id);
    setLoading(false);
    if (res.status === success) {
      toast.success("Ticket closed successfully", { id: toastId });
    } else {
      toast.error(error.message || "Failed to close ticket", { id: toastId });
    }
  };

  return (
    <button
      onClick={handleCloseTicket}
      className="text-red-500 bg-red-100 border border-red-500 px-3 py-2 rounded text-xs font-semibold disabled:bg-inherit"
      disabled={loading}
    >
      Close Ticket
    </button>
  );
};

export default CloseTicketButton;
