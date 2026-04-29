import ResetForm from "@/components/reset/ResetForm";
import Container from "@/components/shared/Container";

export const metadata = {
  title: "Reset Password",
  description: "Reset your password to regain access to your account.",
  robots: { index: false },
};

const ResetPasswordPage = () => {
  return (
    <section>
      <Container>
        <div className="min-h-[calc(100vh-220px)] flex justify-center items-center">
          <ResetForm />
        </div>
      </Container>
    </section>
  );
};

export default ResetPasswordPage;
