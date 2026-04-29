import CreateShopForm from "@/components/shop/CreateShopForm";
import Container from "@/components/shared/Container";

export const metadata = {
  title: "Create Shop",
  description: "Create a new shop to start selling your products.",
  robots: { index: false },
};

const CreateShopPage = () => {
  return (
    <section className="mt-10">
      <Container>
        <p className="px-6 py-4 border border-border rounded text-sm font-medium">
          CREATE SHOP
        </p>
        <CreateShopForm />
      </Container>
    </section>
  );
};

export default CreateShopPage;
