"use client";

import { useTransitionRouter } from "next-view-transitions";
import Image from "next/image";
import { usePathname, useSearchParams } from "next/navigation";
import ReactPaginate from "react-paginate";

const Pagination = ({ total_pages, className }) => {
  const searchParams = useSearchParams();
  const pathname = usePathname();
  const { push } = useTransitionRouter();
  const page = searchParams.get("page") || 1;

  const handlePageChange = (e) => {
    const params = new URLSearchParams(searchParams);
    params.set("page", e.selected + 1);
    push(`${pathname}?${params.toString()}`);
  };

  return (
    <ReactPaginate
      pageCount={total_pages}
      pageRangeDisplayed={1}
      marginPagesDisplayed={2}
      forcePage={page - 1}
      onPageChange={handlePageChange}
      nextLabel={
        <div className="size-8 md:size-10 border border-skyBlue hover:bg-skyBlue/10 transition-colors ml-5 flex justify-center items-center rounded-full cursor-pointer">
          <Image
            src="/icon/ArrowLeft.svg"
            alt="next page"
            width={24}
            height={24}
            className="rotate-180"
          />
        </div>
      }
      previousLabel={
        <div className="size-8 md:size-10 border border-skyBlue hover:bg-skyBlue/10 transition-colors mr-5 flex justify-center items-center rounded-full cursor-pointer">
          <Image
            src="/icon/ArrowLeft.svg"
            alt="previous page"
            width={24}
            height={24}
          />
        </div>
      }
      pageLinkClassName="size-8 md:size-10 border border-border hover:border-skyBlue inline-flex justify-center items-center cursor-pointer rounded-full transition-colors mx-1"
      activeLinkClassName="size-8 md:size-10 flex justify-center items-center cursor-pointer rounded-full bg-skyBlue border border-skyBlue text-white"
      containerClassName={`flex justify-center items-center text-tBlack md:mb-16 mb-12 lg:mb-20 ${className}`}
      breakLabel="..."
      renderOnZeroPageCount={null}
    />
  );
};

export default Pagination;
