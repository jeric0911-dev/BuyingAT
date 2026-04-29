"use client";

import Image from "next/image";
import { useRouter } from "next/navigation";

const UserProfileCard = ({ user, onUpdate }) => {
  console.log('🎯 UserProfileCard: Component rendered', {
    user: user,
    has_profile: !!user?.profile,
    profile_data: user?.profile
  });

  console.log('IMAGE URL:', process.env.NEXT_PUBLIC_IMG_URL);

  const router = useRouter();

  const handleEditProfile = () => {
    router.push('/profile-settings');
  };

  return (
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
              {user?.profile?.avatar ? (
                <Image
                  src={`${process.env.NEXT_PUBLIC_IMG_URL}/${user.profile.avatar}`}
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
              <h4 className="font-semibold text-gray-900">
                {user?.profile?.username || "No username set"}
              </h4>
              <p className="text-sm text-gray-500">@{user?.profile?.username || "username"}</p>
            </div>
          </div>

          {/* Bio Display */}
          {user?.profile?.bio && (
            <div>
              <p className="text-gray-700">{user.profile.bio}</p>
            </div>
          )}

          {/* Empty State */}
          {!user?.profile?.username && !user?.profile?.bio && (
            <div className="text-center py-4">
              <p className="text-gray-500 text-sm">No profile information yet</p>
              <p className="text-gray-400 text-xs">Click &quot;EDIT PROFILE&quot; to get started</p>
            </div>
          )}
        </div>

        {/* EDIT PROFILE Button at bottom */}
        <div className="mt-auto pt-4">
          <button
            onClick={handleEditProfile}
            className="w-full border border-skyBlue rounded-sm text-skyBlue text-sm font-bold px-6 py-3 transition-all duration-200 hover:scale-105 active:scale-95"
          >
            EDIT PROFILE
          </button>
        </div>
      </div>
    </div>
  );
};

export default UserProfileCard;