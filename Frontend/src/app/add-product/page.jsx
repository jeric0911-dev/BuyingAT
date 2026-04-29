import { getBrands, getCategories, getSubCategories } from "@/actions/others";
import AddProductForm from "@/components/addProduct/AddProductForm";
import Container from "@/components/shared/Container";

export const metadata = {
  title: "Add Product",
  description: "Add a new product to your listings",
  robots: { index: false },
};

const AddProductPage = async () => {
  const [{ data: categories }, { data: subCategories }, { data: brands }] =
    await Promise.all([getCategories(), getSubCategories(), getBrands()]);

  return (
    <section className="mt-10">
      <Container>
        <p className="px-6 py-4 border border-border rounded text-sm font-medium">
          CREATE NEW CARD
        </p>
        <AddProductForm
          categories={categories}
          subCategories={subCategories}
          brands={brands}
        />
      </Container>
    </section>
  );
};

export default AddProductPage;
