import { shimmer } from "@/constants";
import toBase64 from "@/utils/toBase64";
import dayjs from "dayjs";
import Image from "next/image";

const Comment = ({ data }) => {
  const img = data?.get_user?.profile_img
    ? `${process.env.NEXT_PUBLIC_IMG_URL}/${data?.get_user?.profile_img}`
    : "/icon/user-circle.svg";

  return (
    <div className="flex gap-3 py-6">
      <Image
        src={img}
        alt={data?.get_user?.name}
        width={40}
        height={40}
        placeholder={`data:image/svg+xml;base64,${toBase64(shimmer())}`}
        className="h-max rounded-full"
      />
      <div>
        <p className="text-sm">
          <span>{data?.get_user?.name}</span>
          <span className="mx-[6px] text-tGray">•</span>
          <span className="text-tGray">
            {dayjs(data?.created_at).format("D MMM, YYYY")}
          </span>
        </p>
        <p className="text-sm mt-[6px]">{data?.comment}</p>
      </div>
    </div>
  );
};

export default Comment;
