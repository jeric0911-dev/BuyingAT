"use client";

import updateQueryParam from "@/utils/updateQueryParam";
import { useSearchParams } from "next/navigation";

const SizeBox = ({ sizes }) => {
  const searchParams = useSearchParams();
  const selected = searchParams.get("size") //?? sizes[0]?.id;

  return (
    <label className="block text-sm">
      Size
      <div className="flex items-center gap-3 mt-2">
        {sizes?.map((item) => (
          <div
            key={item.id}
            onClick={() => updateQueryParam("size", item?.id)}
            className={`border uppercase h-11 px-3 ${
              selected == item?.id ? "border-skyBlue" : "border-border"
            }  flex justify-center items-center`}
          >
            {item?.size}
          </div>
        ))}
      </div>
    </label>
  );
};

export default SizeBox;
