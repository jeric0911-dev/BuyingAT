import { getMyOrders } from "@/actions/cart";
import OrderHistoryTable from "@/components/orderHistory/OrderHistoryTable";
import Pagination from "@/components/shared/Pagination";

export const metadata = {
  title: "My Inventory",
  robots: { index: false },
};

const MyInventoryPage = async ({ searchParams: { page } }) => {
  const { data, pagination } = await getMyOrders(page);

  return (
    <section className="border border-border rounded overflow-hidden">
      <OrderHistoryTable data={data} />
      <Pagination total_pages={pagination?.last_page} className="!my-12" />
    </section>
  );
};

export default MyInventoryPage;
