import { getUser } from "@/actions/auth";
import { getGateways } from "@/actions/others";
import DepositForm from "@/components/deposit/DepositForm";

export const metadata = {
  title: "Deposit",
  robots: { index: false },
};

const DepositPage = async () => {
  const { data } = await getGateways();
  const { data: user } = await getUser();

  return (
    <div className="h-full flex justify-center items-center">
      <DepositForm gateways={data} user={user} />
    </div>
  );
};

export default DepositPage;
