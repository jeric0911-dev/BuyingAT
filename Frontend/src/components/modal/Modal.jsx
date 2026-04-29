"use client";

import { Transition } from "@headlessui/react";
import Image from "next/image";
import { useEffect, useState } from "react";

const Modal = ({ open, handleClose, title, children }) => {
  const [isMounted, setIsMounted] = useState(false);

  useEffect(() => {
    const adjustStyles = () => {
      const isMobile = window.innerWidth < 1024;
      if (open) {
        document.body.style.overflow = "hidden";
        document.body.style.paddingRight = isMobile ? "0px" : "17px";
      } else {
        document.body.style.overflow = "";
        document.body.style.paddingRight = "";
      }
    };

    adjustStyles();
    setIsMounted(true);
    window.addEventListener("resize", adjustStyles);

    return () => {
      document.body.style.overflow = "";
      document.body.style.paddingRight = "";
      window.removeEventListener("resize", adjustStyles);
    };
  }, [open]);

  if (!open && !isMounted) return null;

  return (
    <Transition
      show={open}
      enter="transition transform duration-150 ease-out"
      enterFrom="opacity-0"
      enterTo="opacity-100"
      leave="transition transform duration-150 ease-in"
      leaveFrom="opacity-100"
      leaveTo="opacity-0"
    >
      <div className="fixed inset-0 flex justify-center items-center z-50">
        <div className="fixed inset-0 bg-black/60 transition-all duration-300" />
        <div className="absolute bg-white shadow-lg w-full max-w-[700px] max-h-[calc(100vh-40px)] rounded px-4 lg:px-16 py-8 lg:pb-10 flex flex-col border border-border">
          <button
            onClick={() => {
              handleClose.setOpen(false);
              if (handleClose.onClose) handleClose.onClose();
            }}
            className="absolute top-8 right-8"
          >
            <Image src="/icon/modal-cross.svg" alt="X" width={13} height={13} />
          </button>
          <p className="text-2xl text-tBlack font-semibold text-center">
            {title}
          </p>
          <div className="mt-4 grow size-full overflow-y-auto [&::-webkit-scrollbar]:hidden [-ms-overflow-style:'none'] [scrollbar-width:'none']">
            {children}
          </div>
        </div>
      </div>
    </Transition>
  );
};

export default Modal;
