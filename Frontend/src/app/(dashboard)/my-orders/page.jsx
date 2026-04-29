import { getMyOrders } from "@/actions/cart";
import OrderHistoryTable from "@/components/orderHistory/OrderHistoryTable";
import Pagination from "@/components/shared/Pagination";

export const metadata = {
  title: "My Orders",
  robots: { index: false },
};

const MyOrdersPage = async ({ searchParams: { page } }) => {
  console.log('MyOrdersPage: Fetching orders for page:', page);
  const response = await getMyOrders(page);
  console.log('MyOrdersPage: Full response:', response);
  
  const { data, pagination } = response || { data: [], pagination: {} };
  console.log('MyOrdersPage: Extracted data:', data);
  console.log('MyOrdersPage: Extracted pagination:', pagination);

  return (
    <section className="border border-border rounded overflow-hidden">
      <OrderHistoryTable data={data} />
      <Pagination total_pages={pagination?.last_page} className="!my-12" />
    </section>
  );
};

export default MyOrdersPage;
