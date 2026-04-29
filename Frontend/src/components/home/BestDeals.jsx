import { Link } from "next-view-transitions";
import Image from "next/image";
import ProductCard from "./ProductCard";
import { getBestDeals } from "@/actions/others";

const BestDeals = async () => {
  const { data } = await getBestDeals();

  return (
    <section className="mt-24">
      <div className="flex justify-between items-center">
        <p className="text-2xl font-semibold">Best Deals</p>
        <Link
          href="/products?sort_by=discount"
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
      <div className="mt-10 grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 xl:grid-cols-5 border border-border">
        {data?.map((item) => (
          <ProductCard key={item.id} data={item} />
        ))}
      </div>
    </section>
  );
};

export default BestDeals;
