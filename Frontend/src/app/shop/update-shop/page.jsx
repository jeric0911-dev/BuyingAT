import { getUser } from "@/actions/auth";
import Container from "@/components/shared/Container";
import UpdateShopForm from "@/components/shop/UpdateShopForm";
import { redirect } from "next/navigation";

export const metadata = {
  title: "Update Shop",
  description: "Update your shop details and information.",
  robots: { index: false },
};

export const dynamic = "force-dynamic";

const UpdateShopPage = async () => {
  const { data: user } = await getUser();

  if (user?.user_type !== "vendor") redirect("/");

  return (
    <section className="mt-10">
      <Container>
        <p className="px-6 py-4 border border-border rounded text-sm font-medium">
          UPDATE SHOP
        </p>
        <UpdateShopForm data={user?.shop} />
      </Container>
    </section>
  );
};

export default UpdateShopPage;
