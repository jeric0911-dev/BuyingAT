import { getUser } from "@/actions/auth";
import { getBrands, getCategories, getSubCategories } from "@/actions/others";
import { getSingleProduct } from "@/actions/product";
import EditProductForm from "@/components/addProduct/EditProductForm";
import Container from "@/components/shared/Container";
import { redirect } from "next/navigation";

export const metadata = {
  title: "Edit Product",
  description: "Edit your product details",
  robots: { index: false },
};

const EditProductPage = async ({ searchParams }) => {
  const [{ data: categories }, { data: subCategories }, { data: brands }] =
    await Promise.all([getCategories(), getSubCategories(), getBrands()]);

  const id = searchParams.id;
  if (!id)
    return (
      <section className="mt-10 text-center">
        You must select a product to continue
      </section>
    );

  const { data } = await getSingleProduct(id);
  const { data: user } = await getUser();

  if (user?.id !== data?.user_id) redirect("/");

  if (!data)
    return (
      <section className="mt-10 text-center">Product ID is not valid!</section>
    );

  return (
    <section className="mt-10">
      <Container>
        <p className="px-6 py-4 border border-border rounded text-sm font-medium">
          EDIT LISTING
        </p>
        <EditProductForm
          brands={brands}
          categories={categories}
          data={data}
          subCategories={subCategories}
        />
      </Container>
    </section>
  );
};

export default EditProductPage;
