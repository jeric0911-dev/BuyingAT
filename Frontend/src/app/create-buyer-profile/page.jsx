import { getGoogleConfig } from "@/actions/location";
import CreateBuyerProfile from "@/components/buyer/CreateBuyerProfileForm";
import Container from "@/components/shared/Container";
import { GoogleOAuthProvider } from "@react-oauth/google";

export const metadata = {
  title: "Create Buyer Profile",
  description: "Create your buyer profile",
  robots: { index: false },
};

const CreateBuyerProfilePage = async () => {
  const { data } = await getGoogleConfig();

  return (
    <GoogleOAuthProvider clientId={data?.google_client_id}>
      <Container>
        <div className="min-h-[calc(100vh-300px)] flex justify-center items-center">
          <CreateBuyerProfile />
        </div>
      </Container>
    </GoogleOAuthProvider>
  );
};

export default CreateBuyerProfilePage;
