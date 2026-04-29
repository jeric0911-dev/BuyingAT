import { getBlogs } from "@/actions/others";
import CategorySearch from "@/components/blog/CategorySearch";
import Search from "@/components/blog/Search";
import BlogCard from "@/components/home/BlogCard";
import Container from "@/components/shared/Container";
import MoreBlogCard from "@/components/shared/MoreBlogCard";
import Pagination from "@/components/shared/Pagination";
import getSearchParams from "@/utils/getSearchParams";
import Image from "next/image";

export const metadata = {
  title: "Blog",
  description: "Read our latest blogs",
};

const BlogPage = async ({ searchParams }) => {
  const params = getSearchParams(searchParams);
  const { data } = await getBlogs(params);

  return (
    <>
      <section className="mt-12">
        <Container>
          <div className="grid grid-cols-1 lg:grid-cols-[350px_1fr] gap-6">
            {/* ----------------------side-filter--------------- */}
            <div>
              {/* --------------------search-------------------- */}
              <Search />
              {/* --------------------category------------------- */}
              <CategorySearch searchParams={searchParams} />
              {/* --------------------more-blog------------------- */}
              <div className="border border-border p-6 rounded-md mt-6">
                <p className="font-medium">MORE BLOGS</p>
                <div className="mt-6 space-y-6">
                  {data?.moreBlogs?.map((item) => (
                    <MoreBlogCard key={data?.id} data={item} />
                  ))}
                </div>
              </div>
            </div>
            <div className="">
              {/* --------------------blog-result-------------- */}
              {data?.items?.length > 0 ? (
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-6">
                  {data?.items?.map((item, i) => (
                    <BlogCard key={i} data={item} padding="6" />
                  ))}
                </div>
              ) : (
                <Image
                  src="/images/empty-blog.png"
                  alt="no item found"
                  width={0}
                  height={0}
                  sizes="100vw"
                  className="w-full md:w-1/2 lg:w-2/5 h-auto mx-auto mt-10 lg:mt-20"
                />
              )}
              <Pagination
                total_pages={Math.ceil(
                  data?.pagination?.total / data?.pagination?.per_page
                )}
                className="mt-10"
              />
            </div>
          </div>
        </Container>
      </section>
    </>
  );
};

export default BlogPage;
