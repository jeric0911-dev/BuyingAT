"use client";

import Image from "next/image";
import { useEffect, useState } from "react";
import {
  FacebookIcon,
  FacebookShareButton,
  LinkedinIcon,
  LinkedinShareButton,
  PinterestIcon,
  PinterestShareButton,
  TwitterShareButton,
  WhatsappIcon,
  WhatsappShareButton,
  XIcon,
} from "react-share";
import { toast } from "sonner";

const Share = () => {
  const [url, setUrl] = useState("");

  useEffect(() => {
    if (typeof window !== "undefined") {
      setUrl(window.location.href);
    }
  }, []);

  const handleClick = async () => {
    try {
      await navigator.clipboard.writeText(url);
      toast.success("Copied!");
    } catch (err) {
      toast.error("Failed to copy!");
    }
  };

  return (
    <div
      className="flex items-center gap-2"
      role="group"
      aria-label="Share options"
    >
      <WhatsappShareButton url={url} aria-label="Share on Whatsapp">
        <WhatsappIcon className="size-6 sm:size-7 lg:size-10" round />
      </WhatsappShareButton>
      <FacebookShareButton url={url} aria-label="Share on Facebook">
        <FacebookIcon className="size-6 sm:size-7 lg:size-10" round />
      </FacebookShareButton>
      <TwitterShareButton url={url} aria-label="Share on Twitter">
        <XIcon className="size-6 sm:size-7 lg:size-10" round />
      </TwitterShareButton>
      <LinkedinShareButton url={url} aria-label="Share on Linkedin">
        <LinkedinIcon className="size-6 sm:size-7 lg:size-10" round />
      </LinkedinShareButton>
      <PinterestShareButton
        url={url}
        media={`${url}/${"exampleImage"}`}
        aria-label="Share on Pinterest"
      >
        <PinterestIcon className="size-6 sm:size-7 lg:size-10" round />
      </PinterestShareButton>
      <button
        onClick={handleClick}
        aria-label="Copy link"
        className="cursor-pointer"
      >
        <Image
          src="/icon/link.svg"
          alt="Copy link"
          width={40}
          height={40}
          className="size-6 sm:size-7 lg:size-10"
        />
      </button>
    </div>
  );
};

export default Share;
