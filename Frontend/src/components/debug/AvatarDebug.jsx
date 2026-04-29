"use client";

import { useEffect } from "react";

const AvatarDebug = ({ user, buyerProfile }) => {
  useEffect(() => {
      console.log('IMAGE URL:', process.env.NEXT_PUBLIC_IMG_URL);
    console.log('🖼️ Client-side Avatar Debug:', {
      user: user,
      buyerProfile: buyerProfile,
      userProfileImg: user?.profile_img,
      buyerProfileAvatar: buyerProfile?.avatar,
      hasUserProfileImg: !!user?.profile_img,
      hasBuyerProfileAvatar: !!buyerProfile?.avatar,
      imageUrl: buyerProfile?.avatar ? `${process.env.NEXT_PUBLIC_IMG_URL}/${buyerProfile.avatar}` : null
    });
  }, [user, buyerProfile]);

  return null; // This component doesn't render anything
};

export default AvatarDebug;
