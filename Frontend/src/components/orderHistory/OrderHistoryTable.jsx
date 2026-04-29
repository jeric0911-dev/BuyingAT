"use client";

import dayjs from "dayjs";
import Image from "next/image";
import { Link } from "next-view-transitions";
import { useState } from "react";
import dynamic from "next/dynamic";
import { usePathname } from "next/navigation";
const DataTable = dynamic(() => import("react-data-table-component"), {
  ssr: false,
});

const OrderHistoryTable = ({ data }) => {
  const [search, setSearch] = useState("");
  const pathname = usePathname();

  console.log('OrderHistoryTable: Received data:', data);
  console.log('OrderHistoryTable: Data type:', typeof data);
  console.log('OrderHistoryTable: Data length:', data?.length);

  const filteredData = data?.filter((order) =>
    order.order_id.toLowerCase().includes(search.toLowerCase())
  );

  const columns = [
    {
      name: "ORDER ID",
      selector: (row) => <p className="text-sm font-medium">{row.order_id}</p>,
    },
    {
      name: "DATE",
      selector: (row) => (
        <p className="text-sm text-tGray">
          {dayjs(row.created_at).format("MMM DD, YYYY HH:mm")}
        </p>
      ),
    },
    {
      name: "TOTAL",
      selector: (row) => (
        <p className="text-sm text-tGray">
          ${row.amount} ({row.quantity} Products)
        </p>
      ),
    },
    {
      name: "STATUS",
      selector: (row) => row.order_status,
      sortable: true,
      cell: (row) => (
        <p
          className={`${
            row?.order_status === "pending"
              ? "text-skyBlue"
              : row.order_status === "processing"
              ? "text-[#9958EE]"
              : row.order_status === "completed"
              ? "text-green"
              : row.order_status === "cancelled"
              ? "text-red-500"
              : ""
          } uppercase text-sm font-semibold`}
        >
          {row.order_status}
        </p>
      ),
    },
    {
      name: "ACTION",
      selector: (row) => (
        <Link
          prefetch={false}
          href={`${pathname}/${row.id}`}
          className="text-skyBlue text-sm font-semibold flex items-center gap-2"
        >
          <span>View Details</span>
          <Image
            src="/icon/right-arrow-blue.svg"
            alt="#"
            width={16}
            height={16}
          />
        </Link>
      ),
      width: "140px",
    },
  ];

  return (
    <>
      <div className="flex justify-between items-center px-2 md:px-6 h-[52px]">
        <p className="text-xs md:text-sm font-medium">ORDER HISTORY</p>
        <div className="relative min-w-[150px] max-w-[228px] h-[38px]">
          <input
            onChange={(e) => setSearch(e.target.value)}
            type="text"
            className="form-input focus:ring-0 focus:border-skyBlue h-full w-full  border border-border rounded-sm text-sm px-4"
            placeholder="Search Order ID..."
          />
          <Image
            src="/icon/search.svg"
            alt="#"
            width={20}
            height={20}
            className="absolute right-0 top-0 my-2 mr-4"
          />
        </div>
      </div>
      <DataTable columns={columns} data={filteredData} responsive={true} />
    </>
  );
};

export default OrderHistoryTable;
