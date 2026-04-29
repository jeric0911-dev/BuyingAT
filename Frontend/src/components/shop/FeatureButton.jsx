"use client";

import Image from "next/image";
import { useState } from "react";
import BoostModal from "./BoostModal";

const FeatureButton = ({ data }) => {
  const [open, setOpen] = useState(false);

  return (
    <div>
      <button
        onClick={() => setOpen(true)}
        className={`${
          data?.is_featured ? "bg-green" : "bg-orange"
        } rounded size-full flex justify-center items-center gap-2`}
      >
        <Image src="/icon/boost.svg" alt="boost icon" width={16} height={16} />
        <span className="text-white">Boost</span>
      </button>
      <BoostModal open={open} setOpen={setOpen} data={data} />
    </div>
  );
};

export default FeatureButton;
