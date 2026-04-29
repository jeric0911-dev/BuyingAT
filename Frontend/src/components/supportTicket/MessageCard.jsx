import dayjs from "dayjs";
import Image from "next/image";
import { Link } from "next-view-transitions";
import { IoDocumentTextOutline } from "react-icons/io5";

const MessageCard = ({ data }) => {
  return (
    <div
      className={`${
        data?.user_id
          ? "border-skyBlue bg-skyBlue/10"
          : "border-[#E46A11] bg-[#E46A11]/10"
      } border p-4 rounded grid grid-cols-1 lg:grid-cols-[200px_1fr]`}
    >
      <div
        className={`lg:border-r pr-4 text-xl font-medium flex items-center gap-5 ${
          data?.user_id ? "border-skyBlue" : "border-[#E46A11]"
        }`}
      >
        <Image
          src={
            data?.user_id
              ? data?.user?.profile_img
                ? `${process.env.NEXT_PUBLIC_IMG_URL}/${data?.user?.profile_img}`
                : "/icon/user-mobile.svg"
              : "/icon/user-mobile.svg"
          }
          alt=""
          width={34}
          height={34}
          className={`rounded-full border-2 ${
            data?.user_id ? "border-skyBlue" : "border-[#E46A11]"
          }`}
        />
        <p className={`${data?.user_id ? "text-skyBlue" : "text-[#E46A11]"}`}>
          {data?.user_id ? data?.user?.name : "Admin"}
        </p>
      </div>
      <div className="pl-4">
        <p className="font-semibold text-gray3B my-2">
          Posted on{" "}
          {dayjs(data?.created_at).format("dddd, D MMMM YYYY [@] hh:mm A")}
        </p>
        <p className="text-gray55">{data?.message}</p>
        {data?.attachments?.length > 0 &&
          data?.attachments?.map((item, index) => (
            <Link
              key={item.id}
              href={`${process.env.NEXT_PUBLIC_IMG_URL}${item.file}`}
              className="text-skyBlue mt-2 flex items-center gap-2"
            >
              <IoDocumentTextOutline
                size={16}
                className={data?.user_id ? "text-skyBlue" : "text-[#E46A11]"}
              />
              Attachment {index + 1}
            </Link>
          ))}
      </div>
    </div>
  );
};

export default MessageCard;
