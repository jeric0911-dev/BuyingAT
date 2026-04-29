"use client";

import { useState } from "react";
import relativeTime from "dayjs/plugin/relativeTime";
import dayjs from "dayjs";
import Review from "../product/Review";
import Specification from "../product/Specification";
import AdditionalInfo from "../product/AdditionalInfo";
dayjs.extend(relativeTime);

const tabs = [
  "description",
  "additional information",
  "specification",
  "review",
];

const CardDetailTab = ({ data }) => {
  const [active, setActive] = useState("description");

  return (
    <section className="mt-14 border border-border rounded">
      <div className="h-14 border-b border-border overflow-x-auto scrollbar-hide">
        <div className="flex h-full min-w-max md:justify-center">
          {tabs.map((item) => (
            <button
              key={item}
              onClick={() => setActive(item)}
              className={`h-full px-5 uppercase whitespace-nowrap transition-colors duration-150 ${
                active === item
                  ? "border-b-2 border-skyBlue text-skyBlue"
                  : "text-tGray"
              }`}
            >
              {item}
            </button>
          ))}
        </div>
      </div>
      {active === "description" ? (
        <div className="p-10">
          <p className="font-semibold">Description</p>
          <p className="mt-3 text-sm text-tGray">{data?.description}</p>
        </div>
      ) : active === "additional information" ? (
        <AdditionalInfo data={data} />
      ) : active === "specification" ? (
        <Specification data={data} />
      ) : active === "review" ? (
        <Review data={data} />
      ) : null}
    </section>
  );
};

export default CardDetailTab;
