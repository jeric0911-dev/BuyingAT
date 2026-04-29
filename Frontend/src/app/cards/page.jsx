import { browseActiveCards } from "@/actions/product";
import Cards from "@/components/card/Cards";
import Container from "@/components/shared/Container";
import Pagination from "@/components/shared/Pagination";
import getSearchParams from "@/utils/getSearchParams";

export const generateMetadata = async ({ searchParams }) => {
  let title = "Browse Cards";
  if (searchParams["search"]) title = `Search Results for "${searchParams["search"]}"`;
  if (searchParams["sport_type"]) title = `${searchParams["sport_type"]} Cards`;
  if (searchParams["grade"]) title = `${searchParams["grade"]} Graded Cards`;
  if (searchParams["sort_by"] == "price") title = "Cards by Price";
  return {
    title,
    description: "Browse and discover approved trading cards from sellers",
  };
};

const CardsPage = async ({ searchParams }) => {
  const params = getSearchParams({ ...searchParams, limit: 12 });
  const { data, pagination } = await browseActiveCards(params);

  return (
    <main className="mt-10">
      <Container>
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-gray-900 mb-2">Browse Cards</h1>
          <p className="text-gray-600">Discover approved trading cards from verified sellers</p>
        </div>
        <Cards data={data} />
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

export default CardsPage;
