import { getBlogBySlug } from "@/actions/others";
import CategorySearch from "@/components/blog/CategorySearch";
import Comment from "@/components/blog/Comment";
import MakeComment from "@/components/blog/MakeComment";
import Search from "@/components/blog/Search";
import Share from "@/components/blog/Share";
import Container from "@/components/shared/Container";
import MoreBlogCard from "@/components/shared/MoreBlogCard";
import dayjs from "dayjs";
import Image from "next/image";

export const generateMetadata = async ({ params: { slug } }) => {
  const { data } = await getBlogBySlug(slug);
  const title = data?.blog_title;
  const description = data?.blog_content
    ?.replace(/<[^>]*>/g, "")
    ?.substring(0, 160);

  return {
    title,
    description,
    openGraph: {
      images: [
        {
          url: `${process.env.NEXT_PUBLIC_IMG_URL}/${data?.blog_thumb_img}`,
        },
      ],
    },
  };
};

const BlogDetailsPage = async ({ params: { slug } }) => {
  const { data } = await getBlogBySlug(slug);

  return (
    <>
      <section className="mt-6 lg:mt-12">
        <Container>
          <div className="w-full h-[300px] md:h-[450px] lg:h-[600px] relative">
            <Image
              src={`${process.env.NEXT_PUBLIC_IMG_URL}/${data?.blog?.cover_img}`}
              alt="#"
              fill
              priority
              className="object-cover"
            />
          </div>
          <div className="mt-12 grid grid-cols-1 md:grid-cols-[1fr_350px] gap-12">
            {/* ----------------------blog-description--------------- */}
            <div>
              <div className="flex justify-between items-center gap-5">
                <div className="flex items-center gap-[6px]">
                  <Image src="/icon/stack.svg" alt="#" width={24} height={24} />
                  <p className="text-sm text-[#475156]">
                    {data?.blog?.category?.name}
                  </p>
                </div>
                <div className="flex items-center gap-[6px]">
                  <Image
                    src="/icon/calender.svg"
                    alt="#"
                    width={24}
                    height={24}
                  />
                  <p className="text-sm text-[#475156]">
                    {dayjs(data?.blog?.updated_at).format("D MMM, YYYY")}
                  </p>
                </div>
              </div>
              <h1 className="text-[28px] lg:text-[32px] font-semibold mt-4">
                {data?.blog?.blog_title}
              </h1>
              <div className="flex justify-between items-center gap-5 mt-6">
                <div className="flex items-center gap-[6px]">
                  <Image
                    src="/icon/user-circle.svg"
                    alt="#"
                    width={40}
                    height={40}
                  />
                  <p className="font-medium">Admin</p>
                </div>
                <Share />
              </div>
              <div
                className="mt-8 prose max-w-none"
                dangerouslySetInnerHTML={{ __html: data?.blog?.blog_content }}
              />
              <MakeComment id={data?.blog?.id} />
              <div className="mt-12">
                <p className="text-xl font-medium">Comments</p>
                <div className="divide-y">
                  {data?.blog?.blog_comments?.map((item) => (
                    <Comment key={item.id} data={item} />
                  ))}
                </div>
              </div>
            </div>
            {/* ----------------------side-filter--------------- */}
            <div>
              {/* --------------------search-------------------- */}
              <Search />
              {/* --------------------category------------------- */}
              <CategorySearch />
              {/* --------------------more-blog------------------- */}
              <div className="border border-border p-6 rounded-md mt-6">
                <p className="font-medium">MORE BLOGS</p>
                <div className="mt-6 space-y-6">
                  {data?.more_blogs?.map((item) => (
                    <MoreBlogCard key={item.id} data={item} />
                  ))}
                </div>
              </div>
            </div>
          </div>
        </Container>
      </section>
    </>
  );
};

export default BlogDetailsPage;
