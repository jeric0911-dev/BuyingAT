import { purchasePlan } from "@/actions/others";
import { useState } from "react";
import { toast } from "sonner";

const MembershipPlanCard = ({ data, activePlanId, hasActive = false }) => {
  const [loading, setLoading] = useState(false);

  const handleConfirm = async (id) => {
    toast("Do you want to purchase this plan?", {
      action: {
        label: "OK",
        onClick: async () => {
          setLoading(true);
          const toastId = toast.loading("Activating...");
          const res = await purchasePlan({ package_id: id });
          setLoading(false);
          if (res.status === "success") {
            toast.success(res.message || "Plan activated!", { id: toastId });
          } else {
            toast.error(res.message || "Something went wrong!", {
              id: toastId,
            });
          }
        },
      },
    });
  };

  const isFree = data?.title?.toLowerCase() === "free";

  return (
    <div
      className={`rounded border ${
        data?.id === activePlanId
          ? "bg-skyBlue/5 border-skyBlue/60"
          : "bg-white border-skyBlue/30"
      } px-9 py-10 max-w-[460px] w-full h-full flex flex-col gap-12`}
    >
      <div>
        <p className="font-semibold text-tBlack uppercase underline underline-offset-4">
          {data?.title}
        </p>
        <p className="mt-14 text-[32px] font-semibold text-skyBlue">
          {data?.title?.toLowerCase() === "free"
            ? "Free Plan"
            : `$ ${data?.price}`}
        </p>
        <ul className="mt-8 list-image-[url('/icon/check-blue.svg')] flex flex-col px-6 gap-4 font-semibold">
          {data?.package_advantage?.map((item) => (
            <li key={item.id} className="text-tBlack/70">
              {item?.title}
            </li>
          ))}
        </ul>
      </div>
      <button
        onClick={() => handleConfirm(data.id)}
        style={
          isFree
            ? {
                backgroundColor: "#E6F7EC", // light green background
                color: "#2A8F47", // dark green text
                borderColor: "#BFE8CB", // light green border
              }
            : undefined
        }
        className={`mt-auto transition-colors text-lg font-semibold w-full rounded h-12 border ${
          isFree
            ? "bg-white border-skyBlue/0" // base values overridden by style
            : "bg-white text-skyBlue border-skyBlue hover:bg-skyBlue hover:text-white"
        } disabled:opacity-60`}
        disabled={
          isFree ||
          loading ||
          data?.id === activePlanId ||
          (hasActive && data?.id !== activePlanId)
        }
      >
        {data?.id === activePlanId ? "Current Plan" : hasActive ? "Locked" : "Buy Now"}
      </button>
    </div>
  );
};

export default MembershipPlanCard;
