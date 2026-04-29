"use client";

import dayjs from "dayjs";
import relativeTime from "dayjs/plugin/relativeTime";
import Image from "next/image";
import EditInventoryButton from "./EditInventoryButton";
import DeleteInventoryButton from "./DeleteInventoryButton";
import { useEffect, useState } from "react";
import PromoteModal from "@/components/promotions/PromoteModal";
import { Link } from "next-view-transitions";
import toBase64 from "@/utils/toBase64";
import { shimmer } from "@/constants";
import { FaClock, FaCheckCircle, FaTimesCircle } from "react-icons/fa";

dayjs.extend(relativeTime);

const MyInventoryCard = ({ data }) => {
  // Get the request status
  const requestStatus = data?.request_status || 'pending';
  
  // Status configuration
  const statusConfig = {
    pending: {
      icon: FaClock,
      color: 'text-yellow-600',
      bgColor: 'bg-yellow-100',
      label: 'Pending Review',
      description: 'Your card is under review'
    },
    approved: {
      icon: FaCheckCircle,
      color: 'text-green-600',
      bgColor: 'bg-green-100',
      label: 'Approved',
      description: 'Your card has been approved'
    },
    rejected: {
      icon: FaTimesCircle,
      color: 'text-red-600',
      bgColor: 'bg-red-100',
      label: 'Rejected',
      description: 'Your card was rejected'
    }
  };

  const status = statusConfig[requestStatus] || statusConfig.pending;
  const StatusIcon = status.icon;

  const [open, setOpen] = useState(false);
  const [isPromoted, setIsPromoted] = useState(false);

  useEffect(() => {
    let ignore = false;
    const check = async () => {
      try {
        const base = (process.env.NEXT_PUBLIC_SERVE || "").replace(/\/$/, "");
        if (!base) return;
        const res = await fetch(`${base}/promotions/status?card_id=${data?.id}`, { cache: 'no-store' });
        const json = await res.json();
        if (!ignore && json?.data) setIsPromoted(!!json.data.active);
      } catch (_) {}
    };
    check();
    return () => { ignore = true; };
  }, [data?.id]);

  return (
    <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden hover:shadow-md transition-shadow">
      {/* Card Image */}
      <div className="relative h-48 w-full">
        {data?.images && data.images.length > 0 ? (
          <Image
            src={`${process.env.NEXT_PUBLIC_IMG_URL}/${data.images[0]}`}
            alt={data?.card_title}
            fill
            placeholder={`data:image/svg+xml;base64,${toBase64(shimmer())}`}
            className="object-cover"
          />
        ) : (
          <div className="w-full h-full bg-gray-200 flex items-center justify-center">
            <span className="text-gray-500">No Image</span>
          </div>
        )}
      </div>
      
      {/* Card Content */}
      <div className="p-4">
        <h3 className="text-lg font-semibold text-gray-900 mb-2 line-clamp-2">
          {data?.card_title}
        </h3>
        
        {/* Status Badge */}
        <div className={`inline-flex items-center gap-2 px-2 py-1 rounded-full text-xs font-medium ${status.bgColor} ${status.color} mb-3`}>
          <StatusIcon className="w-3 h-3" />
          <span>{status.label}</span>
        </div>
        
        <p className="text-xs text-gray-600 mb-3">
          {status.description}
        </p>
        
        {/* Price */}
        <p className="text-skyBlue text-xl font-bold mb-3">
          $ {data?.price}
        </p>
        
        {/* Card Details */}
        <div className="space-y-1 mb-4">
          {data?.condition && (
            <p className="text-sm text-gray-600">
              <span className="font-medium">Condition:</span> {data.condition}
            </p>
          )}
          {data?.sport_type && (
            <p className="text-sm text-gray-600">
              <span className="font-medium">Sport:</span> {data.sport_type}
            </p>
          )}
          <div className="flex items-center gap-1 text-xs text-gray-500">
            <Image
              src="/icon/time-circle.svg"
              alt="clock"
              width={12}
              height={12}
            />
            <span>{dayjs(data?.created_at).fromNow()}</span>
          </div>
        </div>
        
        {/* Action Buttons */}
        <div className="grid grid-cols-3 gap-2">
          <EditInventoryButton data={data} />
          <DeleteInventoryButton data={data} />
          <button
            onClick={() => setOpen(true)}
            disabled={isPromoted}
            className={`border h-10 rounded px-2 ${isPromoted ? 'cursor-not-allowed text-gray-400 border-gray-300' : 'text-skyBlue border-skyBlue'}`}
            title={isPromoted ? 'Already promoted' : 'Promote this card'}
          >
            {isPromoted ? 'Promoted' : 'Promote'}
          </button>
        </div>
        {open && (
          <PromoteModal cardId={data?.id} onClose={() => { setOpen(false); setIsPromoted(true); }} />
        )}
      </div>
    </div>
  );
};

export default MyInventoryCard;
