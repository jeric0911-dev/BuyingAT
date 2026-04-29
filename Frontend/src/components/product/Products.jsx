/* eslint-disable react-hooks/exhaustive-deps */
"use client";

import Image from "next/image";
import ProductCard from "../home/ProductCard";
import { usePathname, useSearchParams } from "next/navigation";
import { useForm } from "react-hook-form";
import { useCallback, useState } from "react";
import debounce from "lodash.debounce";
import { Dialog, DialogBackdrop, DialogPanel } from "@headlessui/react";
import { useTransitionRouter } from "next-view-transitions";

const Products = ({ categories, brands, data }) => {
  const { register, handleSubmit } = useForm();
  const router = useTransitionRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const params = new URLSearchParams(searchParams.toString());
  const [brandSearch, setBrandSearch] = useState("");
  const [filterBar, setFilterBar] = useState(false);

  const subCategoriesByCategory = categories?.find(
    (item) => item.id == searchParams.get("category_id")
  )?.sub_categories;
  const brandByCategory = brands?.filter(
    (item) => item.category_id == searchParams.get("category_id")
  );
  const filteredBrands = brandByCategory?.filter((item) =>
    item.brand_name.toLowerCase().includes(brandSearch.toLowerCase())
  );

  const onSubmit = (values) => {
    if (values.search !== "") {
      router.push(`${pathname}?search=${values.search}`);
    } else {
      router.push(pathname);
    }
  };

  const handleFilter = (key, value, allowMultiple = false) => {
    const existing = params.get(key)?.split(",").filter(Boolean) || [];

    if (!value || (!allowMultiple && existing[0] === value)) {
      params.delete(key);
    } else {
      const updated = allowMultiple
        ? existing.includes(value)
          ? existing.filter((v) => v !== value)
          : [...existing, value]
        : [value];

      updated.length > 0
        ? params.set(key, updated.join(","))
        : params.delete(key);
    }
    router.push(`${pathname}?${params.toString()}`);
  };

  const debouncedFilter = useCallback(
    debounce((key, value) => {
      handleFilter(key, value);
      closeFilterBar();
    }, 500),
    [handleFilter]
  );

  const closeFilterBar = () => setFilterBar(false);

  return (
    <div className="grid grid-cols-1 lg:grid-cols-[300px_1fr] gap-6 mt-8">
      {/* ----------------------side-filter--------------- */}
      <div className={`hidden lg:block`}>
        {/* --------------------category filter----------- */}
        <>
          <p className="font-medium">CATEGORY</p>
          <div className="mt-3 space-y-3 max-h-[150px] overflow-y-auto filter-scrollbar">
            {categories?.map((item, i) => (
              <div key={i}>
                <label className="text-sm text-[#475156] flex items-center gap-2">
                  <input
                    onChange={(e) => {
                      params.delete("sub_category_id");
                      params.delete("brand_id");
                      params.delete("page");
                      handleFilter("category_id", e.target.value);
                    }}
                    value={item.id}
                    checked={item.id == searchParams.get("category_id")}
                    type="checkbox"
                    className="form-checkbox border-border text-skyBlue focus:ring-0"
                  />
                  {item.category_name}
                </label>
              </div>
            ))}
          </div>
          <hr className="my-6" />
        </>
        {/* -----------------subCategory-------------- */}
        {subCategoriesByCategory?.length > 0 && (
          <>
            <p className="font-medium">SUB CATEGORY</p>
            <div className="mt-3 space-y-3 max-h-[150px] overflow-y-auto filter-scrollbar">
              {subCategoriesByCategory?.map((item, i) => (
                <div key={i}>
                  <label className="text-sm text-[#475156] flex items-center gap-2">
                    <input
                      onChange={(e) => {
                        params.delete("brand_id");
                        params.delete("page");
                        handleFilter("sub_category_id", e.target.value);
                      }}
                      value={item.id}
                      checked={item.id == searchParams.get("sub_category_id")}
                      type="checkbox"
                      className="form-checkbox border-border text-skyBlue focus:ring-0"
                    />
                    {item.sub_category_name}
                  </label>
                </div>
              ))}
            </div>
            <hr className="my-6" />
          </>
        )}
        {/* --------------------brand filter-------------- */}
        {brandByCategory?.length > 0 && (
          <>
            <p className="font-medium">BRAND</p>
            <input
              onChange={(e) => setBrandSearch(e.target.value)}
              value={brandSearch}
              type="text"
              className="my-4 w-full h-10 px-4 border border-border rounded-sm form-input focus:ring-0 focus:border-skyBlue text-sm"
              placeholder="Search Brand"
            />
            <div className="space-y-3 max-h-[150px] overflow-y-auto filter-scrollbar">
              {filteredBrands?.map((item, i) => (
                <label
                  key={i}
                  className="text-sm text-[#475156] flex items-center gap-2"
                >
                  <input 
                    onChange={(e) => {
                      handleFilter("brand_id", e.target.value, true);
                      params.delete("page");
                    }}
                    value={item.id}
                    checked={(searchParams.get("brand_id") || "")
                      .split(",")
                      .includes(String(item.id))}
                    type="checkbox"
                    className="form-checkbox border-border rounded-sm text-skyBlue focus:ring-0"
                  />
                  {item.brand_name}
                </label>
              ))}
            </div>
            <hr className="my-6" />
          </>
        )}
        {/* --------------------price filter-------------- */}
        <>
          {/* <input type="range" className="w-full" /> */}
          <div className="w-full h-10 flex items-center gap-3 my-4">
            <input
              type="number"
              className="form-input focus:ring-0 focus:border-skyBlue border-border rounded-sm px-3 text-sm w-1/2"
              placeholder="Min price"
              onChange={(e) => {
                debouncedFilter("min_price", e.target.value);
                params.delete("page");
              }}
            />
            <input
              type="number"
              className="form-input focus:ring-0 focus:border-skyBlue border-border rounded-sm px-3 text-sm w-1/2"
              placeholder="Max price"
              onChange={(e) => {
                debouncedFilter("max_price", e.target.value);
                params.delete("page");
              }}
            />
          </div>
          {/*  <div className="space-y-3">
            {prices.map((item, i) => (
              <label
                key={i}
                className="text-sm text-[#475156] flex items-center gap-2"
              >
                <input
                  type="radio"
                  name="price"
                  className="form-radio border-border text-skyBlue focus:ring-0"
                  value={item.label}
                />
                {item.label}
              </label>
            ))}
          </div> */}
        </>
      </div>
      {/* ----------------------side-filter responsive--------------- */}

      <div className="">
        {/* --------------------searchbar------------------ */}
        <div className="flex sm:flex-row flex-col w-full justify-between items-start sm:items-center gap-5">
          <div className="w-full sm:w-[60%] flex gap-5">
            {/* --------------------FilterBtn------------------ */}
            <button
              type="button"
              onClick={() => setFilterBar(!filterBar)} // Replace with your actual handler
              className="lg:hidden flex items-center gap-2 px-4 h-11 border border-border rounded-sm text-sm font-semibold text-[#053B5F] bg-white hover:bg-[#053B5F] hover:text-white transition-colors duration-200"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                className="h-4 w-4"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                strokeWidth={2}
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2a1 1 0 01-.293.707L15 13.414V20a1 1 0 01-1.447.894l-4-2A1 1 0 019 18v-4.586L3.293 6.707A1 1 0 013 6V4z"
                />
              </svg>
              Filter
            </button>
            <form
              onSubmit={handleSubmit(onSubmit)}
              className="relative w-[70%] h-11"
            >
              <input
                {...register("search")}
                type="text"
                className="form-input focus:ring-0 focus:border-skyBlue h-full w-full border border-border rounded-sm text-sm px-4"
                placeholder="Search for anything..."
              />
              <button type="submit" aria-label="search">
                <Image
                  src="/icon/search.svg"
                  alt="#"
                  width={20}
                  height={20}
                  className="absolute right-0 top-0 my-3 mr-4"
                />
              </button>
            </form>
          </div>
          <div className="h-11 w-full sm:w-max">
            <label className="text-sm">
              Sort by:
              <select
                onChange={(e) => {
                  const [sortBy, direction] = e.target.value.split("_");
                  if (!sortBy || !direction) {
                    handleFilter("sort_by", "");
                    handleFilter("sort_direction", "");
                  } else {
                    handleFilter("sort_by", sortBy);
                    handleFilter("sort_direction", direction);
                  }
                }}
                value={`${searchParams.get("sort_by") || ""}${
                  searchParams.get("sort_direction")
                    ? "_" + searchParams.get("sort_direction")
                    : ""
                }`}
                className="ml-5 h-full border border-border form-select focus:ring-0 focus:border-skyBlue text-tGray text-sm w-32 sm:w-36 md:w-44"
              >
                <option value="">Most Recent</option>
                <option value="price_asc">Lowest Price</option>
                <option value="price_desc">Highest Price</option>
                <option value="rating_desc">Highest Rating</option>
              </select>
            </label>
          </div>
        </div>
        {/* --------------------search-result-------------- */}
        {data?.length > 0 ? (
          <div className="mt-5 grid grid-cols-1 sm:grid-cols-3 xl:grid-cols-4 gap-4">
            {data?.map((item, i) => (
              <ProductCard key={i} data={item} star={true} />
            ))}
          </div>
        ) : (
          <Image
            src="/images/empty-search.png"
            alt="no item found"
            width={0}
            height={0}
            sizes="100vw"
            className="w-full md:w-1/2 lg:w-2/5 h-auto mx-auto mt-10 lg:mt-20"
          />
        )}
      </div>
      <Dialog open={filterBar} onClose={setFilterBar}>
        <DialogBackdrop
          transition
          className="fixed inset-0 bg-black/30 transition-opacity duration-500 ease-in-out data-[closed]:opacity-0"
        />
        <div className="fixed inset-0 overflow-hidden">
          <div className="absolute inset-0 overflow-hidden">
            <div className="pointer-events-none fixed inset-y-0 left-0 flex w-[80%] sm:w-[60%]">
              <DialogPanel
                transition
                className="pointer-events-auto relative w-full transform transition duration-500 ease-in-out data-[closed]:-translate-x-full sm:duration-700"
              >
                <div className="flex h-full flex-col bg-white p-6 shadow-xl">
                  <button
                    type="button"
                    onClick={closeFilterBar}
                    className="lg:hidden flex items-center mb-14 gap-2 px-4 h-11 w-max border border-border rounded-sm text-sm font-semibold text-[#053B5F] bg-white hover:bg-[#053B5F] hover:text-white transition-colors duration-200"
                  >
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      className="h-4 w-4"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                      strokeWidth={2}
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        d="M6 18L18 6M6 6l12 12"
                      />
                    </svg>
                    Close
                  </button>

                  <p className="font-medium">CATEGORY</p>
                  <div className="mt-3 space-y-3 max-h-[150px] overflow-y-auto filter-scrollbar">
                    {categories?.map((item, i) => (
                      <div key={i}>
                        <label className="text-sm text-[#475156] flex items-center gap-2">
                          <input
                            onChange={(e) => {
                              params.delete("brand_id");
                              params.delete("page");
                              handleFilter("category_id", e.target.value);
                              closeFilterBar();
                            }}
                            value={item.id}
                            checked={item.id == searchParams.get("category_id")}
                            type="checkbox"
                            className="form-checkbox border-border text-skyBlue focus:ring-0"
                          />
                          {item.category_name}
                        </label>
                      </div>
                    ))}
                  </div>
                  <hr className="my-6" />
                  {subCategoriesByCategory?.length > 0 && (
                    <>
                      <p className="font-medium">SUB CATEGORY</p>
                      <div className="mt-3 space-y-3 max-h-[150px] overflow-y-auto filter-scrollbar">
                        {subCategoriesByCategory?.map((item, i) => (
                          <div key={i}>
                            <label className="text-sm text-[#475156] flex items-center gap-2">
                              <input
                                onChange={(e) => {
                                  params.delete("brand_id");
                                  params.delete("page");
                                  handleFilter(
                                    "sub_category_id",
                                    e.target.value
                                  );
                                  closeFilterBar();
                                }}
                                value={item.id}
                                checked={
                                  item.id == searchParams.get("sub_category_id")
                                }
                                type="checkbox"
                                className="form-checkbox border-border text-skyBlue focus:ring-0"
                              />
                              {item.sub_category_name}
                            </label>
                          </div>
                        ))}
                      </div>
                      <hr className="my-6" />
                    </>
                  )}
                  {/* --------------------brand filter-------------- */}
                  {brandByCategory?.length > 0 && (
                    <>
                      <p className="font-medium">BRAND</p>
                      <input
                        onChange={(e) => setBrandSearch(e.target.value)}
                        value={brandSearch}
                        type="text"
                        className="my-4 w-full h-10 px-4 border border-border rounded-sm form-input focus:ring-0 focus:border-skyBlue text-sm"
                        placeholder="Search Brand"
                      />
                      <div className="space-y-3 max-h-[150px] overflow-y-auto filter-scrollbar">
                        {filteredBrands?.map((item, i) => (
                          <label
                            key={i}
                            className="text-sm text-[#475156] flex items-center gap-2"
                          >
                            <input
                              onChange={(e) => {
                                handleFilter("brand_id", e.target.value, true);
                                params.delete("page");
                                closeFilterBar();
                              }}
                              value={item.id}
                              checked={(searchParams.get("brand_id") || "")
                                .split(",")
                                .includes(String(item.id))}
                              type="checkbox"
                              className="form-checkbox border-border rounded-sm text-skyBlue focus:ring-0"
                            />
                            {item.brand_name}
                          </label>
                        ))}
                      </div>
                      <hr className="my-6" />
                    </>
                  )}
                  {/* --------------------price filter-------------- */}
                  <>
                    {/* <input type="range" className="w-full" /> */}
                    <div className="w-full h-10 flex items-center gap-3 my-4">
                      <input
                        type="number"
                        className="form-input focus:ring-0 focus:border-skyBlue border-border rounded-sm px-3 text-sm w-1/2"
                        placeholder="Min price"
                        defaultValue={searchParams.get("min_price") || ""}
                        onChange={(e) => {
                          debouncedFilter("min_price", e.target.value);
                          params.delete("page");
                        }}
                      />
                      <input
                        type="number"
                        className="form-input focus:ring-0 focus:border-skyBlue border-border rounded-sm px-3 text-sm w-1/2"
                        placeholder="Max price"
                        defaultValue={searchParams.get("max_price") || ""}
                        onChange={(e) => {
                          debouncedFilter("max_price", e.target.value);
                          params.delete("page");
                        }}
                      />
                    </div>
                  </>
                </div>
              </DialogPanel>
            </div>
          </div>
        </div>
      </Dialog>
    </div>
  );
};

export default Products;
