"use client";

import updateQueryParam from "@/utils/updateQueryParam";
import { useSearchParams } from "next/navigation";

const VariantBox = ({ variants }) => {
  const searchParams = useSearchParams();
  const selected = searchParams.get("variants"); //?? variants[0]?.id;

  return (
    <label className="block text-sm">
      Variation
      <select
        onChange={(e) => updateQueryParam("variant", e.target.value)}
        className="mt-2 input-select"
        defaultValue={selected}
      >
        <option value="">Select</option>
        {variants?.map((item) => (
          <option key={item.id} value={item?.id}>
            {item?.variant_name}
          </option>
        ))}
      </select>
    </label>
  );
};

export default VariantBox;
