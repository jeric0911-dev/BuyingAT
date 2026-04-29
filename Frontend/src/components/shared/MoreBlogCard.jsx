import dayjs from "dayjs";
import Image from "next/image";
import { Link } from "next-view-transitions";
import toBase64 from "@/utils/toBase64";
import { shimmer } from "@/constants";

const MoreBlogCard = ({ data }) => {
  return (
    <Link href={`/blogs/${data?.slug}`}>
      <div className="flex items-center gap-4">
        <Image
          src={`${process.env.NEXT_PUBLIC_IMG_URL}/${data?.blog_thumb_img}`}
          alt="#"
          width={0}
          height={0}
          sizes="100vw"
          placeholder={`data:image/svg+xml;base64,${toBase64(shimmer())}`}
          className="w-[104px] h-20 object-cover rounded-sm"
        />
        <div>
          <p className="text-sm font-medium line-clamp-2">{data?.blog_title}</p>
          <p className="text-sm text-tGray mt-2">
            {dayjs(data?.updated_at).format("D MMM, YYYY")}
          </p>
        </div>
      </div>
    </Link>
  );
};

export default MoreBlogCard;
