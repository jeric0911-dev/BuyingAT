import { getGoogleConfig } from "@/actions/location";
import Login from "@/components/login/LoginForm";
import Container from "@/components/shared/Container";
import { GoogleOAuthProvider } from "@react-oauth/google";

export const metadata = {
  title: "Login",
  description: "Login to your account",
  robots: { index: false },
};

const LoginPage = async () => {
  const { data } = await getGoogleConfig();

  return (
    <GoogleOAuthProvider clientId={data?.google_client_id}>
      <Container>
        <div className="min-h-[calc(100vh-300px)] flex justify-center items-center">
          <Login />
        </div>
      </Container>
    </GoogleOAuthProvider>
  );
};

export default LoginPage;
