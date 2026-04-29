import { getBrands, getCategories } from "@/actions/others";
import { filter } from "@/actions/product";
import Products from "@/components/product/Products";
import Container from "@/components/shared/Container";
import Pagination from "@/components/shared/Pagination";
import getSearchParams from "@/utils/getSearchParams";

export const generateMetadata = async ({ searchParams }) => {
  let title = "Products";
  if (searchParams["is_featured"]) title = "Featured Products";
  if (searchParams["sort_by"] == "discount") title = "Best Deals Products";
  if (
    searchParams["sort_by"] == "rating" &&
    searchParams["sort_direction"] == "desc"
  )
    title = "Top Rated Products";
  return {
    title,
    description: "Explore our wide range of products",
  };
};

const ProductsPage = async ({ searchParams }) => {
  const params = getSearchParams({ ...searchParams, limit: 12 });
  const [{ data: categories }, { data: brands }, { data, pagination }] =
    await Promise.all([getCategories(), getBrands(), filter(params)]);

  return (
    <main className="mt-10">
      <Container>
        <Products categories={categories} brands={brands} data={data} />
        <div className="grid grid-cols-1 lg:grid-cols-[300px_1fr] gap-6 mt-11">
          <div></div>
          <Pagination
            total_pages={Math.ceil(pagination?.total / pagination?.per_page)}
          />
        </div>
      </Container>
    </main>
  );
};

export default ProductsPage;
