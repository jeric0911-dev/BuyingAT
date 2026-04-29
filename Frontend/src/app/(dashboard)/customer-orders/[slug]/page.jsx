import { getOrderDetails } from "@/actions/cart";
import OrderActivity from "@/components/orderHistory/OrderActivity";
import OrderStatus from "@/components/orderHistory/OrderStatus";
import OrderStatusMenu from "@/components/orderHistory/OrderStatusMenu";
import ProductRow from "@/components/orderHistory/ProductRow";
import dayjs from "dayjs";
import Image from "next/image";
import { Link } from "next-view-transitions";

export const metadata = {
  title: "Order Details",
  robots: { index: false },
};

const OrderDetailsPage = async ({ params: { slug } }) => {
  const { data } = await getOrderDetails(slug);
  const orderStatusLength =
    data?.order_status === "cancelled" ? 0 : data?.order_status_detail?.length;

  return (
    <div>
      <section>
        <div className="border border-border rounded px-6 py-4 flex items-center justify-between">
          <Link href="/customer-orders" className="flex items-center gap-3">
            <Image
              src="/icon/right-arrow-black.svg"
              alt="#"
              width={24}
              height={24}
              className="rotate-180"
            />
            <span className="uppercase text-sm font-medium">Order Details</span>
          </Link>
          <OrderStatusMenu data={data} />
        </div>
        <div className="p-6">
          <div className="p-6 border border-skyBlue/50 rounded bg-skyBlue/10 flex flex-col sm:flex-row justify-evenly sm:justify-between items-start sm:items-center">
            <div>
              <p className="text-xl">#{data?.order_id}</p>
              <p className="text-tGray text-sm flex flex-col sm:flex-row sm:items-center items-start gap-2 mt-2">
                <span>{data?.quantity} Products</span>
                <span className="hidden sm:block">•</span>
                <span>
                  Order Placed in{" "}
                  {dayjs(data?.created_at).format("DD MMM, YYYY [at] h:mm A")}
                </span>
              </p>
            </div>
            <p className="text-[28px] text-skyBlue font-semibold">
              ${data?.amount}
            </p>
          </div>
          {/* <p className="text-sm my-6">
            <span className="text-tGray">Order expected arrival</span>{" "}
            <span className="font-medium">23 Jan, 2021</span>
          </p> */}
          <OrderStatus status={orderStatusLength} />
        </div>
      </section>
      <OrderActivity data={data} />
      <section className="py-8">
        <p className="px-6 text-lg font-medium">
          Product{" "}
          <span className="text-tGray font-normal">
            ({data?.ordered_items?.length})
          </span>
        </p>
        <div className="overflow-x-auto">
          <div className="min-w-[1000px]">
            <div className="grid grid-cols-[1fr_124px_80px_80px_80px_80px_150px] gap-5 text-xs px-6 py-[10px] border border-border bg-lightGray mt-5">
              <p>PRODUCTS</p>
              <p>PRICE</p>
              <p>QUANTITY</p>
              <p>COLOR</p>
              <p>SIZE</p>
              <p>VARIANT</p>
              <p>SUB-TOTAL</p>
            </div>
            <div className="px-6 divide-y border border-t-0 border-border">
              {data?.ordered_items?.map((item, index) => (
                <ProductRow key={index} data={item} />
              ))}
            </div>
          </div>
        </div>
      </section>
      <section className="grid grid-cols-1 sm:grid-cols-2 py-8 divide-y sm:divide-x sm:divide-y-0 border border-border rounded">
        {/* <div className="px-6 sm:py-0 py-3">
          <p className="text-lg font-medium">Billing Address</p>
          <p className="text-sm font-medium mt-6">Kevin Gilbert</p>
          <p className="mt-2 text-sm text-tGray">
            East Tejturi Bazar, Word No. 04, Road No. 13/x, House no. 1320/C,
            Flat No. 5D, Dhaka - 1200, Bangladesh
          </p>
          <p className="mt-2 text-sm">
            Phone Number: <span className="text-tGray"> +1-202-555-0118</span>
          </p>
          <p className="mt-2 text-sm mb-6">
            Email: <span className="text-tGray"> kevin.gilbert@gmail.com</span>
          </p>
        </div> */}
        <div className="px-6 sm:py-0 py-3">
          <p className="text-lg font-medium">Shipping Address</p>
          <p className="text-sm font-medium mt-6">{data?.delivery_address}</p>
        </div>
        <div className="px-6 sm:py-0 py-3">
          <p className="text-lg font-medium">Order Notes</p>
          <p className="mt-6 text-sm text-tGray">{data?.order_note}</p>
        </div>
      </section>
    </div>
  );
};

export default OrderDetailsPage;
