import { getToken } from "@/actions/auth";
import { getBrands, getCategories, getShopBySlug } from "@/actions/others";
import { getWishList } from "@/actions/product";
import Products from "@/components/product/Products";
import Container from "@/components/shared/Container";
import Pagination from "@/components/shared/Pagination";
import ShopInfo from "@/components/shop/ShopInfo";
import getSearchParams from "@/utils/getSearchParams";

export const generateMetadata = async ({ params: { slug } }) => {
  const { data } = await getShopBySlug(slug);
  return {
    title: data?.shop?.name || "Shop Details",
    description: data?.shop?.description || "Shop details page",
  };
};

const ShopDetailsPage = async ({ params: { slug }, searchParams }) => {
  const params = getSearchParams(searchParams);
  const [
    token,
    { data: wishlist },
    { data: categories },
    { data: brands },
    { data },
  ] = await Promise.all([
    getToken(),
    getWishList(),
    getCategories(),
    getBrands(),
    getShopBySlug(slug, params),
  ]);

  if (!data) {
    return <div className="text-center">Shop not found</div>;
  }

  return (
    <main>
      <Container>
        <ShopInfo data={data?.shop} pagination={data?.pagination} />
        <Products
          brands={brands}
          categories={categories}
          data={data?.products}
          token={token}
          wishlist={wishlist}
        />
        <div className="grid grid-cols-1 lg:grid-cols-[300px_1fr] gap-6 mt-11">
          <div></div>
          <Pagination
            total_pages={Math.ceil(
              data?.pagination?.total / data?.pagination?.per_page
            )}
          />
        </div>
      </Container>
    </main>
  );
};

export default ShopDetailsPage;
