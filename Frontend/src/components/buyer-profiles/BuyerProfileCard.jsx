"use client";

import Image from "next/image";
import { FaUserCircle } from "react-icons/fa";
import { useRouter } from "next/navigation";
import { createBuyerProfileConversation } from "@/actions/others";
import { getUser } from "@/actions/auth";
import { toast } from "sonner";
import { useState, useEffect } from "react";
import { getUserPackageStatus } from "@/actions/package";
console.log('IMAGE URL:', process.env.NEXT_PUBLIC_IMG_URL);
const BuyerProfileCard = ({ profile }) => {
  const router = useRouter();
  const [isContacting, setIsContacting] = useState(false);
  const [currentUser, setCurrentUser] = useState(null);
  const user = profile.user;
  const initials = user?.name ? user.name.split(' ').map(n => n[0]).join('').toUpperCase() : 'U';
  const avatarUrl = profile.user?.profile?.avatar 
    ? `${process.env.NEXT_PUBLIC_IMG_URL}/${profile.user.profile.avatar}`
    : null;
  const [isMember, setIsMember] = useState(false);

  // Load current user on component mount
  useEffect(() => {
    const loadCurrentUser = async () => {
      try {
        const { data: user } = await getUser();
        setCurrentUser(user);
      } catch (error) {
        console.error('Error loading current user:', error);
      }
    };
    loadCurrentUser();
  }, []);

  // Load membership status for this card's user
  useEffect(() => {
    const loadStatus = async () => {
      try {
        if (!user?.id) return;
        const res = await getUserPackageStatus(user.id);
        setIsMember(!!res?.data?.active);
      } catch (_) {}
    };
    loadStatus();
  }, [user?.id]);

  // Check if this is the current user's own profile
  const isOwnProfile = currentUser && user && currentUser.id === user.id;

  const handleViewProfile = () => {
    window.open(`/buyer-profile/${profile.id}`, '_blank');
  };

  const handleContact = async () => {
    // Don't allow contacting yourself
    if (isOwnProfile) {
      toast.error("You cannot contact yourself");
      return;
    }

    try {
      setIsContacting(true);
      
      if (!currentUser) {
        toast.error("Please login to contact buyers");
        router.push("/login");
        return;
      }
      
      const conversationData = {
        sender_id: currentUser.id,
        receiver_id: user.id,
        buyer_profile_id: profile.id
      };
      
      const result = await createBuyerProfileConversation(conversationData);
      
      if (result.status === 'success') {
        toast.success("Starting conversation...");
        // Redirect to chat interface
        router.push(`/chat/${result.data.id}`);
      } else {
        toast.error(result.message || "Failed to start conversation");
        console.error('Conversation creation failed:', result);
      }
    } catch (error) {
      console.error('Contact error:', error);
      toast.error("Something went wrong!");
    } finally {
      setIsContacting(false);
    }
  };

  return (
    <div className="bg-white border border-gray-200 rounded-lg p-6 shadow-sm">
      <div className="flex items-center space-x-4">
        <div className="relative">
          {avatarUrl ? (
            <Image
              src={avatarUrl}
              alt={profile.username || user?.name || "Buyer"}
              width={48}
              height={48}
              className="w-12 h-12 rounded-full object-cover"
            />
          ) : (
            <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center">
              <span className="text-green-600 font-semibold">{initials}</span>
            </div>
          )}
          {isMember && (
            <span className="absolute -bottom-1 -right-1 text-[9px] px-1 py-0.5 rounded-full bg-emerald-600 text-white ring-2 ring-white">MEMBER</span>
          )}
        </div>
        <div>
          <h3 className="font-semibold text-gray-900">
            {user?.profile?.username || user?.name || "Buyer"}
          </h3>
          <p className="text-sm text-gray-500">Buyer</p>
        </div>
      </div>
      <div className="mt-4">
        {/* Categories */}
        {profile.categories && profile.categories.length > 0 && (
          <div className="mb-3">
            <p className="text-xs text-gray-500 mb-1">Interested in:</p>
            <div className="flex flex-wrap gap-1">
              {profile.categories.slice(0, 3).map((category, index) => (
                <span key={index} className="px-2 py-1 bg-green-100 text-green-700 text-xs rounded">
                  {category}
                </span>
              ))}
              {profile.categories.length > 3 && (
                <span className="px-2 py-1 bg-gray-100 text-gray-600 text-xs rounded">
                  +{profile.categories.length - 3} more
                </span>
              )}
            </div>
          </div>
        )}

        {/* Budget Range */}
        {(profile.budget_min || profile.budget_max) && (
          <div className="mb-3">
            <p className="text-xs text-gray-500 mb-1">Budget Range:</p>
            <p className="text-sm text-gray-600">
              ${profile.budget_min || 0} - ${profile.budget_max || "No limit"}
            </p>
          </div>
        )}

        {/* Tags */}
        {profile.buyer_tags && profile.buyer_tags.length > 0 && (
          <div className="mb-3">
            <p className="text-xs text-gray-500 mb-1">Tags:</p>
            <div className="flex flex-wrap gap-1">
              {profile.buyer_tags.slice(0, 2).map((tag, index) => (
                <span key={index} className="px-2 py-1 bg-green-100 text-green-700 text-xs rounded">
                  {tag.tag_name}
                </span>
              ))}
              {profile.buyer_tags.length > 2 && (
                <span className="px-2 py-1 bg-gray-100 text-gray-600 text-xs rounded">
                  +{profile.buyer_tags.length - 2} more
                </span>
              )}
            </div>
          </div>
        )}

        <div className="flex gap-2 mt-3">
          <button 
            onClick={handleViewProfile}
            className="flex-1 bg-skyBlue text-white px-4 py-2 rounded-md text-sm hover:bg-skyBlueHover transition-colors"
          >
            View Profile
          </button>
          <button 
            onClick={handleContact}
            disabled={isContacting || isOwnProfile}
            style={isOwnProfile ? {
              backgroundColor: '#E6F7EC',
              color: '#2A8F47',
              borderColor: '#BFE8CB'
            } : {
              backgroundColor: '#0EA5E9',
              color: '#FFFFFF',
              borderColor: '#0EA5E9'
            }}
            className={`flex-1 px-4 py-2 rounded-md text-sm transition-colors border ${
              isOwnProfile 
                ? 'cursor-not-allowed' 
                : 'disabled:opacity-50 disabled:cursor-not-allowed'
            }`}
            title={isOwnProfile ? "You cannot contact yourself" : ""}
          >
            {isContacting ? "Starting..." : isOwnProfile ? "Your Profile" : "Contact"}
          </button>
        </div>
      </div>
    </div>
  );
};

export default BuyerProfileCard;
