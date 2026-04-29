import { Link } from "next-view-transitions";
import ProductCard from "./ProductCard";
import Image from "next/image";
import { getBanner, getCategoryAccessories } from "@/actions/others";

const ComputerAccessories = async () => {
  const [{ data }, { data: banner }] = await Promise.all([
    getCategoryAccessories(),
    getBanner(),
  ]);

  return (
    <>
      <section className="mt-24">
        <div className="grid grid-cols-1 md:grid-cols-[300px_1fr] gap-6">
          <Link href={banner?.link_7}>
            <Image
              src={`${process.env.NEXT_PUBLIC_IMG_URL}/${banner?.img_7}`}
              alt="#"
              width={0}
              height={0}
              sizes="100vw"
              className="object-contain w-full h-[700px] md:h-full order-2 md:order-1"
            />
          </Link>
          <div className="order-1 md:order-2">
            <div className="flex justify-between items-center">
              <p className="text-2xl font-semibold">{data?.category?.title}</p>
              <Link
                href={`/products?category_id=${data?.category?.id}`}
                className="flex items-center gap-2 group"
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
              {data?.products?.map((item) => (
                <ProductCard key={item.id} data={item} star={true} />
              ))}
            </div>
          </div>
        </div>
      </section>
      <section className="mt-14 lg:mt-24">
        <Link href={banner?.link_8}>
          <Image
            src={`${process.env.NEXT_PUBLIC_IMG_URL}/${banner?.img_8}`}
            alt="#"
            width={0}
            height={0}
            sizes="100vw"
            className="size-full object-contain"
          />
        </Link>
      </section>
    </>
  );
};

export default ComputerAccessories;
