import Image from "next/image";
import { Link } from "next-view-transitions";

const CategoryCard = ({ data }) => {
  return (
    <Link href={`/products?category_id=${data?.id}`} className="group ">
      <div className="min-w-[150px] h-[230px] border border-border rounded px-3 py-6 flex flex-col items-center justify-center gap-4">
        <Image
          src={`${process.env.NEXT_PUBLIC_IMG_URL}/${data?.icon}`}
          alt="img"
          width={148}
          height={148}
          sizes="100vw"
          className="object-contain group-hover:scale-105 transition-all duration-150"
          /> 
        <p className="font-medium text-center group-hover:underline underline-offset-4 transition-all duration-300">{data?.category_name}</p>
      </div>
    </Link>
  );
};

export default CategoryCard;
