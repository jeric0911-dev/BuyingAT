import Image from "next/image";
import ShopNow from "../buttons/ShopNow";
import dayjs from "dayjs";
import toBase64 from "@/utils/toBase64";
import { shimmer } from "@/constants";

const BlogCard = ({ data, padding }) => {
  return (
    <div
      className={`p-${padding} border border-border rounded flex flex-col w-full transition-all duration-300 hover:shadow-lg hover:-translate-y-1`}
    >
      <div className="h-[248px] w-full relative">
        <Image
          src={`${process.env.NEXT_PUBLIC_IMG_URL}/${data?.blog_thumb_img}`}
          alt="#"
          fill
          placeholder={`data:image/svg+xml;base64,${toBase64(shimmer())}`}
          className="object-cover rounded"
        />
      </div>
      <div className="mt-6 flex justify-between items-center">
        <div className="flex items-center gap-[6px]">
          <Image src="/icon/calender.svg" alt="#" width={24} height={24} />
          <p className="text-sm text-[#475156]">
            {dayjs(data?.updated_at).format("DDMMM, YYYY")}
          </p>
        </div>
        <div className="flex items-center gap-[6px]">
          <Image src="/icon/user-circle.svg" alt="#" width={24} height={24} />
          <p className="text-sm text-[#475156]">Admin</p>
        </div>
      </div>
      <p className="mt-[10px] text-lg font-medium line-clamp-2">
        {data?.blog_title}
      </p>
      <div
        className="mt-3 mb-6 text-tGray font-medium line-clamp-3"
        dangerouslySetInnerHTML={{ __html: data?.blog_content }}
      ></div>

      <ShopNow
        size={20}
        link={`/blogs/${data?.slug}`}
        text="READ MORE"
        ariaLabel={data?.blog_title}
        cls={
          "w-[160px] inline-block text-skyBlue text-sm font-bold py-3 border-2 border-[#CFECFF] rounded-sm mt-auto"
        }
      />
    </div>
  );
};

export default BlogCard;
