"use client";

import Slider from "react-slick";
import { useRef } from "react";
import Image from "next/image";

const MySlider = ({ children, slidesToShow }) => {
  const slider = useRef(null);
 
  return (
    <div className="relative">
      <Slider
      responsive={[
        {
          breakpoint: 1024,
          settings: {
            slidesToShow: 4,
            slidesToScroll: 1,
            infinite: true,
            dots: true
          }
        },
        {
          breakpoint: 680,
          settings: {
            slidesToShow: 3,
            slidesToScroll: 1,
            initialSlide: 2
          }
        },
        {
          breakpoint: 480,
          settings: {
            slidesToShow: 2,
            slidesToScroll: 1
          }
        }
      ]}
        ref={slider}
        slidesToShow={slidesToShow}
        slidesToScroll={1}
        swipeToSlide={true}
        infinite={true}
        speed={500}
        
      >
        {children}
      </Slider>
      <Image
        src="/icon/arrow-button.svg"
        alt="prev"
        width={48}
        height={48}
        className="absolute left-1 rotate-180 top-[91px] transition-transform duration-200 hover:scale-110 active:scale-95 cursor-pointer"
        onClick={() => slider?.current?.slickPrev()}
      />
      <Image
        src="/icon/arrow-button.svg"
        alt="prev"
        width={48}
        height={48}
        className="absolute right-1 top-[91px] transition-transform duration-200 hover:scale-110 active:scale-95 cursor-pointer"
        onClick={() => slider?.current?.slickNext()}
      />
    </div>
  );
};

export default MySlider;
