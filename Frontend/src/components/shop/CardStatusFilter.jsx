"use client";

import { useState } from "react";
import { useSearchParams, useRouter, usePathname } from "next/navigation";
import { FaSearch } from "react-icons/fa";

const CardStatusFilter = () => {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();
  
  const [searchTerm, setSearchTerm] = useState(searchParams.get('search') || '');
  
  const statusFilters = [
    { key: 'all', label: 'ALL' },
    { key: 'approved', label: 'ACTIVE' },
    { key: 'pending', label: 'PENDING' },
    { key: 'rejected', label: 'REJECTED' }
  ];

  const currentStatus = searchParams.get('status') || 'all';

  const handleStatusFilter = (status) => {
    const params = new URLSearchParams(searchParams);
    if (status === currentStatus) {
      params.delete('status');
    } else {
      params.set('status', status);
    }
    router.push(`${pathname}?${params.toString()}`);
  };

  const handleSearch = (e) => {
    e.preventDefault();
    const params = new URLSearchParams(searchParams);
    if (searchTerm.trim()) {
      params.set('search', searchTerm.trim());
    } else {
      params.delete('search');
    }
    router.push(`${pathname}?${params.toString()}`);
  };

  const clearFilters = () => {
    router.push(pathname);
    setSearchTerm('');
  };

  return (
    <div className="bg-white p-4 rounded-lg shadow-sm border border-gray-200 mb-6">
      <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
        {/* Status Filter Buttons */}
        <div className="flex flex-wrap gap-2">
          {statusFilters.map((filter) => (
            <button
              key={filter.key}
              onClick={() => handleStatusFilter(filter.key)}
              className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${
                currentStatus === filter.key
                  ? 'bg-skyBlue text-white'
                  : 'bg-white text-skyBlue border border-skyBlue hover:bg-skyBlue hover:text-white'
              }`}
            >
              {filter.label}
            </button>
          ))}
        </div>

        {/* Search Bar */}
        <div className="flex items-center gap-2">
          <form onSubmit={handleSearch} className="flex items-center gap-2">
            <div className="relative">
              <input
                type="text"
                placeholder="Search product..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 pr-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-skyBlue focus:border-transparent"
              />
              <FaSearch className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
            </div>
            <button
              type="submit"
              className="px-4 py-2 bg-skyBlue text-white rounded-md hover:bg-skyBlue/90 transition-colors"
            >
              Search
            </button>
          </form>
          
          {(currentStatus !== 'all' || searchTerm) && (
            <button
              onClick={clearFilters}
              className="px-4 py-2 text-gray-600 border border-gray-300 rounded-md hover:bg-gray-50 transition-colors"
            >
              Clear
            </button>
          )}
        </div>
      </div>
    </div>
  );
};

export default CardStatusFilter;
