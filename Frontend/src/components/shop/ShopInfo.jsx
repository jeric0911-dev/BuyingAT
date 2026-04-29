import Image from "next/image";
import StarRating from "../shared/StarRating";
import dayjs from "dayjs";
import { CameraIcon } from "@heroicons/react/16/solid";
import { Link } from "next-view-transitions";
import { FaUserCircle } from "react-icons/fa";
import toBase64 from "@/utils/toBase64";
import { shimmer } from "@/constants";

const ShopInfo = ({ data, pagination, user }) => {
  return (
    <section className="mt-6">
      <div className="h-[240px] lg:h-[400px] w-full relative">
        <Image
          src={`${process.env.NEXT_PUBLIC_IMG_URL}/${data?.banner}`}
          alt={`${data?.name} banner`}
          fill
          priority
          placeholder={`data:image/svg+xml;base64,${toBase64(shimmer())}`}
          className="object-cover"
        />
        {user?.user_type?.toLowerCase() === "vendor" && (
          <Link
            href="/shop/update-shop"
            aria-label="Update shop image"
            className="size-8 rounded-full bg-skyBlue flex justify-center items-center absolute bottom-2.5 right-2.5"
          >
            <CameraIcon color="white" className="size-5" />
          </Link>
        )}
      </div>
      <div className="mt-6 flex items-start">
        {data?.get_user?.profile_img ? (
          <Image
            src={`${process.env.NEXT_PUBLIC_IMG_URL}/${data?.get_user?.profile_img}`}
            alt={data?.get_user?.name}
            width={152}
            height={152}
            placeholder={`data:image/svg+xml;base64,${toBase64(shimmer())}`}
            className="rounded h-[150px] w-[150px] object-cover"
          />
        ) : (
          <FaUserCircle className="size-[152px] text-white bg-skyBlue rounded" />
        )}
        <div className="ml-4 md:ml-7 w-full lg:w-1/2">
          <p className="text-xl font-semibold">{data?.name}</p>
          <p className="text-sm text-tGray mt-2 text-justify">
            {data?.description}
          </p>
          <div className="flex items-center flex-wrap gap-3 justify-between mt-[18px] w-full">
            <p className="text-sm text-tGray flex items-center gap-2">
              <Image src="/icon/envelop.svg" alt="#" width={20} height={20} />
              {data?.get_user?.email}
            </p>
            {data?.get_user?.phone && (
              <p className="text-sm text-tGray flex items-center gap-2">
                <Image src="/icon/phone.svg" alt="#" width={20} height={20} />
                {data?.get_user?.phone}
              </p>
            )}

            <p className="text-sm text-tGray flex items-center gap-2 flex-grow">
              <Image src="/icon/location.svg" alt="#" width={20} height={20} />
              {data?.get_user?.state?.state_name &&
                data?.get_user?.country?.country_name &&
                data.get_user.state.state_name +
                  ", " +
                  data.get_user.country.country_name}
            </p>
          </div>
          <div className="mt-[18px] flex flex-col sm:flex-row items-start sm:items-center gap-5 lg:gap-14">
            <p className="text-sm text-tGray">
              Member since {dayjs(data?.created_at).year()}
            </p>
            <div className="flex items-center gap-1">
              <StarRating value={data?.average_rating} />
              <p className="text-sm text-tGray">({data?.rating_count})</p>
            </div>
          </div>
        </div>
      </div>
      <p className="mt-14 px-6 py-4 border border-border rounded font-medium">
        {`Products ( ${pagination?.total} )`}
      </p>
    </section>
  );
};

export default ShopInfo;
