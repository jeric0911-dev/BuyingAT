"use client";

import { useEffect, useState } from "react";
import MembershipPlanCard from "./MembershipPlanCard";
import useAuth from "@/hooks/useAuth";

const MembershipPlan = ({ data }) => {
  const {user, token} = useAuth()
  const [plan, setPlan] = useState("monthly");
  const [activePlanId, setActivePlanId] = useState(null);
  const [hasActive, setHasActive] = useState(false);

  useEffect(() => {
    const load = async () => {
      try {
        const base = (process.env.NEXT_PUBLIC_SERVE || process.env.SERVER_API_URL || "").replace(/\/$/, "");
        if (!base || !token) return;
        const res = await fetch(`${base}/user/current-package`, {
          headers: { Authorization: `Bearer ${token}` },
          cache: 'no-store'
        });
        const json = await res.json();
        if (json?.data) {
          setHasActive(!!json.data.active);
          setActivePlanId(json.data.package?.package_id || json.data.package?.id || null);
        }
      } catch (_) {}
    };
    load();
  }, [token]);
  const freePlan = data?.find((item) => item.title.toLowerCase() === "free");
  const selectedPlanData = data?.find(
    (item) => item.title.toLowerCase() === plan
  );

  return (
    <>
      <div className="flex justify-center items-center bg-[#EDF1F4] w-max mx-auto rounded-full transition-colors border border-skyBlue/5 h-10 mt-10">
        {data
          ?.filter((item) => item.title.toLowerCase() !== "free")
          ?.map((item) => (
            <button
              key={item.id}
              onClick={() => setPlan(item.title.toLowerCase())}
              className={`px-5 h-full rounded-full transition-colors ${
                plan === item?.title?.toLowerCase()
                  ? "text-white bg-skyBlue font-semibold"
                  : "text-tBlack font-medium"
              } `}
            >
              {item.title}
            </button>
          ))}
      </div>
      <div className="w-full max-w-5xl mx-auto grid grid-cols-1 lg:grid-cols-2 gap-5 place-items-center lg:gap-10 mt-12 mb-32">
        <MembershipPlanCard
          data={freePlan.packages?.[0]}
          activePlanId={activePlanId}
          hasActive={hasActive}
        />
        {selectedPlanData?.packages?.map((item, i) => (
          <MembershipPlanCard
            key={item.id}
            data={item}
            activePlanId={activePlanId}
            hasActive={hasActive}
          />
        ))}
      </div>
    </>
  );
};

export default MembershipPlan;
