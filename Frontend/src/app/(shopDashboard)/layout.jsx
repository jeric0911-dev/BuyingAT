import { getUser } from "@/actions/auth";
import { getMyShop, getMyShopProducts } from "@/actions/vendor";
import Container from "@/components/shared/Container";
import SideNav from "@/components/shared/SideNav";
import ShopInfo from "@/components/shop/ShopInfo";

export const dynamic = "force-dynamic";

const layout = async ({ children }) => {
  const [{ data: shopInfo }, { pagination }, {data: user}] = await Promise.all([
    getMyShop(),
    getMyShopProducts(),
    getUser()
  ]);

  return (
    <Container>
      <ShopInfo data={shopInfo} pagination={pagination} user={user} />
      <div className="grid grid-cols-1 lg:grid-cols-[250px_1fr] gap-16 mt-8">
        <SideNav user={user} />
        <div>{children}</div>
      </div>
    </Container>
  );
};

export default layout;
