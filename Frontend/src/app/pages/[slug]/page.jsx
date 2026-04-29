import { getSinglePage } from "@/actions/others";
import Container from "@/components/shared/Container";
import Image from "next/image";

export const generateMetadata = async ({ params: { slug } }) => {
  const { data } = await getSinglePage(slug);
  return {
    title: data?.title,
  };
};

const PagesPage = async ({ params: { slug } }) => {
  const { data } = await getSinglePage(slug);

  return (
    <section className="mt-[60px]">
      <Container>
        <div className="mt-8 overflow-hidden h-32 relative rounded">
          <Image
            src="/logo/pages.svg"
            alt="#"
            fill
            className="object-cover object-left"
          />
          <div className="absolute inset-0 flex justify-center items-center">
            <p className="text-[32px] font-bold font text-white text-center">
              {data?.title}
            </p>
          </div>
        </div>
        <div
          className="mt-8 prose max-w-none *:text-[#4c4c4c] prose-headings:text-black prose-p:text-[#4c4c4c] prose-a:text-[#4c4c4c] prose-strong:text-[#4c4c4c] prose-li:text-[#4c4c4c] *:m-0"
          dangerouslySetInnerHTML={{ __html: data?.content }}
        ></div>
      </Container>
    </section>
  );
};

export default PagesPage;
