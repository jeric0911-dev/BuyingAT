"use client";

import { usePathname } from "next/navigation";
import Script from "next/script";
import { useEffect, useState } from "react";

const FacebookPixel = ({ id }) => {
  const [loaded, setLoaded] = useState(false);
  const pathname = usePathname();

  useEffect(() => {
    if (!loaded || !window.fbq) return;
    window.fbq("track", "PageView");
  }, [pathname, loaded]);

  useEffect(() => {
    const event = (name, options = {}) => {
      if (!window.fbq) {
        console.warn("Facebook Pixel not initialized");
        return;
      }
      window.fbq("track", name, options);
    };
    window.event = event;
    return () => {
      delete window.event;
    };
  }, []);

  if (!id) {
    console.warn("Facebook Pixel ID is missing");
    return null;
  }

  return (
    <Script
      id="fb-pixel"
      src="/scripts/pixel.js"
      strategy="afterInteractive"
      onLoad={() => setLoaded(true)}
      data-pixel-id={id}
    />
  );
};

export default FacebookPixel;
