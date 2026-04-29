import { getUser, getUserBillingAddress } from "@/actions/auth";
import { getMyOrders, getMyOrderStats } from "@/actions/cart";
import { getUserProfileServer } from "@/actions/userProfileServer";
import ProfileTable from "@/components/profile/ProfileTable";
import { getCurrentPackage } from "@/actions/package";
import UserProfileCard from "@/components/profile/UserProfileCard";
import Image from "next/image";
import { Link } from "next-view-transitions";
import { FaUserCircle } from "react-icons/fa";

export const metadata = {
  title: "Profile",
  description: "View and manage your profile details",
  robots: { index: false },
};

const ProfilePage = async () => {
  const [
    { data: user },
    { data: orders },
    { data: orderStats },
    { data: billingAddress },
    { data: userProfile },
    currentPackage,
  ] = await Promise.all([
    getUser(),
    getMyOrders(),
    getMyOrderStats(),
    getUserBillingAddress(),
    getUserProfileServer(),
    getCurrentPackage(),
  ]);

  // Merge user profile data with user data
  const userWithProfile = {
    ...user,
    profile: userProfile
  };

  // Check if user is a buyer
  const isBuyer = user?.role === 'buyer';

  return (
    <div>
      <section>
        <p className="text-xl font-semibold">{user?.name}</p>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mt-6">
          {/* ------------------User Profile Card------------------ */}
          <div className="lg:col-span-1">
            <UserProfileCard user={userWithProfile} />
          </div>
          
          {/* ------------------column-1------------------ */}
          <div className="border border-border rounded h-full">
            <p className="px-6 py-4 text-sm font-medium">ACCOUNT INFO</p>
            <hr />
            <div className="h-[calc(100%-52px)] p-6 flex flex-col">
              <div className="flex items-center gap-4">
                {user?.profile_img ? (
                  <div className="relative">
                    <Image
                      src={`${process.env.NEXT_PUBLIC_IMG_URL}/${user?.profile_img}`}
                      alt={user?.name}
                      width={48}
                      height={48}
                      className="rounded-full object-cover"
                    />
                    {currentPackage?.data?.active && (
                      <span className="absolute -bottom-1 -right-1 text-[10px] px-1.5 py-0.5 rounded-full bg-emerald-600 text-white ring-2 ring-white">MEMBER</span>
                    )}
                  </div>
                ) : (
                  <div className="relative">
                    <FaUserCircle className="size-12 text-skyBlue" />
                    {currentPackage?.data?.active && (
                      <span className="absolute -bottom-0.5 -right-0.5 text-[10px] px-1.5 py-0.5 rounded-full bg-emerald-600 text-white ring-2 ring-white">MEMBER</span>
                    )}
                  </div>
                )}
                <div>
                  <p className="font-semibold">{user?.name}</p>
                  {/* <p className="mt-1 text-tGray text-sm">{user?.address}</p> */}
                </div>
              </div>
              <p className="mt-5 text-sm">
                Email: <span className="text-tGray">{user?.email}</span>
              </p>
              {/* <p className="mt-2 text-sm">
                Phone:{" "}
                <span className="text-tGray">{user?.phone ?? "N/A"}</span>
              </p> */}
              <Link
                href="/settings"
                className="mt-auto w-max border border-skyBlue rounded-sm text-skyBlue text-sm font-bold px-6 py-3 transition-all duration-200 hover:scale-110 active:scale-95"
              >
                EDIT ACCOUNT
              </Link>
            </div>
          </div>
          {/* ------------------column-2------------------ */}
          {/* <div className="border border-border rounded lg:col-span-1">
            <p className="px-6 py-4 text-sm font-medium">BILLING ADDRESS</p>
            <hr />
            <div className="p-6 h-[calc(100%-52px)] flex flex-col">
              <p className="text-sm font-medium">{}</p>
              <p className="mt-2 text-sm text-tGray">
                {billingAddress?.address}
              </p>
              <p className="mt-2 text-sm">
                Phone Number:{" "}
                <span className="text-tGray">
                  {billingAddress?.phone ?? "N/A"}
                </span>
              </p>
              <p className="mt-2 text-sm">
                Email:{" "}
                <span className="text-tGray">
                  {billingAddress?.email ?? "N/A"}
                </span>
              </p>
              <Link
                href="/settings"
                className="mt-2 xl:mt-auto w-max border border-skyBlue rounded-sm text-skyBlue text-sm font-bold px-6 py-3 transition-all duration-200 hover:scale-110 active:scale-95"
              >
                EDIT ADDRESS
              </Link>
            </div>
          </div> */}
          {/* ------------------column-3------------------ */}
          <div className="flex flex-col justify-between gap-5 lg:col-span-2">
            <div className="flex items-center gap-4 p-4 rounded bg-skyBlue/10">
              <div className="p-4 rounded-sm bg-white">
                <Image
                  src="/icon/total-order.svg"
                  alt="#"
                  width={32}
                  height={32}
                />
              </div>
              <div>
                <p className="text-xl font-semibold">
                  {orderStats?.total_orders}
                </p>
                <p className="text-sm text-tGray mt-1">Total Orders</p>
              </div>
            </div>
            <div className="flex items-center gap-4 p-4 rounded bg-green/10">
              <div className="p-4 rounded-sm bg-white">
                <Image
                  src="/icon/completed-order.svg"
                  alt="#"
                  width={32}
                  height={32}
                />
              </div>
              <div>
                <p className="text-xl font-semibold">
                  {orderStats?.completed_orders}
                </p>
                <p className="text-sm text-tGray mt-1">Completed Orders</p>
              </div>
            </div>
            <div className="flex items-center gap-4 p-4 rounded bg-orange/10">
              <div className="p-4 rounded-sm bg-white">
                <Image
                  src="/icon/pending-order.svg"
                  alt="#"
                  width={32}
                  height={32}
                />
              </div>
              <div>
                <p className="text-xl font-semibold">
                  {orderStats?.pending_orders}
                </p>
                <p className="text-sm text-tGray mt-1">Pending Orders</p>
              </div>
            </div>
          </div>
        </div>
      </section>
      {/*  <section className="mt-6 border border-border rounded">
        <p className="flex justify-between items-center px-6 py-3 text-sm">
          <span className="font-medium">PAYMENT OPTION</span>
          <span className="text-skyBlue font-semibold flex items-center gap-2">
            Add Card
            <Image
              src="/icon/right-arrow-blue.svg"
              alt="#"
              width={20}
              height={20}
            />
          </span>
        </p>
        <hr />
        <div className="p-6 flex lg:flex-row flex-col items-center gap-6">
          <div className="bg-gradient-to-br from-[#1B6392] to-[#124261] p-6 rounded text-white min-w-72">
            <p className="flex items-center justify-between">
              <span>$95, 400.00 USD</span>
              <span>---</span>
            </p>
            <p className="text-xs font-medium mt-6">CARD NUMBER</p>
            <p className="mt-2 flex items-center gap-2 text-xl">
              <span>**** **** **** 3814</span>{" "}
              <Image src="/icon/copy.svg" alt="#" width={20} height={20} />
            </p>
            <p className="mt-5 flex items-center justify-between">
              <Image src="/icon/visa.svg" alt="#" width={40} height={40} />
              <span className="text-sm font-medium">Kevin Gilbert</span>
            </p>
          </div>
          <div className="bg-gradient-to-br from-[#248E1D] to-[#2DB224] p-6 rounded text-white min-w-72">
            <p className="flex items-center justify-between">
              <span>$95, 400.00 USD</span>
              <span>---</span>
            </p>
            <p className="text-xs font-medium mt-6">CARD NUMBER</p>
            <p className="mt-2 flex items-center gap-2 text-xl">
              <span>**** **** **** 1761</span>{" "}
              <Image src="/icon/copy.svg" alt="#" width={20} height={20} />
            </p>
            <p className="mt-5 flex items-center justify-between">
              <Image
                src="/icon/mastercard.svg"
                alt="#"
                width={40}
                height={40}
              />
              <span className="text-sm font-medium">Kevin Gilbert</span>
            </p>
          </div>
        </div>
      </section> */}
      <section className="mt-6 border border-border rounded ">
        <div className="px-6 py-3 text-sm font-medium flex justify-between items-center">
          <span>RECENT ORDER</span>
          <Link
            href="/my-orders"
            className="text-skyBlue font-semibold flex items-center gap-2"
          >
            View All
            <Image
              src="/icon/right-arrow-blue.svg"
              alt="#"
              width={20}
              height={20}
            />
          </Link>
        </div>
        <ProfileTable data={orders?.slice(0, 5)} />
      </section>
    </div>
  );
};

export default ProfilePage;
