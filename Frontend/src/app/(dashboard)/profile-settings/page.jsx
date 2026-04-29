import { getUser } from "@/actions/auth";
import { getUserProfileServer } from "@/actions/userProfileServer";
import ProfileSettingsForm from "@/components/profile/ProfileSettingsForm";
import Container from "@/components/shared/Container";

export const metadata = {
  title: "Profile Settings",
  description: "Edit your profile information",
  robots: { index: false },
};

const ProfileSettingsPage = async () => {
  const [
    { data: user },
    { data: userProfile },
  ] = await Promise.all([
    getUser(),
    getUserProfileServer(),
  ]);

  // Merge user profile data with user data
  const userWithProfile = {
    ...user,
    profile: userProfile
  };

  return (
    <main className="mt-10">
      <Container>
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-gray-900">Profile Settings</h1>
          <p className="text-gray-600 mt-2">Manage your personal information and preferences</p>
        </div>
        
        <ProfileSettingsForm 
          user={userWithProfile}
        />
      </Container>
    </main>
  );
};

export default ProfileSettingsPage;
