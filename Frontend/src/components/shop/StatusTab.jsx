"use client";

import Image from "next/image";
import { Link, useTransitionRouter } from "next-view-transitions";
import { usePathname, useSearchParams } from "next/navigation";
import { useForm } from "react-hook-form";

const allStatus = ["active", "unpublished", "pending", "disabled", "rejected"];

const StatusTab = () => {
  const pathname = usePathname();
  const router = useTransitionRouter();
  const searchParams = useSearchParams();
  const { register, handleSubmit } = useForm({
    defaultValues: { search: searchParams.get("search") || "" },
  });

  const onSubmit = (values) => {
    const params = new URLSearchParams(searchParams);

    if (values.search !== "") {
      params.set("search", values.search);
    } else {
      params.delete("search");
    }

    const newQueryString = params.toString();
    const url = newQueryString ? `${pathname}?${newQueryString}` : pathname;

    router.push(url);
  };

  return (
    <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-5 md:gap-0 overflow-hidden">
      <div className="flex gap-3 overflow-x-auto no-scrollbar w-full md:w-[60%] min-w-0">
        {allStatus.map((item) => (
          <Link
            key={item}
            href={`${pathname}?status=${item}`}
            prefetch={false}
            className={`rounded-[3px] border border-skyBlue text-sm uppercase font-bold px-3 lg:px-5 py-2 transition-colors hover:bg-skyBlue hover:text-white ${
              item === (searchParams.get("status") ?? "active")
                ? "text-white bg-skyBlue"
                : "text-skyBlue"
            }`}
          >
            {item}
          </Link>
        ))}
      </div>
      <form
        onSubmit={handleSubmit(onSubmit)}
        className="relative w-full sm:w-auto xl:min-w-56 h-[38px]"
      >
        <input
          {...register("search")}
          type="text"
          className="form-input focus:ring-0 focus:border-skyBlue h-full w-full border border-border rounded-sm text-sm pl-4 pr-9"
          placeholder="Search product..."
        />
        <button type="submit" aria-label="search">
          <Image
            src="/icon/search.svg"
            alt="#"
            width={20}
            height={20}
            className="absolute right-0 top-0 my-2 mr-4"
          />
        </button>
      </form>
    </div>
  );
};

export default StatusTab;
