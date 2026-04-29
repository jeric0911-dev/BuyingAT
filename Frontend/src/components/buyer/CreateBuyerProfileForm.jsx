"use client";

import { useState } from "react";
import Image from "next/image";
import { useTransitionRouter } from "next-view-transitions";
import { useForm } from "react-hook-form";
import { toast } from "sonner";
import { createOrUpdateUserProfile } from "@/actions/userProfile";
import { success } from "@/constants";

const CreateBuyerProfile = () => {
  const [loading, setLoading] = useState(false);
  const [avatarPreview, setAvatarPreview] = useState(null);
  const router = useTransitionRouter();
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm();

  // Handle avatar preview
  const handleAvatarChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        setAvatarPreview(e.target.result);
      };
      reader.readAsDataURL(file);
    }
  };

  // Generate auto username with format BA####
  const generateUsername = () => {
    // Generate 4-digit random number
    const randomNumber = Math.floor(Math.random() * 9000) + 1000;
    
    // Create username: BA + 4 random digits
    return `BA${randomNumber}`;
  };

  // Validation function for bio field
  const validateBio = (value) => {
    if (!value || value.trim() === '') {
      return "Bio is required";
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

  const onSubmit = async (values) => {
    const autoUsername = generateUsername();
    
    console.log('🔄 CreateBuyerProfile: Starting profile creation', {
      timestamp: new Date().toISOString(),
      form_values: {
        username: autoUsername,
        bio: values.bio,
        has_avatar: !!(values.avatar && values.avatar[0]),
        avatar_name: values.avatar?.[0]?.name,
        avatar_size: values.avatar?.[0]?.size
      }
    });

    setLoading(true);
    const toastId = toast.loading("Creating buyer profile...");
    
    try {
      const profileData = {
        username: autoUsername,
        bio: values.bio,
        avatar: values.avatar && values.avatar[0] ? values.avatar[0] : null
      };

      console.log('📤 CreateBuyerProfile: Calling createOrUpdateUserProfile with data:', {
        username: profileData.username,
        bio: profileData.bio,
        has_avatar: !!profileData.avatar,
        avatar_details: profileData.avatar ? {
          name: profileData.avatar.name,
          size: profileData.avatar.size,
          type: profileData.avatar.type
        } : null
      });

      const res = await createOrUpdateUserProfile(profileData);
      
      console.log('📥 CreateBuyerProfile: API response received:', {
        status: res.status,
        message: res.message,
        has_data: !!res.data,
        data_keys: res.data ? Object.keys(res.data) : null
      });
      
      setLoading(false);
      
      if (res.status === 'success') {
        console.log('✅ CreateBuyerProfile: Profile created successfully', {
          profile_id: res.data?.id,
          username: res.data?.username,
          has_avatar: !!res.data?.avatar
        });
        
        toast.success("Buyer profile created successfully!", { id: toastId });
        router.push("/profile");
      } else {
        console.log('❌ CreateBuyerProfile: Profile creation failed:', {
          status: res.status,
          message: res.message,
          errors: res.errors
        });
        
        toast.error(res.message || "Something went wrong!", { id: toastId });
      }
    } catch (error) {
      console.error('💥 CreateBuyerProfile: Error occurred:', {
        error: error.message,
        stack: error.stack,
        timestamp: new Date().toISOString()
      });
      
      setLoading(false);
      toast.error("Something went wrong!", { id: toastId });
    }
  };

  return (
    <form
      onSubmit={(e) => {
        console.log('🚀 CreateBuyerProfile: Form submission triggered');
        handleSubmit(onSubmit)(e);
      }}
      className="w-full max-w-[424px] border border-border rounded shadow-[0_8px_40px_0px_rgba(0,0,0,0.12)] p-8 pt-0 mt-4"
    >
      <div className="flex border-b -mx-8">
        <div className="w-full py-4 text-xl text-center font-semibold border-b-2 border-skyBlue">
          Create Buyer Profile
        </div>
      </div>

      <div>
        {/* --------------------avatarField----------------- */}
        <div className="flex flex-col items-center mt-6">
          <label className="text-sm mb-4">Avatar</label>
          <div className="relative">
            <div className="w-24 h-24 rounded-full border-2 border-skyBlue overflow-hidden bg-gray-100 flex items-center justify-center">
              {avatarPreview ? (
                <Image
                  src={avatarPreview}
                  alt="Avatar preview"
                  width={96}
                  height={96}
                  className="w-full h-full object-cover"
                />
              ) : (
                <div className="w-12 h-12 bg-gray-300 rounded-full flex items-center justify-center">
                  <svg className="w-6 h-6 text-gray-500" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clipRule="evenodd" />
                  </svg>
                </div>
              )}
            </div>
            {/* Camera icon overlay */}
            <div className="absolute -bottom-1 -right-1 w-8 h-8 bg-skyBlue rounded-full flex items-center justify-center cursor-pointer hover:bg-green-600 transition-colors">
              <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
            </div>
            <input
              {...register("avatar")}
              type="file"
              accept="image/*"
              onChange={handleAvatarChange}
              className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
            />
          </div>
        </div>

        {/* --------------------bioField----------------- */}
        <label className="block mt-4 text-sm">
          Bio
          <textarea
            {...register("bio", { 
              validate: validateBio
            })}
            className="mt-2 input-input min-h-[150px] resize-y"
            placeholder="Please tell us the type of cards you are looking for (text only, no links or contact info)"
            rows="8"
            style={{ height: '150px' }}
          />
          {errors.bio && (
            <p className="text-red-500 text-xs mt-1">{errors.bio.message}</p>
          )}
          <p className="text-xs text-gray-500 mt-1">
            Bio should contain only text. No external links, email addresses, phone numbers, or contact information allowed.
          </p>
        </label>

        {/* --------------------submitButton----------------- */}
        <button
          type="submit"
          onClick={() => console.log('🔘 CreateBuyerProfile: Submit button clicked')}
          style={{ "--hover-bg": `black`, "--hover-txt": "white" }}
          className="btn-hover-effect bg-skyBlue text-white text-sm font-bold py-3 w-full rounded-sm flex items-center justify-center gap-2 mt-6 disabled:cursor-not-allowed"
          disabled={loading}
        >
          <span>CREATE PROFILE</span>
          <Image
            src="/icon/right-arrow-white.svg"
            alt="#"
            width={20}
            height={20}
          />
        </button>

        {/* --------------------skipButton----------------- */}
        <button
          type="button"
          onClick={() => router.push("/profile")}
          className="w-full h-11 border border-border rounded-sm px-4 py-3 text-sm flex items-center justify-center mt-3 text-tGray hover:bg-gray-50 transition-colors duration-200"
        >
          Skip for now
        </button>
      </div>
    </form>
  );
};

export default CreateBuyerProfile;
