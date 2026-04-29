import Image from "next/image";
import Container from "../shared/Container";
import ShopNow from "../buttons/ShopNow";
import { getHeroData } from "@/actions/others";

const Hero = async () => {
  const { data } = await getHeroData();

  return (
    <div className="relative h-[580px]">
      <Image
        src={`${process.env.NEXT_PUBLIC_IMG_URL}/${data?.banner}`}
        alt="hero-img"
        fill
        className="object-cover object-top -z-10"
      />
      <Container>
        <div className="flex items-center justify-center xl:w-1/2 h-full">
          <div className="px-5 md:px-16">
            <p className="text-4xl md:text-5xl lg:text-6xl text-white font-semibold">
              {data?.hero_title}
            </p>
            <p className="text-base lg:text-lg text-white font-medium mt-5">
              {data?.hero_description}
            </p>
            <ShopNow
              size={18}
              link="/products"
              cls={
                "w-[140px] inline-block text-[#053B5F] text-sm font-bold bg-yellow py-3 rounded-sm mt-10"
              }
            />
          </div>
        </div>
      </Container>
    </div>
  );
};

export default Hero;
