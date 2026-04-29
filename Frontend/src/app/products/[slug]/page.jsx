import { getSingleProduct } from "@/actions/product";
import NewArrival from "@/components/home/NewArrival";
import TopRated from "@/components/home/TopRated";
import AddToCart from "@/components/product/AddToCart";
import ColorBox from "@/components/product/ColorBox";
import ProductDetailSlider from "@/components/product/ProductDetailSlider";
import ProductDetailTab from "@/components/product/ProductDetailTab";
import SizeBox from "@/components/product/SizeBox";
import VariantBox from "@/components/product/VariantBox";
import Container from "@/components/shared/Container";
import StarRating from "@/components/shared/StarRating";
import { Link } from "next-view-transitions";

export const generateMetadata = async ({ params: { slug } }) => {
  const { data } = await getSingleProduct(slug);
  return {
    title: data.product_title,
    description: data.product_description,
    openGraph: {
      images: [
        {
          url: `${process.env.NEXT_PUBLIC_IMG_URL}/${data?.get_gallery_images?.[0]?.img}`,
        },
      ],
    },
  };
};

const ProductDetailsPage = async ({ params: { slug } }) => {
  const { data } = await getSingleProduct(slug);
  const stock = data?.stocks?.length
    ? data?.stocks?.reduce((sum, item) => sum + item.stock, 0)
    : data.stock;

  return (
    <main className="mt-10">
      <Container>
        <section className="grid grid-cols-1 lg:grid-cols-2 gap-10 lg:gap-0">
          <div className="lg:pr-14">
            <ProductDetailSlider
              images={[
                ...(data?.get_gallery_images || []),
                ...(data?.colors?.flatMap(
                  (color) =>
                    color?.images?.map((img) => ({ img: img.color_image })) ||
                    []
                ) || []),
              ]}
            />
          </div>
          <div className="">
            <h1 className="text-xl">{data?.product_title}</h1>
            <p className="text-tGray text-sm mt-2">
              By:{" "}
              <Link
                prefetch={false}
                href={
                  data?.get_product_user?.user_type === "vendor"
                    ? `/shop/${data?.shop?.slug}`
                    : `/users/${data?.get_product_user?.id}`
                }
                className="font-semibold text-skyBlue"
              >
                {data?.get_product_user?.user_type === "vendor"
                  ? data?.shop?.name
                  : data?.get_product_user?.name}
              </Link>
            </p>
            <div className="mt-2 flex items-center gap-[6px]">
              <StarRating value={data?.ratings_avg_rating} />
              <span className="text-sm font-semibold">
                {parseInt(data?.ratings_avg_rating ?? 0)} Star Rating
              </span>
              <span className="text-sm text-tGray">
                ({data?.ratings_count} User feedback)
              </span>
            </div>
            <div className="mt-4 grid grid-cols-2 gap-2 text-sm">
              <p className="text-tGray truncate">
                Sku: {data?.stocks?.length ? data?.stocks?.[0]?.sku : data?.sku}
              </p>
              <p className="text-tGray">
                Status:{" "}
                <span
                  className={
                    stock > 0
                      ? "text-green font-semibold"
                      : "text-red-500 font-semibold"
                  }
                >
                  {stock > 0 ? "In Stock" : "Out of Stock"}
                </span>
              </p>
              <p className="text-tGray">
                Brand:{" "}
                <Link
                  href={`/products?category_id=${data?.category_id}&brand_id=${data?.brand_id}`}
                  className="font-semibold text-tBlack"
                >
                  {data?.get_brand?.brand_name ?? "N/A"}
                </Link>
              </p>
              <p className="text-tGray">
                Category:{" "}
                <Link
                  href={`/products?category_id=${data?.get_category?.id}`}
                  className="text-tBlack font-semibold"
                >
                  {data?.get_category?.category_name}
                </Link>
              </p>
            </div>
            <p className="mt-6 text-skyBlue text-2xl font-semibold leading-none flex items-center gap-3">
              $
              {data?.discounted_price && data.discounted_price < data.price
                ? data.discounted_price
                : data?.price}
              {data?.discounted_price && data.discounted_price < data.price && (
                <>
                  <span className="line-through text-tGray font-normal">
                    ${data.price}
                  </span>
                  <span className="text-tBlack text-sm font-semibold bg-yellow px-[10px] py-[3px] rounded-sm">
                    {Math.round(
                      ((data.price - data.discounted_price) / data.price) * 100
                    )}
                    % OFF
                  </span>
                </>
              )}
            </p>
            <hr className="my-6" />
            <div className="space-y-6">
              {data?.colors?.length > 0 && <ColorBox colors={data?.colors} />}
              {data?.sizes?.length > 0 && <SizeBox sizes={data?.sizes} />}
              {data?.variants?.length > 0 && (
                <VariantBox variants={data?.variants} />
              )}
            </div>
            <AddToCart data={data} />
          </div>
        </section>
        <ProductDetailTab data={data} />
        <TopRated />
        <NewArrival />
      </Container>
    </main>
  );
};

export default ProductDetailsPage;
