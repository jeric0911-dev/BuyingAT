"use client";

import { useState } from "react";
import { useForm } from "react-hook-form";
import { toast } from "sonner";
import Image from "next/image";
import { useTransitionRouter } from "next-view-transitions";
import { createSellerInventory } from "@/actions/sellerInventory";

const AddCardForm = () => {
  const [loading, setLoading] = useState(false);
  const [selectedImages, setSelectedImages] = useState([]);
  const router = useTransitionRouter();

  const handleImageChange = (e) => {
    const newImages = [...selectedImages, ...e.target.files];
    setSelectedImages(newImages.slice(0, 6));
  };

  const handleDeleteImage = (index) => {
    const updatedImages = selectedImages.filter((_, i) => i !== index);
    setSelectedImages(updatedImages);
  };

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm({
    mode: 'onChange',
    defaultValues: {
      card_title: "",
      description: "",
      price: "",
      price_type: "FIRM",
      condition: "",
      grade: "No",
      sport_type: "",
      weight: "",
    },
  });

  const onSubmit = async (data) => {
    setLoading(true);
    try {
      console.log("Card data:", data);
      console.log("Images:", selectedImages);
      
      // Create FormData for file uploads
      const formData = new FormData();
      formData.append('card_title', data.card_title);
      formData.append('description', data.description);
      formData.append('price', parseFloat(data.price));
      formData.append('price_type', data.price_type);
      formData.append('condition', data.condition);
      formData.append('grade', data.grade || 'No');
      formData.append('sport_type', data.sport_type);
      if (data.weight) {
        formData.append('weight', parseFloat(data.weight));
      }
      
      // Append images to FormData
      selectedImages.forEach((image, index) => {
        formData.append(`images[${index}]`, image);
      });

      console.log("Sending to API:", formData);

      const result = await createSellerInventory(formData);

      if (result.status === "success") {
        toast.success("Card added successfully!");
        router.push("/my-cards");
      } else {
        toast.error(result.message || "Failed to add card. Please try again.");
        console.error("API Error:", result);
      }
    } catch (error) {
      console.error("Form submission error:", error);
      toast.error("Failed to add card. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  const sportTypes = [
    "Football",
    "Basketball",
    "Baseball",
    "Soccer",
    "Hockey",
    "Tennis",
    "Golf",
    "Boxing",
    "Wrestling",
    "Racing",
    "Olympics",
    "Pokemon",
    "One Piece",
    "Magic",
    "Other"
  ];

  const conditions = [
    "Mint",
    "Near Mint",
    "Excellent",
    "Very Good",
    "Good",
    "Fair",
    "Poor"
  ];

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
      {/* Card Title */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Card Title *
        </label>
        <input
          {...register("card_title", { required: "Card title is required" })}
          type="text"
          placeholder="Enter card title"
          className="w-full px-4 py-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-green-500 focus:border-transparent"
        />
        {errors.card_title && (
          <p className="text-red-500 text-sm mt-1">{errors.card_title.message}</p>
        )}
      </div>

      {/* Description */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Description
        </label>
        <textarea
          {...register("description")}
          rows={4}
          placeholder="Enter card description (optional)"
          className="w-full px-4 py-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-green-500 focus:border-transparent"
        />
        {errors.description && (
          <p className="text-red-500 text-sm mt-1">{errors.description.message}</p>
        )}
      </div>

      {/* Price, Price Type, Condition and Grade Row */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        {/* Price */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Price *
          </label>
          <input
            {...register("price", { 
              required: "Price is required",
              pattern: {
                value: /^\d+(\.\d{1,2})?$/,
                message: "Please enter a valid price"
              }
            })}
            type="number"
            step="0.01"
            placeholder="0.00"
            className="w-full px-4 py-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-green-500 focus:border-transparent"
          />
          {errors.price && (
            <p className="text-red-500 text-sm mt-1">{errors.price.message}</p>
          )}
        </div>

        {/* Price Type */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Price is *
          </label>
          <select
            {...register("price_type")}
            className="w-full px-4 py-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-green-500 focus:border-transparent"
          >
            <option value="FIRM">FIRM</option>
            <option value="OBO">OBO</option>
          </select>
        </div>

        {/* Condition */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Condition *
          </label>
          <select
            {...register("condition", { required: "Condition is required" })}
            className="w-full px-4 py-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-green-500 focus:border-transparent"
          >
            <option value="">Select Condition</option>
            {conditions.map((condition) => (
              <option key={condition} value={condition}>
                {condition}
              </option>
            ))}
          </select>
          {errors.condition && (
            <p className="text-red-500 text-sm mt-1">{errors.condition.message}</p>
          )}
        </div>

        {/* Grade */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Graded
          </label>
          <select
            {...register("grade")}
            className="w-full px-4 py-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-green-500 focus:border-transparent"
          >
            <option value="No">No</option>
            <option value="Yes">Yes</option>
          </select>
          {errors.grade && (
            <p className="text-red-500 text-sm mt-1">{errors.grade.message}</p>
          )}
        </div>
      </div>

      {/* Sport Type and Weight Row */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Sport Type */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Card Type *
          </label>
          <select
            {...register("sport_type", { required: "Card type is required" })}
            className="w-full px-4 py-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-green-500 focus:border-transparent"
          >
            <option value="">Select Card Type</option>
            {sportTypes.map((sport) => (
              <option key={sport} value={sport}>
                {sport}
              </option>
            ))}
          </select>
          {errors.sport_type && (
            <p className="text-red-500 text-sm mt-1">{errors.sport_type.message}</p>
          )}
        </div>

        {/* Weight */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Weight (grams)
          </label>
          <input
            {...register("weight")}
            type="number"
            step="0.1"
            placeholder="0.0"
            className="w-full px-4 py-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-green-500 focus:border-transparent"
          />
        </div>
      </div>

      {/* Images */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Card Images (Max. 6) *
        </label>
        <div className="border-2 border-dashed border-gray-300 rounded-lg p-6">
          <input
            type="file"
            multiple
            accept="image/*"
            onChange={handleImageChange}
            className="hidden"
            id="card-images"
          />
          <label
            htmlFor="card-images"
            className="cursor-pointer flex flex-col items-center justify-center space-y-2"
          >
            <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center">
              <svg className="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
              </svg>
            </div>
            <p className="text-sm text-gray-600">Click to upload images</p>
            <p className="text-xs text-gray-500">PNG, JPG, GIF up to 10MB each</p>
          </label>
        </div>

        {/* Display selected images */}
        {selectedImages.length > 0 && (
          <div className="mt-4 grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
            {selectedImages.map((image, index) => (
              <div key={index} className="relative">
                <Image
                  src={URL.createObjectURL(image)}
                  alt={`Card image ${index + 1}`}
                  width={100}
                  height={100}
                  className="w-full h-24 object-cover rounded-md"
                />
                <button
                  type="button"
                  onClick={() => handleDeleteImage(index)}
                  className="absolute -top-2 -right-2 bg-red-500 text-white rounded-full w-6 h-6 flex items-center justify-center text-sm hover:bg-red-600"
                >
                  ×
                </button>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Submit Button */}
      <div className="flex justify-end space-x-4">
        <button
          type="button"
          onClick={() => router.back()}
          className="px-6 py-3 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50"
        >
          Cancel
        </button>
        <button
          type="submit"
          disabled={loading}
          className="px-6 py-3 bg-green-600 text-white rounded-md hover:bg-green-700 disabled:opacity-50"
        >
          {loading ? "Adding Card..." : "Add Card"}
        </button>
      </div>
    </form>
  );
};

export default AddCardForm;
