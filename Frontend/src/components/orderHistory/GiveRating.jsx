"use client";

import Image from "next/image";
import { useState } from "react";
import ReviewModal from "../product/ReviewModal";

const GiveRating = ({ data }) => {
  const [open, setOpen] = useState(false);

  return (
    <>
      <button onClick={() => setOpen(true)} className="flex items-center gap-2">
        <span className="text-sm font-semibold text-skyBlue">
          Leave a Rating
        </span>
        <Image src="/icon/plusBlue2.svg" alt="#" width={20} height={20} />
      </button>
      <ReviewModal
        open={open}
        setOpen={setOpen}
        data={data?.ordered_items}
      />
    </>
  );
};

export default GiveRating;
