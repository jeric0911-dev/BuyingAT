"use client";

import { useState } from "react";
import Image from "next/image";
import { toast } from "sonner";
import { useForm } from "react-hook-form";
import { createOrUpdateUserProfile } from "@/actions/userProfile";

const ProfileSettingsForm = ({ user }) => {
  const [loading, setLoading] = useState(false);
  const [selectedImage, setSelectedImage] = useState(null);
  const [previewImage, setPreviewImage] = useState(
    user?.profile?.avatar 
      ? `${process.env.NEXT_PUBLIC_IMG_URL}/${user.profile.avatar}`
      : null
  );

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
  } = useForm({
    defaultValues: {
      username: user?.profile?.username || "",
      bio: user?.profile?.bio || "",
      fullName: user?.name || "",
      email: user?.email || "",
    }
  });

  // Validation function for bio field
  const validateBio = (value) => {
    if (!value || value.trim() === '') {
      return true; // Bio is optional in settings
    }
    
    // Check for URLs/links
    const urlRegex = /(https?:\/\/[^\s]+|www\.[^\s]+|[^\s]+\.[a-z]{2,})/gi;
    if (urlRegex.test(value)) {
      return "Bio cannot contain external links or URLs";
    }
    
    // Check for email addresses
    const emailRegex = /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/g;
    if (emailRegex.test(value)) {
      return "Bio cannot contain email addresses";
    }
    
    // Check for phone numbers (various formats)
    const phoneRegex = /(\+?1[-.\s]?)?\(?([0-9]{3})\)?[-.\s]?([0-9]{3})[-.\s]?([0-9]{4})|(\+?[0-9]{1,3}[-.\s]?)?[0-9]{3,4}[-.\s]?[0-9]{3,4}[-.\s]?[0-9]{3,4}/g;
    if (phoneRegex.test(value)) {
      return "Bio cannot contain phone numbers";
    }
    
    // Check for social media handles
    const socialRegex = /@[a-zA-Z0-9_]+|#[a-zA-Z0-9_]+/g;
    if (socialRegex.test(value)) {
      return "Bio cannot contain social media handles (@username or #hashtag)";
    }
    
    // Check for contact info patterns
    const contactRegex = /(contact|call|text|message|reach|find|follow|connect|dm|direct message)/gi;
    if (contactRegex.test(value)) {
      return "Bio cannot contain contact-related terms";
    }
    
    return true; // Valid
  };

  const handleImageChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setSelectedImage(file);
      setPreviewImage(URL.createObjectURL(file));
    }
  };

  const onSubmit = async (data) => {
    setLoading(true);
    const toastId = toast.loading("Updating profile...");

    try {
      const profileData = {
        username: data.username,
        bio: data.bio,
        avatar: selectedImage
      };

      const response = await createOrUpdateUserProfile(profileData);
      
      if (response.status === 'success') {
        toast.success("Profile updated successfully!", { id: toastId });
        // Reset form
        setSelectedImage(null);
        setPreviewImage(
          response.data?.avatar 
            ? `${process.env.NEXT_PUBLIC_IMG_URL}/${response.data.avatar}`
            : null
        );
      } else {
        toast.error(response.message || "Failed to update profile", { id: toastId });
      }
    } catch (error) {
      console.error('Profile update error:', error);
      toast.error("Something went wrong!", { id: toastId });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-8">
      {/* ACCOUNT SETTING Section */}
      <div className="bg-white border border-gray-200 rounded-lg p-6 shadow-sm">
        <h2 className="text-lg font-semibold text-gray-900 mb-6">ACCOUNT SETTING</h2>
        
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
          <div className="flex items-start space-x-6">
            {/* Profile Picture */}
            <div className="relative">
              <div className="w-24 h-24 rounded-full overflow-hidden bg-gray-100 flex items-center justify-center">
                {previewImage ? (
                  <Image
                    src={previewImage}
                    alt="Profile"
                    width={96}
                    height={96}
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <div className="w-12 h-12 bg-gray-600 rounded-full flex items-center justify-center">
                    <span className="text-white font-semibold text-xl">
                      {user?.name?.charAt(0)?.toUpperCase() || "U"}
                    </span>
                  </div>
                )}
              </div>
              <label className="absolute -bottom-1 -right-1 w-8 h-8 bg-green-600 rounded-full flex items-center justify-center cursor-pointer hover:bg-green-700 transition-colors">
                <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleImageChange}
                  className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                />
              </label>
            </div>

            {/* Personal Information */}
            <div className="flex-1 grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Full Name</label>
                <input
                  {...register("fullName", { required: "Full name is required" })}
                  type="text"
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-green-500 focus:border-transparent"
                />
                {errors.fullName && (
                  <p className="text-red-500 text-sm mt-1">{errors.fullName.message}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Email</label>
                <input
                  {...register("email", { 
                    required: "Email is required",
                    pattern: {
                      value: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i,
                      message: "Invalid email address"
                    }
                  })}
                  type="email"
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-green-500 focus:border-transparent"
                />
                {errors.email && (
                  <p className="text-red-500 text-sm mt-1">{errors.email.message}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Username</label>
                <input
                  {...register("username", { 
                    required: "Username is required",
                    minLength: { value: 3, message: "Username must be at least 3 characters" }
                  })}
                  type="text"
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-green-500 focus:border-transparent"
                />
                {errors.username && (
                  <p className="text-red-500 text-sm mt-1">{errors.username.message}</p>
                )}
              </div>


              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-2">Bio</label>
                 <textarea
                   {...register("bio", { 
                     validate: validateBio
                   })}
                   rows={6}
                   className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-green-500 focus:border-transparent min-h-[200px] resize-y"
                   placeholder="Tell us about yourself (text only, no links or contact info)..."
                   style={{ height: '200px' }}
                 />
                {errors.bio && (
                  <p className="text-red-500 text-xs mt-1">{errors.bio.message}</p>
                )}
                <p className="text-xs text-gray-500 mt-1">
                  Bio should contain only text. No external links, email addresses, phone numbers, or contact information allowed.
                </p>
              </div>
            </div>
          </div>

          {/* Save Changes Button */}
          <div className="flex justify-end">
            <button
              type="submit"
              disabled={loading}
              className="px-6 py-3 bg-green-600 text-white rounded-md hover:bg-green-700 disabled:opacity-50 font-semibold"
            >
              {loading ? "Saving..." : "SAVE CHANGES"}
            </button>
          </div>
        </form>
      </div>

    </div>
  );
};

export default ProfileSettingsForm;
