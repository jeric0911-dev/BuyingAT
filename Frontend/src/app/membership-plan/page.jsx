import { getUser } from "@/actions/auth";
import { getPackages } from "@/actions/others";
import MembershipPlan from "@/components/membership/MembershipPlan";
import Container from "@/components/shared/Container";

export const metadata = {
  title: "Membership Plan",
  robots: { index: false },
};

const MembershipPlanPage = async () => {
  const { data } = await getPackages()

  return (
    <Container>
      <main className="mt-12">
        <p className="text-skyBlue uppercase text-center font-semibold">
          subscription
        </p>
        <p className="mt-3 text-tBlack text-[32px] font-semibold text-center">
          Flexible pricing options designed for your business
        </p>
        <p className="text-center text-tBlack/70 mt-[26px] max-w-[55ch] mx-auto">
          Empower your business with impactful services. Straightforward,
          personalized plans just for you.
        </p>
        <MembershipPlan data={data} />
      </main>
    </Container>
  );
};

export default MembershipPlanPage;
