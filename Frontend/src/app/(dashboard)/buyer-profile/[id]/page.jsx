import { getBuyerProfileById } from "@/actions/buyerProfile";
import Image from "next/image";
import { getUserPackageStatus } from "@/actions/package";
import { FaUserCircle, FaArrowLeft, FaEnvelope, FaPhone, FaMapMarkerAlt } from "react-icons/fa";
import Link from "next/link";

export const metadata = {
  title: "Buyer Profile",
  description: "View detailed buyer profile information",
  robots: { index: false },
};

const BuyerProfileDetailPage = async ({ params }) => {
  const { id } = params;
  const buyerProfileResult = await getBuyerProfileById(id);
  const profile = buyerProfileResult.status === "success" ? buyerProfileResult.data : null;
  console.log('IMAGE URL:', process.env.NEXT_PUBLIC_IMG_URL);
  // Debug logging
  console.log("🔍 Buyer Profile Detail Debug:");
  console.log("🔍 Profile ID:", id);
  console.log("🔍 API Result:", buyerProfileResult);
  console.log("🔍 Profile Data:", profile);
  if (profile) {
    console.log("🔍 Categories:", profile.categories);
    console.log("🔍 Tags:", profile.buyer_tags);
    console.log("🔍 Preferences:", profile.preferences);
    console.log("🔍 Budget:", profile.budget_min, "-", profile.budget_max);
  }


  if (!profile) {
    return (
      <div className="py-8">
        <div className="text-center py-12">
          <FaUserCircle className="mx-auto text-6xl text-gray-300 mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">Buyer Profile Not Found</h3>
          <p className="text-gray-500 mb-4">The buyer profile you&apos;re looking for doesn&apos;t exist.</p>
          <Link 
            href="/buyer-profiles"
            className="inline-flex items-center gap-2 bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700 transition-colors"
          >
            <FaArrowLeft className="w-4 h-4" />
            Back to Buyer Profiles
          </Link>
        </div>
      </div>
    );
  }

  const user = profile.user;
  const initials = user?.name ? user.name.split(' ').map(n => n[0]).join('').toUpperCase() : 'U';
  const avatarUrl = profile.user?.profile?.avatar 
    ? `${process.env.NEXT_PUBLIC_IMG_URL}/${profile.user.profile.avatar}`
    : null;
  // membership status
  const memberStatus = await getUserPackageStatus(profile?.user?.id);
  const isMember = memberStatus?.data?.active;

  return (
    <div className="py-8">
      {/* Header with Back Button */}
      <div className="mb-6">
        <Link 
          href="/buyer-profiles"
          className="inline-flex items-center gap-2 text-green-600 hover:text-green-700 transition-colors mb-4"
        >
          <FaArrowLeft className="w-4 h-4" />
          Back to Buyer Profiles
        </Link>
      </div>

      <div className="max-w-4xl mx-auto">
        {/* Profile Header */}
        <div className="bg-white border border-gray-200 rounded-lg p-6 shadow-sm mb-6">
          <div className="flex items-start gap-6">
            <div className="relative">
              {avatarUrl ? (
                <Image
                  src={avatarUrl}
                  alt={user?.profile?.username || user?.name || "Buyer"}
                  width={80}
                  height={80}
                  className="w-20 h-20 rounded-full object-cover"
                />
              ) : (
                <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center">
                  <span className="text-green-600 font-semibold text-2xl">{initials}</span>
                </div>
              )}
              {isMember && (
                <span className="absolute -bottom-1 -right-1 text-[10px] px-1.5 py-0.5 rounded-full bg-emerald-600 text-white ring-2 ring-white">MEMBER</span>
              )}
            </div>
            
            <div className="flex-1">
              <h1 className="text-2xl font-bold text-gray-900 mb-2">
                {user?.profile?.username || user?.name || "Buyer"}
              </h1>
              <p className="text-gray-600 mb-4">{user?.profile?.bio || "No bio available"}</p>
              
              {/* Contact Information */}
              <div className="flex flex-wrap gap-4 text-sm text-gray-600">
                {user?.email && (
                  <div className="flex items-center gap-2">
                    <FaEnvelope className="w-4 h-4" />
                    <span>{user.email}</span>
                  </div>
                )}
                {user?.phone && (
                  <div className="flex items-center gap-2">
                    <FaPhone className="w-4 h-4" />
                    <span>{user.phone}</span>
                  </div>
                )}
                {user?.zip_code && (
                  <div className="flex items-center gap-2">
                    <FaMapMarkerAlt className="w-4 h-4" />
                    <span>{user.zip_code}</span>
                  </div>
                )}
              </div>
            </div>

            <div className="text-right">
              <button className="bg-green-600 text-white px-6 py-2 rounded-md hover:bg-green-700 transition-colors">
                Contact Buyer
              </button>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Categories Section */}
          <div className="bg-white border border-gray-200 rounded-lg p-6 shadow-sm">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Interested Categories</h3>
            {profile.categories && profile.categories.length > 0 ? (
              <div className="flex flex-wrap gap-2">
                {profile.categories.map((category, index) => (
                  <span 
                    key={index}
                    className="px-3 py-1 bg-green-100 text-green-700 rounded-full text-sm font-medium"
                  >
                    {category}
                  </span>
                ))}
              </div>
            ) : (
              <p className="text-gray-500 text-sm">No categories specified</p>
            )}
          </div>

          {/* Budget Range Section */}
          <div className="bg-white border border-gray-200 rounded-lg p-6 shadow-sm">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Budget Range</h3>
            {(profile.budget_min || profile.budget_max) ? (
              <>
                <div className="text-2xl font-bold text-green-600">
                  ${profile.budget_min || 0} - ${profile.budget_max || "No limit"}
                </div>
                <p className="text-sm text-gray-500 mt-2">Preferred spending range</p>
              </>
            ) : (
              <p className="text-gray-500 text-sm">No budget range specified</p>
            )}
          </div>

          {/* Tags Section */}
          <div className="bg-white border border-gray-200 rounded-lg p-6 shadow-sm lg:col-span-2">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Buyer Tags</h3>
            {profile.buyer_tags && profile.buyer_tags.length > 0 ? (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {profile.buyer_tags.map((tag, index) => (
                  <div key={index} className="border border-gray-200 rounded-lg p-4">
                    <div className="flex items-center justify-between mb-2">
                      <span className="font-medium text-gray-900">{tag.tag_name}</span>
                      {tag.tag_type && (
                        <span className="px-2 py-1 bg-green-100 text-green-700 text-xs rounded">
                          {tag.tag_type}
                        </span>
                      )}
                    </div>
                    <div className="grid grid-cols-2 gap-2 text-sm text-gray-600">
                      {tag.card_condition && (
                        <div>
                          <span className="font-medium">Condition:</span> {tag.card_condition}
                        </div>
                      )}
                      {tag.purchase_volume && (
                        <div>
                          <span className="font-medium">Volume:</span> {tag.purchase_volume}
                        </div>
                      )}
                      {tag.budget_tier && (
                        <div>
                          <span className="font-medium">Tier:</span> {tag.budget_tier}
                        </div>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-gray-500 text-sm">No tags specified</p>
            )}
          </div>

          {/* Preferences Section */}
          <div className="bg-white border border-gray-200 rounded-lg p-6 shadow-sm lg:col-span-2">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Preferences</h3>
            {profile.preferences ? (
              <p className="text-gray-700 leading-relaxed">{profile.preferences}</p>
            ) : (
              <p className="text-gray-500 text-sm">No preferences specified</p>
            )}
          </div>

          {/* Profile Link Section */}
          <div className="bg-white border border-gray-200 rounded-lg p-6 shadow-sm lg:col-span-2">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Profile Link</h3>
            {profile.profile_link ? (
              <a 
                href={profile.profile_link}
                target="_blank"
                rel="noopener noreferrer"
                className="text-green-600 hover:text-green-700 underline"
              >
                {profile.profile_link}
              </a>
            ) : (
              <p className="text-gray-500 text-sm">No profile link provided</p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default BuyerProfileDetailPage;
