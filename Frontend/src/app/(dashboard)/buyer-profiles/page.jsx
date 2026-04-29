"use client";

import { getAllBuyerProfiles } from "@/actions/buyerProfile";
import { FaUserCircle } from "react-icons/fa";
import BuyerProfileCard from "@/components/buyer-profiles/BuyerProfileCard";
import { useState, useEffect } from "react";

const BuyerProfilesPage = () => {
  const [buyerProfiles, setBuyerProfiles] = useState([]);
  const [filteredProfiles, setFilteredProfiles] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("All Categories");
  const [isLoading, setIsLoading] = useState(true);

  // Available categories for filtering
  const availableCategories = [
    "All Categories",
    "Sports Cards",
    "Trading Cards",
    "Collectible Cards",
    "Baseball Cards",
    "Football Cards",
    "Basketball Cards",
    "Hockey Cards",
    "Soccer Cards",
    "Rookie Cards",
    "Vintage Cards",
    "Modern Cards",
    "Autographed Cards",
    "Graded Cards"
  ];

  // Load buyer profiles on component mount
  useEffect(() => {
    const loadBuyerProfiles = async () => {
      try {
        setIsLoading(true);
        const result = await getAllBuyerProfiles();
        if (result.status === "success") {
          setBuyerProfiles(result.data || []);
          setFilteredProfiles(result.data || []);
        } else {
          console.error("Failed to load buyer profiles:", result.message);
          setBuyerProfiles([]);
          setFilteredProfiles([]);
        }
      } catch (error) {
        console.error("Error loading buyer profiles:", error);
        setBuyerProfiles([]);
        setFilteredProfiles([]);
      } finally {
        setIsLoading(false);
      }
    };

    loadBuyerProfiles();
  }, []);

  // Filter profiles based on search term and category
  useEffect(() => {
    let filtered = buyerProfiles;

    // Filter by search term
    if (searchTerm.trim()) {
      filtered = filtered.filter(profile => {
        const userName = profile.user?.profile?.username || profile.user?.name || "";
        const userEmail = profile.user?.email || "";
        const categories = profile.categories || [];
        const tags = profile.buyer_tags || [];
        
        const searchLower = searchTerm.toLowerCase();
        
        return (
          userName.toLowerCase().includes(searchLower) ||
          userEmail.toLowerCase().includes(searchLower) ||
          categories.some(cat => cat.toLowerCase().includes(searchLower)) ||
          tags.some(tag => tag.tag_name?.toLowerCase().includes(searchLower))
        );
      });
    }

    // Filter by category
    if (selectedCategory !== "All Categories") {
      filtered = filtered.filter(profile => {
        const categories = profile.categories || [];
        return categories.includes(selectedCategory);
      });
    }

    setFilteredProfiles(filtered);
  }, [buyerProfiles, searchTerm, selectedCategory]);

  const handleSearch = () => {
    // The filtering is already handled by useEffect
    // This function can be used for additional search logic if needed
  };

  const handleClearFilters = () => {
    setSearchTerm("");
    setSelectedCategory("All Categories");
  };

  if (isLoading) {
    return (
      <div className="py-8">
        <div className="flex items-center justify-center h-64">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600 mx-auto mb-4"></div>
            <p className="text-gray-600">Loading buyer profiles...</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="py-8">
      <h1 className="text-2xl font-bold text-gray-900 mb-6">Buyer Profiles</h1>
      <p className="text-gray-600 mb-8">
        Browse through buyer profiles to find potential customers for your products.
      </p>
      
      {/* Search and Filter Section */}
      <div className="mb-8 bg-gray-50 p-6 rounded-lg">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Find Buyers</h2>
        <div className="flex flex-col md:flex-row gap-4">
          <input
            type="text"
            placeholder="Search by name, email, or interests..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="flex-1 px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-green-500 focus:border-transparent"
          />
          <select 
            value={selectedCategory}
            onChange={(e) => setSelectedCategory(e.target.value)}
            className="px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-green-500 focus:border-transparent"
          >
            {availableCategories.map((category) => (
              <option key={category} value={category}>
                {category}
              </option>
            ))}
          </select>
          <button 
            onClick={handleSearch}
            className="bg-skyBlue text-white px-6 py-2 rounded-md hover:bg-skyBlueHover transition-colors"
          >
            Search
          </button>
          <button 
            onClick={handleClearFilters}
            className="px-6 py-2 rounded-md border-2 border-gray-400 text-gray-700 bg-white hover:bg-gray-100 transition-colors"
          >
            Clear
          </button>
        </div>
        
        {/* Results count */}
        <div className="mt-4 text-sm text-gray-600">
          {filteredProfiles.length === buyerProfiles.length ? (
            `Showing all ${buyerProfiles.length} buyer profiles`
          ) : (
            `Showing ${filteredProfiles.length} of ${buyerProfiles.length} buyer profiles`
          )}
        </div>
      </div>
      
      {/* Buyer Profiles Grid */}
      {filteredProfiles.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredProfiles.map((profile) => (
            <BuyerProfileCard key={profile.id} profile={profile} />
          ))}
        </div>
      ) : (
        <div className="text-center py-12">
          <FaUserCircle className="mx-auto text-6xl text-gray-300 mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">
            {buyerProfiles.length === 0 ? "No Buyer Profiles Found" : "No Matching Profiles"}
          </h3>
          <p className="text-gray-500">
            {buyerProfiles.length === 0 
              ? "There are no buyer profiles available at the moment."
              : "Try adjusting your search criteria or filters."
            }
          </p>
          {buyerProfiles.length > 0 && (
            <button 
              onClick={handleClearFilters}
              className="mt-4 bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700 transition-colors"
            >
              Clear Filters
            </button>
          )}
        </div>
      )}
    </div>
  );
};

export default BuyerProfilesPage;
