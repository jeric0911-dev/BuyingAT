import Image from "next/image";
import StarRating from "../shared/StarRating";
import dayjs from "dayjs";

const Review = ({ data }) => {
  return (
    <div className="p-10">
      <div className="flex items-center gap-4">
        <StarRating value={5} />
        <p className="text-sm font-semibold text-tBlack">
          Reviews {data?.ratings?.length}
        </p>
      </div>
      <div className="mt-6">
        {data?.ratings?.map((item, i) => (
          <div
            key={i}
            className="border-t border-border last:border-b py-6 flex gap-4"
          >
            <Image
              src={
                item?.user?.profile_img
                  ? `${process.env.NEXT_PUBLIC_IMG_URL}/${item?.user?.profile_img}`
                  : "/icon/user-circle.svg"
              }
              alt="user image"
              width={0}
              height={0}
              sizes="100vw"
              className="size-16 rounded-full object-cover"
            />
            <div className="space-y-1">
              <StarRating value={item?.rating} />
              <p className="text-sm text-tBlack font-semibold">
                {item?.user?.name}
              </p>
              <p className="text-sm text-tGray">{item?.message}</p>
              <p className="text-sm text-skyBlue">
                {dayjs(item?.created_at).fromNow()}
              </p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default Review;
