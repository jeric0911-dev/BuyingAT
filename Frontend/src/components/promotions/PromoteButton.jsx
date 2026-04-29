"use client";

import { useState } from "react";
import useAuth from "@/hooks/useAuth";
import PromoteModal from "./PromoteModal";

export default function PromoteButton({ card }) {
  const { user } = useAuth();
  const [open, setOpen] = useState(false);

  if (!user || !card?.seller?.id || user.id !== card.seller.id) return null;

  return (
    <>
      <button
        onClick={() => setOpen(true)}
        className="border border-skyBlue px-4 h-10 text-skyBlue rounded-[3px]"
      >
        Promote
      </button>
      {open && (
        <PromoteModal cardId={card.id} onClose={() => setOpen(false)} />
      )}
    </>
  );
}


