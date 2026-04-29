"use client";

import updateQueryParam from "@/utils/updateQueryParam";
import { useSearchParams } from "next/navigation";

const ColorBox = ({ colors }) => {
  const searchParams = useSearchParams();
  const selected = searchParams.get("color") //?? colors[0]?.color_name;

  return (
    <div>
      <p className="text-sm">Color</p>
      <div className="flex items-center gap-3 mt-2">
        {colors?.map((item, i) => (
          <div
            key={i}
            onClick={() => updateQueryParam("color", item?.id)}
            className={`size-11 border ${
              selected == item?.id
                ? "border-skyBlue"
                : "border-transparent"
            } rounded-full relative`}
          >
            <div
              style={{ backgroundColor: item?.color }}
              className="absolute inset-[5px] size-8 rounded-full"
            ></div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default ColorBox;
