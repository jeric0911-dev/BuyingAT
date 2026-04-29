import { getUser } from "@/actions/auth";
import { getMySellerInventory } from "@/actions/sellerInventory";
import Pagination from "@/components/shared/Pagination";
import MyInventoryCard from "@/components/shop/MyInventoryCard";
import StatusTab from "@/components/shop/StatusTab";
import getSearchParams from "@/utils/getSearchParams";
import Image from "next/image";
import { redirect } from "next/navigation";
import CardStatusFilter from "@/components/shop/CardStatusFilter";

export const metadata = {
  title: "My Cards",
  description: "View and manage your card listings",
  robots: { index: false },
};

const MyCardsPage = async ({ searchParams }) => {
  const { data: user } = await getUser();
  if (user?.user_type === "vendor") redirect("/");

  const params = getSearchParams(searchParams);
  const { data } = await getMySellerInventory(params);

  return (
    <div>
      <CardStatusFilter />
      {data?.length > 0 ? (
        <div className="mt-4 mb-8 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {data?.map((item) => (
            <MyInventoryCard key={item.id} data={item} />
          ))}
        </div>
      ) : (
        <Image
          src="/images/empty-store.png"
          alt="empty store"
          width={0}
          height={0}
          sizes="100vw"
          className="w-full md:w-1/2 lg:w-1/4 mx-auto h-auto mt-10 lg:mt-20"
        />
      )}
      {/* Pagination can be added later if needed */}
    </div>
  );
};

export default MyCardsPage;
