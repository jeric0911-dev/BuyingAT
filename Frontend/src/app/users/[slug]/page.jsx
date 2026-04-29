import { getToken } from "@/actions/auth";
import { getBrands, getCategories, getUserBySlug } from "@/actions/others";
import { getWishList } from "@/actions/product";
import Products from "@/components/product/Products";
import Container from "@/components/shared/Container";
import Pagination from "@/components/shared/Pagination";
import StarRating from "@/components/shared/StarRating";
import getSearchParams from "@/utils/getSearchParams";
import dayjs from "dayjs";
import Image from "next/image";
import { notFound } from "next/navigation";
import { FaUserCircle } from "react-icons/fa";

const UsersProductPage = async ({ params: { slug }, searchParams }) => {
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
    getUserBySlug(slug, params),
  ]);

  if(!data) return notFound()

  return (
    <main>
      <Container>
        <section className="mt-6">
          <div className="flex items-start">
            {data?.user?.profile_img ? (
              <Image
                src={`${process.env.NEXT_PUBLIC_IMG_URL}/${data?.user?.profile_img}`}
                alt={data?.user?.name}
                width={152}
                height={152}
                className="rounded h-[150px] w-[150px] object-cover"
              />
            ) : (
              <FaUserCircle className="size-[152px] text-white bg-skyBlue rounded" />
            )}
            <div className="ml-4 md:ml-7 w-full lg:w-1/2">
              <p className="text-xl font-semibold">{data?.user?.name}</p>
              <div className="flex items-center flex-wrap gap-3 justify-between mt-[18px] w-full">
                <p className="text-sm text-tGray flex items-center gap-2">
                  <Image
                    src="/icon/envelop.svg"
                    alt="#"
                    width={20}
                    height={20}
                  />
                  {data?.user?.email}
                </p>
                {data?.user?.phone && (
                  <p className="text-sm text-tGray flex items-center gap-2">
                    <Image
                      src="/icon/phone.svg"
                      alt="#"
                      width={20}
                      height={20}
                    />
                    {data?.user?.phone}
                  </p>
                )}

                <p className="text-sm text-tGray flex items-center gap-2 flex-grow">
                  <Image
                    src="/icon/location.svg"
                    alt="#"
                    width={20}
                    height={20}
                  />
                  {data?.user?.state?.state_name &&
                    data?.user?.country?.country_name &&
                    data.user.state.state_name +
                      ", " +
                      data.user.country.country_name}
                </p>
              </div>
              <div className="mt-[18px] flex flex-col sm:flex-row items-start sm:items-center gap-5 lg:gap-14">
                <p className="text-sm text-tGray">
                  Member since {dayjs(data?.created_at).year()}
                </p>
                <div className="flex items-center gap-1">
                  <StarRating value={data?.user?.average_rating} />
                  <p className="text-sm text-tGray">
                    ({data?.user?.rating_count})
                  </p>
                </div>
              </div>
            </div>
          </div>
          <p className="mt-14 px-6 py-4 border border-border rounded font-medium">
            {`Products ( ${data?.pagination?.total} )`}
          </p>
        </section>
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

export default UsersProductPage;
