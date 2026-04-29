import dayjs from "dayjs";
import relativeTime from "dayjs/plugin/relativeTime";
import Image from "next/image";
import FeatureButton from "./FeatureButton";
import EditButton from "./EditButton";
import UnpublishButton from "./UnpublishButton";
import DeleteButton from "./DeleteButton";
import StockButton from "./StockButton";
import { Link } from "next-view-transitions";
import toBase64 from "@/utils/toBase64";
import { shimmer } from "@/constants";
dayjs.extend(relativeTime);

const MyListingCard = ({ data }) => {
  return (
    <div className="grid grid-cols-1 sm:grid-cols-[230px_1fr] gap-3.5 sm:gap-6 pt-6 pb-8">
      <Link
        prefetch={false}
        href={`/products/${data?.id}`}
        className="relative h-[200px] lg:size-full"
      >
        <Image
          src={`${process.env.NEXT_PUBLIC_IMG_URL}/${data?.get_gallery_images?.[0]?.img}`}
          alt={data?.product_title}
          fill
          placeholder={`data:image/svg+xml;base64,${toBase64(shimmer())}`}
          className="rounded-t-md sm:rounded-md object-cover"
        />
      </Link>
      <div className="mt-0.5">
        <Link prefetch={false} href={`/products/${data?.id}`}>
          <p className="text-lg text-tBlack font-semibold">
            {data?.product_title}
          </p>
        </Link>
        <div className="flex items-center justify-between mt-3.5">
          <Link href={`/products/${data?.id}`} prefetch={false}>
            <div>
              <p className="flex items-center gap-2.5">
                <Image
                  src="/icon/time-circle.svg"
                  alt="clock"
                  width={16}
                  height={16}
                />
                <span className="text-[#475156]">
                  {dayjs(data?.updated_at).fromNow()}
                </span>
              </p>
              <p className="text-skyBlue text-xl font-bold mt-[10px] sm:mt-[18px]">
                $ {data?.price}
              </p>
            </div>
          </Link>
          {(data?.status.toLowerCase() === "active" ||
            data?.status?.toLowerCase() === "pending") && (
            <StockButton data={data} />
          )}
        </div>
        <hr className="border-border my-4" />
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 sm:gap-[22px] *:h-9 text-sm font-semibold">
          {data?.status?.toLowerCase() === "active" && (
            <FeatureButton data={data} />
          )}
          <EditButton data={data} />
          {data?.status?.toLowerCase() !== "unpublished" && (
            <UnpublishButton data={data} />
          )}
          <DeleteButton data={data} />
        </div>
      </div>
    </div>
  );
};

export default MyListingCard;
