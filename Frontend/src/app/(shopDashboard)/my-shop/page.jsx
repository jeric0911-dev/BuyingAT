import { getMyShopProducts } from "@/actions/vendor";
import Pagination from "@/components/shared/Pagination";
import MyListingCard from "@/components/shop/MyListingCard";
import StatusTab from "@/components/shop/StatusTab";
import getSearchParams from "@/utils/getSearchParams";
import Image from "next/image";

export const metadata = {
  title: "My Shop",
  robots: { index: false },
};

const MyShopPage = async ({ searchParams }) => {
  const params = getSearchParams(searchParams);
  const { data, pagination } = await getMyShopProducts(params);

  return (
    <>
      <StatusTab />
      {data?.length > 0 ? (
        <div className="mt-4 mb-8 divide-y divide-dashed divide-[#8C8C8C]">
          {data?.map((item) => (
            <MyListingCard key={item.id} data={item} />
          ))}
        </div>
      ) : (
        <Image
          src="/images/empty-store.png"
          alt="empty shop"
          width={0}
          height={0}
          sizes="100vw"
          className="w-full md:w-1/2 lg:w-1/4 mx-auto h-auto mt-10 lg:mt-20"
        />
      )}
      <Pagination
        total_pages={Math.ceil(pagination?.total / pagination?.per_page)}
      />
    </>
  );
};

export default MyShopPage;
