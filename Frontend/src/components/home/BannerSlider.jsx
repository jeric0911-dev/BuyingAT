/* eslint-disable react-hooks/exhaustive-deps */
"use client";

import { useTransitionRouter } from "next-view-transitions";
import Image from "next/image";
import { useEffect, useState } from "react";

const BannerSlider = ({ slides }) => {
  const [currentSlide, setCurrentSlide] = useState(0);
  const [touchPosition, setTouchPosition] = useState(null);
  const [mousePosition, setMousePosition] = useState(null);
  const router = useTransitionRouter();

  useEffect(() => {
    const interval = setInterval(() => {
      nextSlide();
    }, 5000);
    return () => clearInterval(interval);
  }, [currentSlide]);

  const nextSlide = () => {
    setCurrentSlide((prev) => (prev + 1) % slides?.length);
  };

  const goToSlide = (index) => {
    setCurrentSlide(index);
  };

  const handleTouchStart = (e) => {
    setTouchPosition(e.touches[0]?.clientX);
  };

  const handleTouchMove = (e) => {
    if (touchPosition === null) return;

    const touchMove = e.touches[0].clientX;
    const diff = touchPosition - touchMove;

    if (diff < -5) {
      setCurrentSlide((prev) => (prev - 1 + slides.length) % slides.length);
    } else if (diff > 5) {
      nextSlide();
    }
    setTouchPosition(null);
  };

  const handleMouseDown = (e) => {
    setMousePosition(e.clientX);
    setIsDragging(true);
    e.preventDefault(); // Prevent text selection
  };

  const handleMouseMove = (e) => {
    if (mousePosition === null) return;

    const currentMouse = e.clientX;
    const diff = mousePosition - currentMouse;

    if (diff > 50) {
      nextSlide();
      setMousePosition(null);
    } else if (diff < -50) {
      setCurrentSlide((prev) => (prev - 1 + slides.length) % slides.length);
      setMousePosition(null);
    }
  };

  const handleMouseUp = () => {
    setMousePosition(null);
  };

  const handleMouseLeave = () => {
    setMousePosition(null);
  };

  const handleClick = (item) => {
    router.push(item?.link);
  };

  return (
    <div className="relative h-[200px] sm:h-[300px] md:h-[450px] lg:h-[520px]">
      <div
        onTouchStart={handleTouchStart}
        onTouchMove={handleTouchMove}
        onMouseDown={handleMouseDown}
        onMouseMove={handleMouseMove}
        onMouseUp={handleMouseUp}
        onMouseLeave={handleMouseLeave}
        className="overflow-hidden rounded-md"
      >
        <div
          className="flex transition-transform duration-1000 ease-in-out"
          style={{ transform: `translateX(-${currentSlide * 100}%)` }}
        >
          {slides?.map((item) => (
            <div
              key={item.id}
              onClick={() => handleClick(item)}
              className="relative h-[200px] sm:h-[300px] md:h-[450px] lg:h-[520px] w-full flex-shrink-0 rounded-md"
            >
              <Image
                src={`${process.env.NEXT_PUBLIC_IMG_URL}/${item?.img}`}
                alt="img"
                fill
                className="object-cover rounded-md"
              />
            </div>
          ))}
        </div>
      </div>

      <div className="absolute bottom-4 left-1/2 transform -translate-x-1/2 flex space-x-2">
        {slides.map((_, index) => (
          <button
            key={index}
            onClick={() => goToSlide(index)}
            className={`size-2 md:size-2.5 rounded-full transition-all duration-300 ${
              currentSlide === index ? "bg-tBlack" : "bg-[#ADB7BC]"
            }`}
            aria-label={`Go to slide ${index + 1}`}
          />
        ))}
      </div>
    </div>
  );
};

export default BannerSlider;
