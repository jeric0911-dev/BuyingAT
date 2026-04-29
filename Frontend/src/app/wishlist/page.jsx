import { getWishList } from "@/actions/product";
import Container from "@/components/shared/Container";
import WishlistCard from "@/components/wishlist/WishlistCard";
import Image from "next/image";
import nextDynamic from "next/dynamic";

const CardWishlistList = nextDynamic(() => import("@/components/wishlist/CardWishlistList"), { ssr: false });

export const metadata = {
  title: "Wishlist",
  description: "View and manage your wishlist items",
  robots: { index: false },
};
export const dynamic = "force-dynamic";
const WishlistPage = async () => {
  const { data } = await getWishList();

  return (
    <main>
      <Container>
        <div className="min-h-[calc(100vh-204px)]">
          <div className="w-full mt-12 border border-border rounded-[4px]">
            <p className="px-6 py-5 text-lg font-medium">Wishlist</p>

            {/* Scroll wrapper around header and items */}
            <div className="overflow-x-auto scrollbar-hide">
              <div className="min-w-[650px]">
                {/* Header row */}
                <div className="border-y border-border bg-lightGray px-6 py-[10px] grid grid-cols-[1fr_80px_180px] md:grid-cols-[1fr_100px_200px] lg:grid-cols-[1fr_200px_220px] gap-5 text-xs text-[#475156] text-nowrap">
                  <p>CARDS</p>
                  <p>PRICE</p>
                  {/* <p>STOCK STATUS</p> */}
                  <p>ACTION</p>
                </div>
                {/* Items (Products) */}
                {data?.length > 0 ? (
                  <div className="p-6 space-y-4">
                    {data?.map((item) => (
                      <WishlistCard key={item} data={item} />
                    ))}
                  </div>
                ) : (
                  <div className="p-6">
                    {/* Fallback to card wishlist from local storage */}
                    <CardWishlistList />
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </Container>
    </main>
  );
};

export default WishlistPage;
