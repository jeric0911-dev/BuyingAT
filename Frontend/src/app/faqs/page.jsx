import { getFaqs } from "@/actions/others";
import Container from "@/components/shared/Container";
import Accordion from "./Accordion";

export const metadata = {
  title: "Frequently Asked Question",
};

const FaqPage = async () => {
  const { data } = await getFaqs();

  return (
    <section className="mt-8 md:mt-[60px] min-h-[calc(100vh-300px)] md:min-h-[calc(100vh-360px)]">
      <Container>
        <p className="text-2xl text-tBlack font-semibold text-center">FAQ</p>
        <div className="mt-6 md:mt-10 md:max-w-[80%] mx-auto space-y-4">
          {data?.map((item) => (
            <Accordion key={item.id} data={item} />
          ))}
        </div>
      </Container>
    </section>
  );
};

export default FaqPage;
