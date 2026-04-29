"use client";

import { useState, useEffect } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import { getSellerInventoryById, updateSellerInventory } from "@/actions/sellerInventory";
import { toast } from "sonner";
import Image from "next/image";
import { FaUpload, FaTimes } from "react-icons/fa";

const EditInventoryPage = () => {
  const searchParams = useSearchParams();
  const router = useRouter();
  const inventoryId = searchParams.get('id');
  
  const [formData, setFormData] = useState({
    card_title: '',
    description: '',
    price: '',
    price_type: 'FIRM',
    condition: '',
    grade: 'No',
    sport_type: '',
    weight: ''
  });
  
  const [images, setImages] = useState([]);
  const [newImages, setNewImages] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Load inventory data
  useEffect(() => {
    const loadInventoryData = async () => {
      if (!inventoryId) {
        toast.error("No inventory ID provided");
        router.push("/my-cards");
        return;
      }

      try {
        setIsLoading(true);
        const result = await getSellerInventoryById(inventoryId);
        
        if (result.status === "success" && result.data) {
          const data = result.data;
          console.log('Loaded data from API:', data);
          console.log('Grade from API:', data.grade);
          setFormData({
            card_title: data.card_title || '',
            description: data.description || '',
            price: data.price || '',
            price_type: data.price_type || 'FIRM',
            condition: data.condition || '',
            grade: data.grade || 'No',
            sport_type: data.sport_type || '',
            weight: data.weight || ''
          });
          setImages(data.images || []);
        } else {
          toast.error("Failed to load inventory data");
          router.push("/my-cards");
        }
      } catch (error) {
        console.error("Error loading inventory:", error);
        toast.error("Failed to load inventory data");
        router.push("/my-cards");
      } finally {
        setIsLoading(false);
      }
    };

    loadInventoryData();
  }, [inventoryId, router]);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    console.log('Input change:', { name, value });
    if (name === 'grade') {
      console.log('Grade field changed to:', value);
    }
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleImageUpload = (e) => {
    const files = Array.from(e.target.files);
    const currentTotal = images.length + newImages.length;
    const remainingSlots = 6 - currentTotal;
    
    if (files.length > remainingSlots) {
      toast.error(`You can only add ${remainingSlots} more images (max 6 total)`);
      return;
    }
    
    setNewImages(prev => [...prev, ...files]);
  };

  const removeImage = (index) => {
    setImages(prev => prev.filter((_, i) => i !== index));
  };

  const removeNewImage = (index) => {
    setNewImages(prev => prev.filter((_, i) => i !== index));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!formData.card_title.trim()) {
      toast.error("Card title is required");
      return;
    }
    
    if (!formData.price || formData.price <= 0) {
      toast.error("Valid price is required");
      return;
    }

    try {
      setIsSubmitting(true);
      
      // Debug: Log form data before submission
      console.log('Form data before submission:', formData);
      console.log('Grade value:', formData.grade);
      
      // Create FormData for file upload
      const submitData = new FormData();
      submitData.append('card_title', formData.card_title);
      submitData.append('description', formData.description);
      submitData.append('price', formData.price);
      submitData.append('price_type', formData.price_type);
      submitData.append('condition', formData.condition);
      submitData.append('grade', formData.grade || 'No');
      submitData.append('sport_type', formData.sport_type);
      submitData.append('weight', formData.weight);
      submitData.append('_method', 'PUT'); // Laravel method override for FormData
      
      // Debug: Log FormData entries
      console.log('FormData entries:');
      for (let [key, value] of submitData.entries()) {
        console.log(key + ':', value);
      }
      
      // Add new images (only if there are any)
      if (newImages.length > 0) {
        newImages.forEach((file) => {
          submitData.append('images[]', file);
        });
      }

      // Debug: Log what we're sending
      console.log('FormData being sent:', {
        card_title: formData.card_title,
        description: formData.description,
        price: formData.price,
        condition: formData.condition,
        sport_type: formData.sport_type,
        weight: formData.weight,
        newImagesCount: newImages.length
      });

      // Debug: Log FormData contents
      console.log('FormData entries:');
      for (let [key, value] of submitData.entries()) {
        console.log(`${key}:`, value);
      }

      // Check if we have new images to upload
      if (newImages.length > 0) {
        // Use FormData for file uploads
        console.log('Sending FormData with images:', newImages.length);
        const result = await updateSellerInventory(inventoryId, submitData);
        
        if (result.status === "success") {
          toast.success("Card updated successfully!");
          router.push("/my-cards");
        } else {
          console.error("Update failed:", result);
          if (result.errors) {
            Object.values(result.errors).forEach(errorArray => {
              errorArray.forEach(error => {
                toast.error(error);
              });
            });
          } else {
            toast.error(result.message || "Failed to update card");
          }
        }
      } else {
        // Use JSON for text-only updates
        const jsonData = {
          card_title: formData.card_title,
          description: formData.description,
          price: parseFloat(formData.price),
          price_type: formData.price_type,
          condition: formData.condition,
          grade: formData.grade || 'No',
          sport_type: formData.sport_type,
          weight: formData.weight ? parseFloat(formData.weight) : null
        };

        console.log('Sending JSON data (no images):', jsonData);
        const result = await updateSellerInventory(inventoryId, jsonData);
        
        if (result.status === "success") {
          toast.success("Card updated successfully!");
          router.push("/my-cards");
        } else {
          console.error("Update failed:", result);
          if (result.errors) {
            Object.values(result.errors).forEach(errorArray => {
              errorArray.forEach(error => {
                toast.error(error);
              });
            });
          } else {
            toast.error(result.message || "Failed to update card");
          }
        }
      }
    } catch (error) {
      console.error("Error updating inventory:", error);
      toast.error("Failed to update card");
    } finally {
      setIsSubmitting(false);
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-skyBlue mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading inventory data...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto p-6">
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h1 className="text-2xl font-bold text-gray-900 mb-6">Edit Card</h1>
        
        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Card Title */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Card Title *
            </label>
            <input
              type="text"
              name="card_title"
              value={formData.card_title}
              onChange={handleInputChange}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-skyBlue focus:border-transparent h-10"
              required
            />
          </div>

          {/* Description */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Description
            </label>
            <textarea
              name="description"
              value={formData.description}
              onChange={handleInputChange}
              rows={4}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-skyBlue focus:border-transparent"
            />
          </div>

          {/* Price, Price Type, and Condition */}
          <div>
            <div className="flex gap-4 items-end">
              <div className="flex-1">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Price *
                </label>
                <input
                  type="number"
                  name="price"
                  value={formData.price}
                  onChange={handleInputChange}
                  step="0.01"
                  min="0"
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-skyBlue focus:border-transparent h-10"
                  required
                />
              </div>
              <div className="flex-1">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Price is
                </label>
                <select
                  name="price_type"
                  value={formData.price_type}
                  onChange={handleInputChange}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-skyBlue focus:border-transparent h-10"
                >
                  <option value="FIRM">FIRM</option>
                  <option value="OBO">OBO</option>
                </select>
              </div>
              <div className="flex-1">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Condition
                </label>
                <select
                  name="condition"
                  value={formData.condition}
                  onChange={handleInputChange}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-skyBlue focus:border-transparent h-10"
                >
                  <option value="">Select Condition</option>
                  <option value="Mint">Mint</option>
                  <option value="Near Mint">Near Mint</option>
                  <option value="Excellent">Excellent</option>
                  <option value="Very Good">Very Good</option>
                  <option value="Good">Good</option>
                  <option value="Fair">Fair</option>
                  <option value="Poor">Poor</option>
                </select>
              </div>
            </div>
          </div>

          {/* Grade */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Graded
              </label>
              <select
                name="grade"
                value={formData.grade}
                onChange={handleInputChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-skyBlue focus:border-transparent h-10"
              >
                <option value="No">No</option>
                <option value="Yes">Yes</option>
              </select>
            </div>
            <div>
              {/* Empty div for spacing */}
            </div>
          </div>

          {/* Sport Type and Weight */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Card Type
              </label>
              <select
                name="sport_type"
                value={formData.sport_type}
                onChange={handleInputChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-skyBlue focus:border-transparent h-10"
              >
                <option value="">Select Card Type</option>
                <option value="Football">Football</option>
                <option value="Basketball">Basketball</option>
                <option value="Baseball">Baseball</option>
                <option value="Soccer">Soccer</option>
                <option value="Hockey">Hockey</option>
                <option value="Tennis">Tennis</option>
                <option value="Golf">Golf</option>
                <option value="Boxing">Boxing</option>
                <option value="Wrestling">Wrestling</option>
                <option value="Racing">Racing</option>
                <option value="Olympics">Olympics</option>
                <option value="Pokemon">Pokemon</option>
                <option value="One Piece">One Piece</option>
                <option value="Magic">Magic</option>
                <option value="Other">Other</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Weight (grams)
              </label>
              <input
                type="number"
                name="weight"
                value={formData.weight}
                onChange={handleInputChange}
                step="0.1"
                min="0"
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-skyBlue focus:border-transparent h-10"
              />
            </div>
          </div>

          {/* Current Images */}
          {images.length > 0 && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Current Images
              </label>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                {images.map((image, index) => (
                  <div key={index} className="relative">
                    <Image
                      src={`${process.env.NEXT_PUBLIC_IMG_URL}/${image}`}
                      alt={`Current image ${index + 1}`}
                      width={150}
                      height={150}
                      className="w-full h-32 object-cover rounded-md"
                    />
                    <button
                      type="button"
                      onClick={() => removeImage(index)}
                      className="absolute -top-2 -right-2 bg-red-500 text-white rounded-full w-6 h-6 flex items-center justify-center hover:bg-red-600"
                    >
                      <FaTimes className="w-3 h-3" />
                    </button>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* New Images Upload */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Add New Images
            </label>
            <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
              <input
                type="file"
                multiple
                accept="image/*"
                onChange={handleImageUpload}
                className="hidden"
                id="image-upload"
              />
              <label
                htmlFor="image-upload"
                className="cursor-pointer flex flex-col items-center"
              >
                <FaUpload className="w-8 h-8 text-gray-400 mb-2" />
                <span className="text-sm text-gray-600">
                  Click to upload images (max 6 total images)
                </span>
                {images.length > 0 && (
                  <p className="text-xs text-gray-500 mt-1">
                    Current: {images.length} images, can add {6 - images.length} more
                  </p>
                )}
              </label>
            </div>
            
            {/* Preview new images */}
            {newImages.length > 0 && (
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-4">
                {newImages.map((file, index) => (
                  <div key={index} className="relative">
                    <Image
                      src={URL.createObjectURL(file)}
                      alt={`New image ${index + 1}`}
                      width={150}
                      height={150}
                      className="w-full h-32 object-cover rounded-md"
                    />
                    <button
                      type="button"
                      onClick={() => removeNewImage(index)}
                      className="absolute -top-2 -right-2 bg-red-500 text-white rounded-full w-6 h-6 flex items-center justify-center hover:bg-red-600"
                    >
                      <FaTimes className="w-3 h-3" />
                    </button>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Submit Buttons */}
          <div className="flex justify-end space-x-4">
            <button
              type="button"
              onClick={() => router.push("/my-cards")}
              className="px-6 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50 transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmitting}
              className="px-6 py-2 bg-skyBlue text-white rounded-md hover:bg-skyBlue/90 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {isSubmitting ? "Updating..." : "Update Card"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default EditInventoryPage;
