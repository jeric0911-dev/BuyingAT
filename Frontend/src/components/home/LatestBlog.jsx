import { getBlogs } from "@/actions/others";
import BlogCard from "./BlogCard";
import getSearchParams from "@/utils/getSearchParams";

const LatestBlog = async () => {
  const { data } = await getBlogs(getSearchParams({ limit: 3 }));

  return (
    <section className="mt-24">
      <p className="text-[32px] font-semibold text-center">Latest Blog</p>
      <div className="mt-10 grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-6">
        {data?.items?.map((blog, a) => (
          <BlogCard key={a} data={blog} padding="6" />
        ))}
      </div>
    </section>
  );
};

export default LatestBlog;
