/* eslint-disable react-hooks/exhaustive-deps */
"use client";

import CardCard from "../home/CardCard";
import { usePathname, useSearchParams } from "next/navigation";
import { useForm } from "react-hook-form";
import { useCallback, useState } from "react";
import debounce from "lodash.debounce";
import { Dialog, DialogBackdrop, DialogPanel } from "@headlessui/react";
import { useTransitionRouter } from "next-view-transitions";

const Cards = ({ data }) => {
  const { register, handleSubmit } = useForm();
  const router = useTransitionRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const params = new URLSearchParams(searchParams.toString());
  const [filterBar, setFilterBar] = useState(false);

  const onSubmit = (values) => {
    if (values.search !== "") {
      router.push(`${pathname}?search=${values.search}`);
    } else {
      router.push(pathname);
    }
  };

  const handleFilter = (key, value) => {
    if (!value) {
      params.delete(key);
    } else {
      params.set(key, value);
    }
    router.push(`${pathname}?${params.toString()}`);
  };

  const clearFilters = () => {
    router.push(pathname);
  };

  const debouncedSearch = useCallback(
    debounce((value) => {
      if (value !== "") {
        router.push(`${pathname}?search=${value}`);
      } else {
        router.push(pathname);
      }
    }, 500),
    [pathname, router]
  );

  const handleSearchChange = (e) => {
    debouncedSearch(e.target.value);
  };

  // Get unique sport types and conditions from current data
  const sportTypes = [...new Set(data?.map(card => card.sport_type).filter(Boolean))];
  const conditions = [...new Set(data?.map(card => card.condition).filter(Boolean))];
  
  // For grades, always show both options since it's a fixed set
  const grades = ['Yes', 'No'];

  return (
    <div className="grid grid-cols-1 lg:grid-cols-[300px_1fr] gap-6">
      {/* Filter Sidebar */}
      <div className="hidden lg:block">
        <div className="bg-white border border-border p-4 rounded">
          <h3 className="font-semibold text-lg mb-4">Filters</h3>
          
          {/* Search */}
          <div className="mb-4">
            <label className="block text-sm font-medium mb-2">Search Cards</label>
            <input
              type="text"
              placeholder="Search by title or description..."
              className="w-full p-2 border border-border rounded text-sm"
              defaultValue={searchParams.get("search") || ""}
              onChange={handleSearchChange}
            />
          </div>

          {/* Sport Type Filter */}
          {sportTypes.length > 0 && (
            <div className="mb-4">
              <label className="block text-sm font-medium mb-2">Card Type</label>
              <select
                className="w-full p-2 border border-border rounded text-sm"
                value={searchParams.get("sport_type") || ""}
                onChange={(e) => handleFilter("sport_type", e.target.value)}
              >
                <option value="">All Type</option>
                {sportTypes.map((sport) => (
                  <option key={sport} value={sport}>
                    {sport}
                  </option>
                ))}
              </select>
            </div>
          )}

          {/* Condition Filter */}
          {conditions.length > 0 && (
            <div className="mb-4">
              <label className="block text-sm font-medium mb-2">Condition</label>
              <select
                className="w-full p-2 border border-border rounded text-sm"
                value={searchParams.get("condition") || ""}
                onChange={(e) => handleFilter("condition", e.target.value)}
              >
                <option value="">All Conditions</option>
                {conditions.map((condition) => (
                  <option key={condition} value={condition}>
                    {condition}
                  </option>
                ))}
              </select>
            </div>
          )}

          {/* Grade Filter */}
          {grades.length > 0 && (
            <div className="mb-4">
              <label className="block text-sm font-medium mb-2">Graded</label>
              <select
                className="w-full p-2 border border-border rounded text-sm"
                value={searchParams.get("grade") || ""}
                onChange={(e) => handleFilter("grade", e.target.value)}
              >
                {grades.map((grade) => (
                  <option key={grade} value={grade}>
                    {grade}
                  </option>
                ))}
              </select>
            </div>
          )}

          {/* Price Range */}
          <div className="mb-4">
            <label className="block text-sm font-medium mb-2">Price Range</label>
            <div className="grid grid-cols-2 gap-2">
              <input
                type="number"
                placeholder="Min"
                className="p-2 border border-border rounded text-sm"
                defaultValue={searchParams.get("min_price") || ""}
                onChange={(e) => handleFilter("min_price", e.target.value)}
              />
              <input
                type="number"
                placeholder="Max"
                className="p-2 border border-border rounded text-sm"
                defaultValue={searchParams.get("max_price") || ""}
                onChange={(e) => handleFilter("max_price", e.target.value)}
              />
            </div>
          </div>

          {/* Sort */}
          <div className="mb-4">
            <label className="block text-sm font-medium mb-2">Sort By</label>
            <select
              className="w-full p-2 border border-border rounded text-sm"
              value={searchParams.get("sort_by") || "created_at"}
              onChange={(e) => handleFilter("sort_by", e.target.value)}
            >
              <option value="created_at">Newest First</option>
              <option value="price_asc">Price: Low to High</option>
              <option value="price_desc">Price: High to Low</option>
            </select>
          </div>

          {/* Clear Filters */}
          <button
            onClick={clearFilters}
            className="w-full p-2 bg-gray-100 hover:bg-gray-200 rounded text-sm transition-colors"
          >
            Clear All Filters
          </button>
        </div>
      </div>

      {/* Cards Grid */}
      <div>
        {/* Mobile Filter Toggle */}
        <div className="lg:hidden mb-4">
          <button
            onClick={() => setFilterBar(!filterBar)}
            className="w-full p-3 bg-white border border-border rounded flex items-center justify-between"
          >
            <span>Filters</span>
            <span>{filterBar ? "−" : "+"}</span>
          </button>
        </div>

        {/* Mobile Filter Panel */}
        <Dialog open={filterBar} onClose={() => setFilterBar(false)}>
          <DialogBackdrop className="fixed inset-0 bg-black/30" />
          <DialogPanel className="fixed inset-y-0 left-0 w-80 bg-white p-4 overflow-y-auto">
            <div className="flex justify-between items-center mb-4">
              <h3 className="font-semibold text-lg">Filters</h3>
              <button onClick={() => setFilterBar(false)}>×</button>
            </div>
            
            {/* Same filter content as desktop */}
            <div className="mb-4">
              <label className="block text-sm font-medium mb-2">Search Cards</label>
              <input
                type="text"
                placeholder="Search by title or description..."
                className="w-full p-2 border border-border rounded text-sm"
                defaultValue={searchParams.get("search") || ""}
                onChange={handleSearchChange}
              />
            </div>

            {sportTypes.length > 0 && (
              <div className="mb-4">
                <label className="block text-sm font-medium mb-2">Card Type</label>
                <select
                  className="w-full p-2 border border-border rounded text-sm"
                  value={searchParams.get("sport_type") || ""}
                  onChange={(e) => handleFilter("sport_type", e.target.value)}
                >
                  <option value="">All Sports</option>
                  {sportTypes.map((sport) => (
                    <option key={sport} value={sport}>
                      {sport}
                    </option>
                  ))}
                </select>
              </div>
            )}

            {conditions.length > 0 && (
              <div className="mb-4">
                <label className="block text-sm font-medium mb-2">Condition</label>
                <select
                  className="w-full p-2 border border-border rounded text-sm"
                  value={searchParams.get("condition") || ""}
                  onChange={(e) => handleFilter("condition", e.target.value)}
                >
                  <option value="">All Conditions</option>
                  {conditions.map((condition) => (
                    <option key={condition} value={condition}>
                      {condition}
                    </option>
                  ))}
                </select>
              </div>
            )}

            {grades.length > 0 && (
              <div className="mb-4">
                <label className="block text-sm font-medium mb-2">Grade</label>
                <select
                  className="w-full p-2 border border-border rounded text-sm"
                  value={searchParams.get("grade") || ""}
                  onChange={(e) => handleFilter("grade", e.target.value)}
                >
                  <option value="">All Grades</option>
                  {grades.map((grade) => (
                    <option key={grade} value={grade}>
                      {grade}
                    </option>
                  ))}
                </select>
              </div>
            )}

            <div className="mb-4">
              <label className="block text-sm font-medium mb-2">Price Range</label>
              <div className="grid grid-cols-2 gap-2">
                <input
                  type="number"
                  placeholder="Min"
                  className="p-2 border border-border rounded text-sm"
                  defaultValue={searchParams.get("min_price") || ""}
                  onChange={(e) => handleFilter("min_price", e.target.value)}
                />
                <input
                  type="number"
                  placeholder="Max"
                  className="p-2 border border-border rounded text-sm"
                  defaultValue={searchParams.get("max_price") || ""}
                  onChange={(e) => handleFilter("max_price", e.target.value)}
                />
              </div>
            </div>

            <div className="mb-4">
              <label className="block text-sm font-medium mb-2">Sort By</label>
              <select
                className="w-full p-2 border border-border rounded text-sm"
                value={searchParams.get("sort_by") || "created_at"}
                onChange={(e) => handleFilter("sort_by", e.target.value)}
              >
                <option value="created_at">Newest First</option>
                <option value="price_asc">Price: Low to High</option>
                <option value="price_desc">Price: High to Low</option>
              </select>
            </div>

            <button
              onClick={clearFilters}
              className="w-full p-2 bg-gray-100 hover:bg-gray-200 rounded text-sm transition-colors"
            >
              Clear All Filters
            </button>
          </DialogPanel>
        </Dialog>

        {/* Results Count */}
        <div className="mb-4">
          <p className="text-sm text-gray-600">
            {data?.length || 0} card{data?.length !== 1 ? 's' : ''} found
          </p>
        </div>

        {/* Cards Grid */}
        {data && data.length > 0 ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
            {data.map((card) => (
              <CardCard key={card.id} data={card} showSeller={true} />
            ))}
          </div>
        ) : (
          <div className="text-center py-12">
            <p className="text-gray-500 text-lg">No cards found</p>
            <p className="text-gray-400 text-sm mt-2">
              Try adjusting your search or filter criteria
            </p>
          </div>
        )}
      </div>
    </div>
  );
};

export default Cards;
