import {
  getUser,
  getUserBillingAddress,
  getUserShippingAddress,
} from "@/actions/auth";
import { getCountries, getStates } from "@/actions/location";
import BillingAddressForm from "@/components/settings/BillingAddressForm";
import PasswordUpdateForm from "@/components/settings/PasswordUpdateForm";
import ProfileUpdateForm from "@/components/settings/ProfileUpdateForm";
import ShippingAddressForm from "@/components/settings/ShippingAddressForm";

export const metadata = {
  title: "Settings",
  description: "Manage your account settings",
  robots: { index: false },
};

const SettingsPage = async () => {
  const [
    { data: user },
    { data: countries },
    { data: states },
    { data: billingAddress },
    { data: shippingAddress },
  ] = await Promise.all([
    getUser(),
    getCountries(),
    getStates(),
    getUserBillingAddress(),
    getUserShippingAddress(),
  ]);

  return (
    <div>
      <section className="border border-border rounded">
        <p className="px-6 py-4 text-sm font-medium">ACCOUNT SETTING</p>
        <hr />
        <ProfileUpdateForm data={user} countries={countries} states={states} />
      </section>
      <section className="mt-6 grid grid-cols-1 lg:grid-cols-2 gap-6">
        <BillingAddressForm
          data={billingAddress}
          countries={countries}
          states={states}
        />
        <ShippingAddressForm
          data={shippingAddress}
          countries={countries}
          states={states}
        />
      </section>

      <PasswordUpdateForm />
    </div>
  );
};

export default SettingsPage;
