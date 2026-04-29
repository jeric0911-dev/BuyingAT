"use client";

import { useState } from "react";
import ManageStock from "./ManageStock";
import StockModal from "./StockModal";

const StockButton = ({ data }) => {
  const [open, setOpen] = useState(false);
  const stock = data?.stocks?.length
    ? data?.stocks?.reduce((sum, item) => sum + item.stock, 0)
    : data.stock;

  return (
    <>
      <div className="flex items-center gap-6">
        <div>
          <p className="text-sm text-[#5F6C72]">In Stock</p>
          <p className="text-green font-bold mt-1">{stock}</p>
        </div>
        <div className="bg-border w-px h-10" />
        <button
          onClick={() => setOpen(true)}
          className="bg-skyBlue text-white rounded text-sm font-semibold p-1.5 md:p-2.5"
        >
          <span className="hidden md:block">Add/Subtract</span>
          <span className="md:hidden text-xl font-bold">+ / -</span>
        </button>
      </div>
      {data?.colors?.length < 1 &&
        data?.sizes?.length < 1 &&
        data?.variants?.length < 1 &&
        open && <StockModal open={open} setOpen={setOpen} data={data} />}
      {(data?.colors?.length > 0 ||
        data?.sizes?.length > 0 ||
        data?.variants?.length > 0) &&
        open && <ManageStock open={open} setOpen={setOpen} data={data} />}
    </>
  );
};

export default StockButton;
