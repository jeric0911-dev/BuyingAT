import Image from "next/image";
import { Link } from "next-view-transitions";
import ProductCard from "./ProductCard";
import { getBanner, getFeatured } from "@/actions/others";

const FeaturedProducts = async () => {
  const [{ data }, { data: banner }] = await Promise.all([
    getFeatured(),
    getBanner(),
  ]);

  return (
    <section className="mt-24">
      <div className="grid grid-cols-1 md:grid-cols-[1fr_300px] gap-6">
        <div>
          <div className="flex justify-between items-center">
            <p className="text-2xl font-semibold">Featured Products</p>
            <Link
              href="/products?is_featured=1"
              className="flex items-center md:gap-2 group"
            >
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
          <div className="mt-6 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-2 sm:gap-4">
            {data?.map((item) => (
              <ProductCard key={item.id} data={item} star={true} />
            ))}
          </div>
        </div>
        <Link href={banner?.link_4}>
          <Image
            src={`${process.env.NEXT_PUBLIC_IMG_URL}/${banner?.img_4}`}
            alt="#"
            width={0}
            height={0}
            sizes="100vw"
            className="object-contain w-full h-[700px] md:h-full"
          />
        </Link>
      </div>
    </section>
  );
};

export default FeaturedProducts;
