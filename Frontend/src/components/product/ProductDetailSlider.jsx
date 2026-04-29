"use client";

import { shimmer } from "@/constants";
import toBase64 from "@/utils/toBase64";
import Image from "next/image";
import { useEffect, useRef, useState } from "react";

const ProductDetailSlider = ({ images }) => {
  const [currentIndex, setCurrentIndex] = useState(0);
  const mainImageRef = useRef(null);
  const thumbnailContainerRef = useRef(null);

  // Desktop zoom states
  const [showZoom, setShowZoom] = useState(false);
  const [zoomPosition, setZoomPosition] = useState({ x: 0, y: 0 });
  const [currentImage, setCurrentImage] = useState(images[0]?.img);

  // Mobile/Tablet specific states
  const [isMobile, setIsMobile] = useState(false);
  const [isZoomed, setIsZoomed] = useState(false);
  const [panPosition, setPanPosition] = useState({ x: 50, y: 50 });

  useEffect(() => {
    const handleResize = () => {
      const mobile = window.innerWidth < 1024;
      setIsMobile(mobile);
      if (!mobile) {
        setIsZoomed(false); // Ensure mobile zoom is off on desktop
      }
    };
    handleResize();
    window.addEventListener("resize", handleResize);
    return () => window.removeEventListener("resize", handleResize);
  }, []);

  useEffect(() => {
    if (images && images.length > 0) {
      setCurrentImage(images[currentIndex]?.img);
    }
  }, [currentIndex, images]);

  const handleMouseMove = (e) => {
    if (!mainImageRef.current || isMobile) return;
    const { left, top, width, height } =
      mainImageRef.current.getBoundingClientRect();
    const x = ((e.pageX - left) / width) * 100;
    const y = ((e.pageY - top) / height) * 100;
    setZoomPosition({ x, y });
  };

  const handleTouchMove = (e) => {
    if (!mainImageRef.current || !isZoomed) return;
    const touch = e.touches[0];
    const { left, top, width, height } =
      mainImageRef.current.getBoundingClientRect();
    const x = ((touch.pageX - left) / width) * 100;
    const y = ((touch.pageY - top) / height) * 100;
    setPanPosition({ x, y });
  };

  const toggleMobileZoom = () => {
    if (isMobile) {
      setIsZoomed(!isZoomed);
    }
  };

  const isSlider = images.length > 5;

  const nextSlide = () => {
    setCurrentIndex((prevIndex) => (prevIndex + 1) % images.length);
  };

  const prevSlide = () => {
    setCurrentIndex(
      (prevIndex) => (prevIndex - 1 + images.length) % images.length
    );
  };

  const handleThumbnailClick = (index) => {
    setCurrentIndex(index);
  };

  useEffect(() => {
    if (isSlider && thumbnailContainerRef.current) {
      const activeThumbnail =
        thumbnailContainerRef.current.children[currentIndex];
      if (activeThumbnail) {
        activeThumbnail.scrollIntoView({
          behavior: "smooth",
          inline: "center",
          block: "nearest",
        });
      }
    }
  }, [currentIndex, isSlider]);

  return (
    <div className="relative">
      <div
        ref={mainImageRef}
        className="relative"
        onMouseMove={handleMouseMove}
        onMouseEnter={() => !isMobile && setShowZoom(true)}
        onMouseLeave={() => !isMobile && setShowZoom(false)}
        onClick={toggleMobileZoom}
        onTouchMove={handleTouchMove}
      >
        {/* main img */}
        <div
          className={`border border-border rounded h-[460px] overflow-hidden flex items-center justify-center ${
            isMobile ? (isZoomed ? "cursor-zoom-out" : "cursor-zoom-in") : ""
          }`}
        >
          {images.length > 0 && (
            <Image
              src={`${process.env.NEXT_PUBLIC_IMG_URL}/${images[currentIndex]?.img}`}
              alt="image"
              width={0}
              height={0}
              sizes="100vw"
              priority
               placeholder={`data:image/svg+xml;base64,${toBase64(shimmer())}`}
              className="w-auto h-[460px] hover:cursor-zoom-in m-auto object-cover transition-transform duration-200 ease-out"
              style={{
                transform: isZoomed ? "scale(2)" : "scale(1)",
                transformOrigin: `${panPosition.x}% ${panPosition.y}%`,
              }}
            />
          )}
        </div>
      </div>
      {/* img options */}
      <div className="relative mt-6 mx-5 md:mx-10 xl:mx-0">
        <div
          ref={thumbnailContainerRef}
          className={`flex items-center py-2 gap-4 overflow-x-auto no-scrollbar mx-auto max-w-[34rem] ${
            isSlider ? "justify-start" : "justify-center"
          }`}
        >
          {images.map((item, i) => (
            <div
              key={i}
              className={`flex-shrink-0 cursor-pointer border-2 rounded-sm size-24 ${
                currentIndex === i
                  ? "border-skyBlue scale-105"
                  : "border-border"
              }`}
              onClick={() => handleThumbnailClick(i)}
            >
              <Image
                src={`${process.env.NEXT_PUBLIC_IMG_URL}/${item?.img}`}
                alt="#"
                width={96}
                height={96}
                sizes="100vw"
                className="w-full h-full object-cover rounded-sm"
              />
            </div>
          ))}
        </div>
        {isSlider && (
          <>
            <Image
              src="/icon/arrow-button.svg"
              alt="prev"
              width={48}
              height={48}
              className="absolute -left-7 lg:-left-3 rotate-180 top-1/2 -translate-y-1/2 transition-transform duration-200 hover:scale-105 active:scale-95 cursor-pointer"
              onClick={prevSlide}
            />
            <Image
              src="/icon/arrow-button.svg"
              alt="next"
              width={48}
              height={48}
              className="absolute -right-7 lg:-right-5 top-1/2 -translate-y-1/2 transition-transform duration-200 hover:scale-105 active:scale-95 cursor-pointer"
              onClick={nextSlide}
            />
          </>
        )}
      </div>
      {/* Desktop-only zoom window */}
      {showZoom && !isMobile && (
        <div
          className="absolute top-0 left-full ml-4 w-[500px] h-[460px] border border-border rounded-lg bg-no-repeat pointer-events-none hidden lg:block"
          style={{
            backgroundImage: `url(${process.env.NEXT_PUBLIC_IMG_URL}/${currentImage})`,
            backgroundPosition: `${zoomPosition.x}% ${zoomPosition.y}%`,
            backgroundSize: "250%",
            zIndex: 100,
          }}
        ></div>
      )}
    </div>
  );
};

export default ProductDetailSlider;
