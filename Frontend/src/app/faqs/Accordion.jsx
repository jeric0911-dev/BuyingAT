"use client";

import Image from "next/image";
import { useState } from "react";

const Accordion = ({ data }) => {
  const [accordionOpen, setAccordionOpen] = useState(false);

  return (
    <div
      className={`py-5 md:py-8 lg:px-6 rounded border border-border transition-colors ${
        accordionOpen && "border-skyBlue/30 bg-skyBlue/5"
      }`}
    >
      <button
        onClick={() => setAccordionOpen((p) => !p)}
        className="flex justify-between items-center w-full md:text-lg font-medium pl-2 md:p-0"
      >
        <span className="text-tBlack flex-1 text-start">
          {data?.qua}
        </span>
        <span
          className={`size-10 rounded-full flex items-center justify-center ${
            accordionOpen ? "lg:bg-white lg:shadow-xl" : "lg:bg-skyBlue/10"
          }`}
        >
          <Image
            src="/icon/arrow-blue.svg"
            alt=""
            width={16}
            height={16}
            className={`${
              accordionOpen ? "-rotate-180" : ""
            } transition-all duration-300`}
          />
        </span>
      </button>
      <div
        className={`grid transition-all duration-300 ease-in-out ${
          accordionOpen
            ? "grid-rows-[1fr] opacity-100"
            : "grid-rows-[0fr] opacity-0"
        }`}
      >
        <div
          className={`overflow-hidden text-tGray pl-2 lg:p-0 font-medium max-w-[85%] ${
            accordionOpen ? "mt-3" : "mt-0"
          } transition-all duration-300`}
        >
          {data?.ans}
        </div>
      </div>
    </div>
  );
};

export default Accordion;
