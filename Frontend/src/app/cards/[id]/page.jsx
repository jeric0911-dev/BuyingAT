import { getActiveCard } from "@/actions/product";
// import NewArrival from "@/components/home/NewArrival";
// import TopRated from "@/components/home/TopRated";
import CardAddToCart from "@/components/card/CardAddToCart";
import ProductDetailSlider from "@/components/product/ProductDetailSlider";
import CardDetailTab from "@/components/card/CardDetailTab";
import Container from "@/components/shared/Container";
import StarRating from "@/components/shared/StarRating";
import { Link } from "next-view-transitions";

export const generateMetadata = async ({ params: { id } }) => {
  const { data } = await getActiveCard(id);
  return {
    title: data.card_title,
    description: data.description,
    openGraph: {
      images: [
        {
          url: `${process.env.NEXT_PUBLIC_IMG_URL}/${data?.images?.[0]}`,
        },
      ],
    },
  };
};

const CardDetailsPage = async ({ params: { id } }) => {
  const { data } = await getActiveCard(id);

  // Convert card images to the format expected by ProductDetailSlider
  const cardImages = data?.images?.map((image, index) => ({
    id: index + 1,
    img: image
  })) || [];

  return (
    <main className="mt-10">
      <Container>
        <section className="grid grid-cols-1 lg:grid-cols-2 gap-10 lg:gap-0">
          <div className="lg:pr-14">
            <ProductDetailSlider images={cardImages} />
          </div>
          <div className="">
            <h1 className="text-xl">{data?.card_title}</h1>
            <p className="text-tGray text-sm mt-2">
              By:{" "}
              <Link
                prefetch={false}
                href={`/users/${data?.seller?.id}`}
                className="font-semibold text-skyBlue"
              >
                {data?.seller?.name}
              </Link>
            </p>
            <div className="mt-2 flex items-center gap-[6px]">
              <StarRating value={0} />
              <span className="text-sm font-semibold">
                0 Star Rating
              </span>
              <span className="text-sm text-tGray">
                (0 User feedback)
              </span>
            </div>
            <div className="mt-4 grid grid-cols-2 gap-2 text-sm">
              <p className="text-tGray truncate">
                Sku: {data?.card_id}
              </p>
              <p className="text-tGray">
                Status:{" "}
                <span className="text-green font-semibold">
                  In Stock
                </span>
              </p>
              <p className="text-tGray">
                Card Type:{" "}
                <span className="font-semibold text-tBlack">
                  {data?.sport_type ?? "N/A"}
                </span>
              </p>
              <p className="text-tGray">
                Condition:{" "}
                <span className="text-tBlack font-semibold">
                  {data?.condition ?? "N/A"}
                </span>
              </p>
            </div>
            <p className="mt-6 text-skyBlue text-2xl font-semibold leading-none flex items-center gap-3">
              ${data?.price} {data?.price_type && (
                <span className="text-sm font-normal text-gray-600">
                  ({data.price_type})
                </span>
              )}
            </p>
            <hr className="my-6" />

            <CardAddToCart data={data} />
          </div>
        </section>
        <CardDetailTab data={data} />
        {/* <TopRated />
        <NewArrival /> */}
      </Container>
    </main>
  );
};

export default CardDetailsPage;
