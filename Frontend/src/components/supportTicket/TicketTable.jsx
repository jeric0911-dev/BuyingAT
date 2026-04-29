"use client";

import { Link } from "next-view-transitions";
import DataTable from "react-data-table-component";
import { FiPlus } from "react-icons/fi";
import { IoEyeOutline } from "react-icons/io5";

const TicketTable = ({ data }) => {
  const columns = [
    {
      name: "SUBJECT",
      selector: (row) => <p className="text-skyBlue">{row?.subject}</p>,
    },
    {
      name: "STATUS",
      selector: (row) => (
        <p
          className={`${
            row?.status
              ? "text-green bg-green/10"
              : "text-red-500 bg-red-100"
          } py-2 px-3 rounded font-medium`}
        >
          {row?.status ? "OPEN" : "CLOSED"}
        </p>
      ),
    },
    {
      name: "PRIORITY",
      selector: (row) => (
        <p
          className={`${
            row?.priority === "low"
              ? "text-green bg-green/10"
              : row?.priority === "medium"
              ? "text-yellow bg-yellow/10"
              : row?.priority === "high"
              ? "text-red-500 bg-red-100"
              : ""
          } py-2 px-3 rounded uppercase font-medium`}
        >
          {row?.priority}
        </p>
      ),
    },
    {
      name: "ACTION",
      selector: (row) => (
        <Link href={`/support-ticket/${row?.id}`}>
          <IoEyeOutline size={20} />
        </Link>
      ),
      width: "120px",
    },
  ];

  return (
    <>
      <div className="flex justify-between items-center px-2 md:px-6 h-[52px]">
        <p className="text-xs md:text-sm font-medium">SUPPORT TICKET</p>
        <Link href="/support-ticket/new">
          <button className="py-2 px-4 bg-skyBlue text-white font-medium rounded-sm flex items-center justify-center gap-2">
            <FiPlus size={20} />
            New Ticket
          </button>
        </Link>
      </div>
      <DataTable columns={columns} data={data} responsive={true} />
    </>
  );
};

export default TicketTable;
