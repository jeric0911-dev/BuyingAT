import { getBanner } from "@/actions/others";
import Image from "next/image";
import { Link } from "next-view-transitions";

const TwoBanner = async () => {
  const { data } = await getBanner();

  return (
    <section className="mt-[50px] lg:mt-[100px]">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-2 md:gap-6">
        <Link href={data?.link_5} className="h-[200px] md:h-[336px] relative">
          <Image
            src={`${process.env.NEXT_PUBLIC_IMG_URL}/${data?.img_5}`}
            alt="image"
            fill
            className="object-contain"
          />
        </Link>
        <Link href={data?.link_6} className="h-[200px] md:h-[336px] relative">
          <Image
            src={`${process.env.NEXT_PUBLIC_IMG_URL}/${data?.img_6}`}
            alt="image"
            fill
            className="object-contain"
          />
        </Link>
      </div>
    </section>
  );
};

export default TwoBanner;
