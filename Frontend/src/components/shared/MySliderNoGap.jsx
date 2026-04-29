"use client";

import Slider from "react-slick";
import { useRef } from "react";
import Image from "next/image";
import Container from "./Container";
import { Link } from "next-view-transitions";

const MySliderNoGap = ({ children, slidesToShow, title, link }) => {
  const slider = useRef(null);
  return (
    <section className="mt-24">
      <Container>
        <div className="flex justify-between items-center">
          <p className="text-2xl font-semibold">{title}</p>
          <Link href={link} className="flex items-center gap-2 group">
            <p className="text-sm text-skyBlue font-semibold transition-transform duration-200 group-hover:scale-105">
              Browse All Product
            </p>
            <Image
              src="/icon/right-arrow-blue.svg"
              alt="arrow"
              width={20}
              height={20}
              className="transition-transform duration-200 group-hover:translate-x-1"
            />
          </Link>
        </div>
        <div className="mt-10">
          <div className="relative">
            <Slider
              responsive={[
                {
                  breakpoint: 1440,
                  settings: {
                    slidesToShow: 4,
                    slidesToScroll: 1,
                    infinite: true,
                    dots: true,
                  },
                },
                {
                  breakpoint: 1024,
                  settings: {
                    slidesToShow: 3,
                    slidesToScroll: 1,
                    infinite: true,
                    dots: true,
                  },
                },
                {
                  breakpoint: 780,
                  settings: {
                    slidesToShow: 2,
                    slidesToScroll: 1,
                    initialSlide: 2,
                  },
                },
                {
                  breakpoint: 550,
                  settings: {
                    slidesToShow: 1,
                    slidesToScroll: 1,
                  },
                },
              ]}
              ref={slider}
              slidesToShow={slidesToShow}
              slidesToScroll={1}
              swipeToSlide={true}
              infinite={true}
              speed={500}
              className="px-3"
            >
              {children}
            </Slider>
            <Image
              src="/icon/arrow-button.svg"
              alt="prev"
              width={48}
              height={48}
              className="absolute -left-3 rotate-180 top-1/2 -translate-y-1/2 transition-transform duration-200 hover:scale-110 active:scale-95 cursor-pointer"
              onClick={() => slider?.current?.slickPrev()}
            />
            <Image
              src="/icon/arrow-button.svg"
              alt="prev"
              width={48}
              height={48}
              className="absolute -right-3 top-1/2 -translate-y-1/2 transition-transform duration-200 hover:scale-110 active:scale-95 cursor-pointer"
              onClick={() => slider?.current?.slickNext()}
            />
          </div>
        </div>
      </Container>
    </section>
  );
};

export default MySliderNoGap;
