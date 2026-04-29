import Image from "next/image";
import Container from "../shared/Container";
import { getBanner, getBannerSlider } from "@/actions/others";
import BannerSlider from "./BannerSlider";
import { Link } from "next-view-transitions";

const BoostedProducts = async () => {
  const { data } = await getBanner();
  const { data: slides } = await getBannerSlider();

  return (
    <section className="mt-10">
      <Container>
        <div className="grid grid-cols-1 xl:grid-cols-[2fr_1fr] gap-6">
          <BannerSlider slides={slides} />
          <div className="hidden xl:grid grid-rows-2 gap-6">
            <Link
              href={data?.link_2}
              className="relative rounded-md overflow-hidden"
            >
              <Image
                src={`${process.env.NEXT_PUBLIC_IMG_URL}/${data?.img_2}`}
                alt="img"
                fill
                className="object-contain rounded-md"
              />
            </Link>
            <Link
              href={data?.link_3}
              className="relative rounded-md overflow-hidden"
            >
              <Image
                src={`${process.env.NEXT_PUBLIC_IMG_URL}/${data?.img_3}`}
                alt="img"
                fill
                className="object-contain rounded-md"
              />
            </Link>
          </div>
        </div>
      </Container>
    </section>
  );
};

export default BoostedProducts;
