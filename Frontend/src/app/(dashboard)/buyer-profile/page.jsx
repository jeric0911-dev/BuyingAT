import { getUser } from "@/actions/auth";
import { getBuyerProfile } from "@/actions/buyerProfile";
import { getUserProfileServer } from "@/actions/userProfileServer";
import UserProfileCard from "@/components/profile/UserProfileCard";
import Container from "@/components/shared/Container";
import { Link } from "next-view-transitions";
import { FaUserCircle } from "react-icons/fa";
import Image from "next/image";
import AvatarDebug from "@/components/debug/AvatarDebug";

export const metadata = {
  title: "Buyer Profile",
  description: "View and manage your buyer profile",
  robots: { index: false },
};

const BuyerProfilePage = async () => {
  const [
    { data: user },
    buyerProfileResult,
    userProfileResult,
  ] = await Promise.all([
    getUser(),
    getBuyerProfile(),
    getUserProfileServer(),
  ]);

  // Handle buyer profile data
  const buyerProfile = buyerProfileResult.status === "success" ? buyerProfileResult.data : null;
  
  // Handle user profile data
  const userProfile = userProfileResult.status === "success" ? userProfileResult.data : null;
  
  // Merge user profile data with user data (same as seller page)
  const userWithProfile = {
    ...user,
    profile: userProfile || null
  };


  // Debug the data structure
  console.log('🔍 BuyerProfilePage Data Debug:', {
    user: user,
    buyerProfile: buyerProfile,
    userProfile: userProfile,
    userWithProfile: userWithProfile,
    profileInUserWithProfile: userWithProfile.profile
  });

  // Debug logging
  console.log('🔍 BuyerProfilePage Debug:', {
    user: user,
    buyerProfile: buyerProfile,
    userProfile: userProfile,
    hasBuyerProfile: !!buyerProfile,
    hasUserProfile: !!userProfile,
    shouldShowCreateButton: (!buyerProfile)
  });

  console.log('IMAGE URL:', process.env.NEXT_PUBLIC_IMG_URL);

  // Debug avatar specifically
  console.log('🖼️ Avatar Debug:', {
    userProfileAvatar: userProfile?.avatar,
    hasUserProfileAvatar: !!userProfile?.avatar,
    imageUrl: userProfile?.avatar ? `${process.env.NEXT_PUBLIC_IMG_URL}/${userProfile.avatar}` : null
  });

  return (
    <main className="mt-10">
      <AvatarDebug user={user} buyerProfile={buyerProfile} />
      <Container>
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-gray-900">Buyer Profile</h1>
          <p className="text-gray-600 mt-2">Manage your buyer profile and preferences</p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* User Profile Card - Show basic user info when no buyer profile exists */}
          <div className="lg:col-span-2">
            <div className="bg-white border border-gray-200 rounded-lg p-6 shadow-sm flex flex-col h-full">
              <div className="mb-4">
                <h3 className="text-lg font-semibold text-gray-900">USER PROFILE</h3>
                <hr />
              </div>
              <div className="flex flex-col h-full">
                <div className="space-y-4 flex-1">
                  {/* Avatar Display */}
                  <div className="flex items-center space-x-4">
                    <div className="w-16 h-16 rounded-full overflow-hidden bg-gray-100 flex items-center justify-center">
                        {userProfile?.avatar ? (
                          <Image
                            src={`${process.env.NEXT_PUBLIC_IMG_URL}/${userProfile.avatar}`}
                            alt="Profile"
                            width={64}
                            height={64}
                            className="w-full h-full object-cover"
                          />
                        ) : (
                        <div className="w-8 h-8 bg-green-600 rounded-full flex items-center justify-center">
                          <span className="text-white font-semibold text-lg">
                            {user?.name?.charAt(0)?.toUpperCase() || "U"}
                          </span>
                        </div>
                      )}
                    </div>
                    <div>
                      <h4 className="font-semibold text-gray-900">{user?.name || userProfile?.username}</h4>
                      <p className="text-sm text-gray-500">@{userProfile?.username || user?.name?.toLowerCase()}</p>
                    </div>
                  </div>
                  
                  {/* Bio Section */}
                  <div className="mt-4">
                    <p className="text-sm text-gray-700">{userProfile?.bio || "This text about bio"}</p>
                  </div>
                </div>
                
                {/* EDIT PROFILE Button at bottom */}
                <div className="mt-auto pt-4">
                  <Link
                    href="/profile-settings"
                    className="w-full bg-skyBlue text-white rounded-sm text-sm font-bold px-6 py-3 transition-all duration-200 hover:scale-105 active:scale-95 inline-block text-center"
                  >
                    EDIT PROFILE
                  </Link>
                </div>
              </div>
            </div>
          </div>
          
          {/* Buyer Profile Section */}
          {buyerProfile ? (
            // Show existing buyer profile in card format
            <div className="lg:col-span-2">
              <div className="bg-white border border-gray-200 rounded-lg p-6 shadow-sm">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">BUYER PROFILE</h3>
                
                {/* Avatar and Name */}
                <div className="flex items-center gap-4 mb-6">
                  {userProfile?.avatar ? (
                    <Image
                      src={`${process.env.NEXT_PUBLIC_IMG_URL}/${userProfile.avatar}`}
                      alt={user?.name || userProfile.username}
                      width={64}
                      height={64}
                      className="rounded-full object-cover"
                    />
                  ) : (
                    <div className="w-16 h-16 bg-skyBlue rounded-full flex items-center justify-center">
                      <span className="text-white font-semibold text-xl">
                        {user?.name?.charAt(0)?.toUpperCase() || "U"}
                      </span>
                    </div>
                  )}
                  <div>
                    <h4 className="font-semibold text-gray-900">{user?.name || userProfile?.username}</h4>
                    <p className="text-sm text-gray-500">Buyer</p>
                  </div>
                </div>

                {/* Interested Categories */}
                {buyerProfile.categories && buyerProfile.categories.length > 0 && (
                  <div className="mb-4">
                    <p className="text-xs text-gray-500 mb-2">Interested in:</p>
                    <div className="flex flex-wrap gap-2">
                      {buyerProfile.categories.slice(0, 3).map((category, index) => (
                        <span key={index} className="px-2 py-1 bg-green-100 text-green-700 text-xs rounded">
                          {category}
                        </span>
                      ))}
                      {buyerProfile.categories.length > 3 && (
                        <span className="px-2 py-1 bg-gray-100 text-gray-600 text-xs rounded">
                          +{buyerProfile.categories.length - 3} more
                        </span>
                      )}
                    </div>
                  </div>
                )}

                {/* Budget Range */}
                {(buyerProfile.budget_min || buyerProfile.budget_max) && (
                  <div className="mb-4">
                    <p className="text-xs text-gray-500 mb-1">Budget Range:</p>
                    <p className="text-sm text-gray-600">
                      ${buyerProfile.budget_min || 0} - ${buyerProfile.budget_max || "No limit"}
                    </p>
                  </div>
                )}

                {/* Tags */}
                {buyerProfile.buyer_tags && buyerProfile.buyer_tags.length > 0 && (
                  <div className="mb-4">
                    <p className="text-xs text-gray-500 mb-1">Tags:</p>
                    <div className="flex flex-wrap gap-1">
                      {buyerProfile.buyer_tags.slice(0, 3).map((tag, index) => (
                        <span key={index} className="text-sm text-gray-600">
                          {tag.tag_name}
                          {index < buyerProfile.buyer_tags.length - 1 && index < 2 && ", "}
                        </span>
                      ))}
                      {buyerProfile.buyer_tags.length > 3 && (
                        <span className="text-sm text-gray-600">
                          +{buyerProfile.buyer_tags.length - 3} more
                        </span>
                      )}
                    </div>
                  </div>
                )}

                {/* EDIT BUYER PROFILE Button */}
                <Link
                  href="/update-buyer-profile"
                  className="w-full bg-skyBlue text-white rounded-sm text-sm font-bold px-6 py-3 transition-all duration-200 hover:scale-105 active:scale-95 inline-block text-center">
                  EDIT BUYER PROFILE
                </Link>
              </div>
            </div>
          ) : (
            // Show create buyer profile button
            <div className="lg:col-span-2">
              <div className="border border-border rounded p-6 text-center">
                <h3 className="text-lg font-semibold text-gray-900 mb-2">Complete Your Buyer Profile</h3>
                <p className="text-gray-600 mb-4">Create your buyer profile with Categories and Tags.</p>
                <Link
                  href="/create-buyer-profiles"
                  className="inline-flex items-center gap-2 bg-skyBlue text-white px-6 py-3 rounded-md font-semibold hover:bg-green-700 transition-colors duration-200"
                >
                  Create Buyer Profile
                </Link>
              </div>
            </div>
          )}
        </div>
      </Container>
    </main>
  );
};

export default BuyerProfilePage;
