"use client";

import React, { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import Container from "@/components/shared/Container";
import { getBuyerProfile, updateBuyerProfile } from "@/actions/buyerProfile";
import { toast } from "sonner";

export default function UpdateBuyerProfilePage() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);
  const [isLoadingProfile, setIsLoadingProfile] = useState(true);
  const [formData, setFormData] = useState({
    categories: [],
    tags: [],
    preferences: "",
    budget_min: "",
    budget_max: "",
    profile_link: ""
  });

  // Load existing buyer profile data for editing
  useEffect(() => {
    const loadExistingProfile = async () => {
      try {
        setIsLoadingProfile(true);
        const result = await getBuyerProfile();
        
        if (result.status === "success" && result.data) {
          console.log("📥 Loading existing buyer profile:", result.data);
          
          // Pre-populate form with existing data
          setFormData({
            categories: result.data.categories || [],
            tags: result.data.buyer_tags || [],
            preferences: result.data.preferences || "",
            budget_min: result.data.budget_min || "",
            budget_max: result.data.budget_max || "",
            profile_link: result.data.profile_link || ""
          });
        }
      } catch (error) {
        console.error("❌ Error loading existing profile:", error);
      } finally {
        setIsLoadingProfile(false);
      }
    };

    loadExistingProfile();
  }, []);

  // Debug form data changes
  React.useEffect(() => {
    console.log("📊 Form data updated:", formData);
    console.log("📊 Tags count:", formData.tags.length);
  }, [formData]);

  const [newCategory, setNewCategory] = useState("");
  const [newTag, setNewTag] = useState("");
  const [newTagData, setNewTagData] = useState({
    tag_name: "",
    tag_type: "",
    card_condition: "",
    purchase_volume: "",
    budget_tier: ""
  });

  // Predefined categories for selection
  const availableCategories = [
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

  const handleCategoryAdd = () => {
    if (newCategory.trim() && !formData.categories.includes(newCategory.trim())) {
      setFormData(prev => ({
        ...prev,
        categories: [...prev.categories, newCategory.trim()]
      }));
      setNewCategory("");
    }
  };

  const handleCategoryRemove = (categoryToRemove) => {
    setFormData(prev => ({
      ...prev,
      categories: prev.categories.filter(cat => cat !== categoryToRemove)
    }));
  };

  const handleTagAdd = () => {
    if (newTag.trim() && !formData.tags.includes(newTag.trim())) {
      setFormData(prev => ({
        ...prev,
        tags: [...prev.tags, newTag.trim()]
      }));
      setNewTag("");
    }
  };

  const handleTagRemove = (tagToRemove) => {
    setFormData(prev => ({
      ...prev,
      tags: prev.tags.filter(tag => tag !== tagToRemove)
    }));
  };

  const handleTagDataChange = (field, value) => {
    console.log(`🏷️ Tag field changed: ${field} = ${value}`);
    setNewTagData(prev => {
      const updated = {
        ...prev,
        [field]: value
      };
      console.log("🏷️ Updated newTagData:", updated);
      return updated;
    });
  };

  const handleTagDataAdd = () => {
    console.log("🏷️ handleTagDataAdd function called!");
    console.log("🏷️ Adding tag with data:", newTagData);
    console.log("🏷️ Tag name value:", `"${newTagData.tag_name}"`);
    
    if (newTagData.tag_name.trim()) {
      const tagData = {
        tag_name: newTagData.tag_name.trim(),
        tag_type: newTagData.tag_type,
        card_condition: newTagData.card_condition,
        purchase_volume: newTagData.purchase_volume,
        budget_tier: newTagData.budget_tier
      };
      
      console.log("🏷️ Tag data to add:", tagData);
      
      setFormData(prev => {
        const updated = {
          ...prev,
          tags: [...prev.tags, tagData]
        };
        console.log("🏷️ Updated formData tags:", updated.tags);
        return updated;
      });
      
      // Reset the form
      setNewTagData({
        tag_name: "",
        tag_type: "",
        card_condition: "",
        purchase_volume: "",
        budget_tier: ""
      });
    }
  };

  const handleTagDataRemove = (index) => {
    setFormData(prev => ({
      ...prev,
      tags: prev.tags.filter((_, i) => i !== index)
    }));
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    console.log("🚀 Form submit triggered!");
    setIsLoading(true);

    console.log("Form submission started with data:", formData);
    console.log("Tags data:", formData.tags);
    console.log("Tags count:", formData.tags?.length || 0);
    console.log("Tags detailed:", JSON.stringify(formData.tags, null, 2));

    try {
      // Final check before API call
      console.log("🔍 Final form data check before API call:");
      console.log("🔍 Categories:", formData.categories);
      console.log("🔍 Tags:", formData.tags);
      console.log("🔍 Tags length:", formData.tags.length);
      
      // Ensure tags are properly included
      const tagsToSend = Array.isArray(formData.tags) ? formData.tags : [];
      console.log("🔍 Tags to send:", tagsToSend);
      
      console.log("🔍 Operation type: UPDATE");
      
      const result = await updateBuyerProfile({
        categories: formData.categories,
        tags: tagsToSend,
        preferences: formData.preferences,
        budget_min: formData.budget_min,
        budget_max: formData.budget_max,
        profile_link: formData.profile_link
      });

      console.log("Buyer profile update result:", result);

      if (result.status === "success") {
        toast.success("Buyer profile updated successfully!");
        router.push("/buyer-profile");
      } else {
        toast.error(result.message || "Failed to update buyer profile");
      }
    } catch (error) {
      console.error("Error updating buyer profile:", error);
      toast.error("An error occurred while updating your profile");
    } finally {
      setIsLoading(false);
    }
  };

  const handleCancel = () => {
    router.back();
  };

  // Show loading state while fetching existing profile
  if (isLoadingProfile) {
    return (
      <main className="mt-10">
        <Container>
          <div className="flex items-center justify-center py-12">
            <div className="text-center">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600 mx-auto mb-4"></div>
              <p className="text-gray-600">Loading your buyer profile...</p>
            </div>
          </div>
        </Container>
      </main>
    );
  }

  return (
    <main className="mt-10">
      <Container>
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-gray-900">Edit Buyer Profile</h1>
          <p className="text-gray-600 mt-2">Update your buyer preferences and interests</p>
        </div>

        <div className="max-w-2xl">
          <form onSubmit={handleSubmit} className="space-y-6">
            {/* Categories Section */}
            <div className="bg-white border border-gray-200 rounded-lg p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Categories</h3>
              
              {/* Add Category */}
              <div className="flex gap-2 mb-4">
                <input
                  type="text"
                  value={newCategory}
                  onChange={(e) => setNewCategory(e.target.value)}
                  placeholder="Add a category"
                  className="flex-1 border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
                />
                <button
                  type="button"
                  onClick={handleCategoryAdd}
                  className="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 transition-colors"
                >
                  Add
                </button>
              </div>

              {/* Predefined Categories */}
              <div className="mb-4">
                <p className="text-sm text-gray-600 mb-2">Or select from popular categories:</p>
                <div className="flex flex-wrap gap-2">
                  {availableCategories.map((category) => (
                    <button
                      key={category}
                      type="button"
                      onClick={() => {
                        if (!formData.categories.includes(category)) {
                          setFormData(prev => ({
                            ...prev,
                            categories: [...prev.categories, category]
                          }));
                        }
                      }}
                      disabled={formData.categories.includes(category)}
                      className={`px-3 py-1 text-sm rounded-full border transition-colors ${
                        formData.categories.includes(category)
                          ? "bg-green-100 border-green-300 text-green-700 cursor-not-allowed"
                          : "bg-gray-100 border-gray-300 text-gray-700 hover:bg-gray-200"
                      }`}
                    >
                      {category}
                    </button>
                  ))}
                </div>
              </div>

              {/* Selected Categories */}
              {formData.categories.length > 0 && (
                <div>
                  <p className="text-sm text-gray-600 mb-2">Selected categories:</p>
                  <div className="flex flex-wrap gap-2">
                    {formData.categories.map((category) => (
                      <span
                        key={category}
                        className="inline-flex items-center gap-1 px-3 py-1 bg-green-100 text-green-800 rounded-full text-sm"
                      >
                        {category}
                        <button
                          type="button"
                          onClick={() => handleCategoryRemove(category)}
                          className="ml-1 text-green-600 hover:text-green-800"
                        >
                          ×
                        </button>
                      </span>
                    ))}
                  </div>
                </div>
              )}
            </div>

            {/* Tags Section */}
            <div className="bg-white border border-gray-200 rounded-lg p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">
                Tags 
                <span className="ml-2 text-sm text-gray-500">
                  ({formData.tags.length} tags added)
                </span>
              </h3>
              
              
              {/* Add Tag Form */}
              <div className="space-y-4 mb-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Tag Name *
                      <span className={`ml-2 text-xs ${newTagData.tag_name.trim() ? 'text-green-600' : 'text-red-600'}`}>
                        {newTagData.tag_name.trim() ? '✓ Has content' : '✗ Empty'}
                      </span>
                      <span className="ml-2 text-xs text-gray-500">
                        (Value: &quot;{newTagData.tag_name}&quot;)
                      </span>
                    </label>
                    <input
                      type="text"
                      value={newTagData.tag_name}
                      onChange={(e) => {
                        console.log("📝 Tag name field changed:", e.target.value);
                        handleTagDataChange('tag_name', e.target.value);
                      }}
                      placeholder="e.g., Vintage, Rookie, Autograph"
                      className={`w-full border rounded-md px-3 py-2 focus:outline-none focus:ring-2 ${
                        newTagData.tag_name.trim() 
                          ? 'border-green-300 focus:ring-green-500' 
                          : 'border-gray-300 focus:ring-green-500'
                      }`}
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Tag Type
                    </label>
                    <select
                      value={newTagData.tag_type}
                      onChange={(e) => handleTagDataChange('tag_type', e.target.value)}
                      className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
                    >
                      <option value="">Select Type</option>
                      <option value="condition">Condition</option>
                      <option value="rarity">Rarity</option>
                      <option value="era">Era</option>
                      <option value="player">Player</option>
                      <option value="team">Team</option>
                      <option value="sport">Sport</option>
                    </select>
                  </div>
                </div>
                
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Card Condition
                    </label>
                    <select
                      value={newTagData.card_condition}
                      onChange={(e) => handleTagDataChange('card_condition', e.target.value)}
                      className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
                    >
                      <option value="">Select Grade</option>
                      <option value="PSA 10">PSA 10</option>
                      <option value="PSA 9">PSA 9</option>
                      <option value="PSA 8">PSA 8</option>
                      <option value="PSA 7">PSA 7</option>
                      <option value="BGS 10">BGS 10</option>
                      <option value="BGS 9.5">BGS 9.5</option>
                      <option value="BGS 9">BGS 9</option>
                      <option value="Raw">Raw</option>
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Purchase Volume
                    </label>
                    <input
                      type="number"
                      value={newTagData.purchase_volume}
                      onChange={(e) => handleTagDataChange('purchase_volume', e.target.value)}
                      placeholder="e.g., 10"
                      min="0"
                      className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Budget Tier
                    </label>
                    <select
                      value={newTagData.budget_tier}
                      onChange={(e) => handleTagDataChange('budget_tier', e.target.value)}
                      className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
                    >
                      <option value="">Select Tier</option>
                      <option value="low">Low ($0-$100)</option>
                      <option value="medium">Medium ($100-$500)</option>
                      <option value="high">High ($500-$1000)</option>
                      <option value="premium">Premium ($1000+)</option>
                    </select>
                  </div>
                </div>
                
                <div className="flex justify-end gap-2">
                  <button
                    type="button"
                    onClick={() => {
                      console.log("🔘 Add Tag button clicked!");
                      console.log("🔘 Current newTagData:", newTagData);
                      console.log("🔘 Tag name field value:", newTagData.tag_name);
                      console.log("🔘 Tag name length:", newTagData.tag_name.length);
                      handleTagDataAdd();
                    }}
                    className="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 transition-colors"
                  >
                    Add Tag
                  </button>
                </div>
              </div>

              {/* Selected Tags */}
              {formData.tags.length > 0 && (
                <div>
                  <p className="text-sm text-gray-600 mb-3">Selected tags:</p>
                  <div className="space-y-3">
                    {formData.tags.map((tag, index) => (
                      <div
                        key={index}
                        className="flex items-center justify-between p-3 bg-green-50 border border-green-200 rounded-lg"
                      >
                        <div className="flex-1">
                          <div className="flex items-center gap-4 text-sm">
                            <span className="font-medium text-green-800">{tag.tag_name}</span>
                            {tag.tag_type && (
                              <span className="px-2 py-1 bg-green-100 text-green-700 rounded text-xs">
                                {tag.tag_type}
                              </span>
                            )}
                            {tag.card_condition && (
                              <span className="px-2 py-1 bg-green-100 text-green-700 rounded text-xs">
                                {tag.card_condition}
                              </span>
                            )}
                            {tag.purchase_volume && (
                              <span className="px-2 py-1 bg-purple-100 text-purple-700 rounded text-xs">
                                Vol: {tag.purchase_volume}
                              </span>
                            )}
                            {tag.budget_tier && (
                              <span className="px-2 py-1 bg-orange-100 text-orange-700 rounded text-xs">
                                {tag.budget_tier}
                              </span>
                            )}
                          </div>
                        </div>
                        <button
                          type="button"
                          onClick={() => handleTagDataRemove(index)}
                          className="ml-2 text-red-600 hover:text-red-800 text-lg font-bold"
                        >
                          ×
                        </button>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>

            {/* Preferences Section */}
            <div className="bg-white border border-gray-200 rounded-lg p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Preferences</h3>
              <textarea
                name="preferences"
                value={formData.preferences}
                onChange={handleInputChange}
                placeholder="Tell us about your collecting preferences, favorite players, teams, or any specific interests..."
                rows={4}
                className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
              />
            </div>

            {/* Budget Section */}
            <div className="bg-white border border-gray-200 rounded-lg p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Budget Range</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Minimum Budget ($)
                  </label>
                  <input
                    type="number"
                    name="budget_min"
                    value={formData.budget_min}
                    onChange={handleInputChange}
                    placeholder="0"
                    min="0"
                    className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Maximum Budget ($)
                  </label>
                  <input
                    type="number"
                    name="budget_max"
                    value={formData.budget_max}
                    onChange={handleInputChange}
                    placeholder="10000"
                    min="0"
                    className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>
              </div>
            </div>

            {/* Profile Link Section */}
            <div className="bg-white border border-gray-200 rounded-lg p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Profile Link</h3>
              <input
                type="url"
                name="profile_link"
                value={formData.profile_link}
                onChange={handleInputChange}
                placeholder="https://your-profile-link.com (optional)"
                className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
              />
              <p className="text-sm text-gray-500 mt-1">
                Optional: Link to your social media, website, or other profile
              </p>
            </div>

            {/* Action Buttons */}
            <div className="flex gap-4 pt-6">
              <button
                type="button"
                onClick={handleCancel}
                className="flex-1 px-6 py-3 border border-gray-300 text-gray-700 rounded-md hover:bg-gray-50 transition-colors"
                disabled={isLoading}
              >
                Cancel
              </button>
              <button
                type="submit"
                disabled={isLoading}
                className="flex-1 px-6 py-3 bg-green-600 text-white rounded-md hover:bg-green-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {isLoading ? "Updating..." : "Update Profile"}
              </button>
            </div>
          </form>
        </div>
      </Container>
    </main>
  );
}
