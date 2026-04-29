"use client";

import dayjs from "dayjs";
import dynamic from "next/dynamic";
import Image from "next/image";
import { Link } from "next-view-transitions";
const DataTable = dynamic(() => import("react-data-table-component"), {
  ssr: false,
  loading: () => <div className="h-12 w-full bg-slate-200 animate-pulse" />,
});

const ProfileTable = ({ data }) => {
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
          href={`/my-orders/${row.id}`}
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
  return <DataTable columns={columns} data={data} responsive={true} />;
};

export default ProfileTable;
