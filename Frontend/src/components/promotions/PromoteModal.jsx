"use client";

import { useEffect, useMemo, useState } from "react";
import { toast } from "sonner";
import { useRouter } from "next/navigation";
import useAuth from "@/hooks/useAuth";

const DEFAULT_TIERS = [
  { id: "time_72h", name: "72 hours", price: 9.99, type: "time", duration: 72 },
  { id: "impr_100", name: "100 views", price: 7.99, type: "impression", max_views: 100 },
];

export default function PromoteModal({ cardId, onClose }) {
  const { token } = useAuth();
  const router = useRouter();
  const [tiers, setTiers] = useState(DEFAULT_TIERS);
  const [selected, setSelected] = useState(DEFAULT_TIERS[0].id);
  const [loading, setLoading] = useState(false);

  const tier = useMemo(() => tiers.find(t => t.id === selected), [tiers, selected]);

  const handleConfirm = async () => {
    const envBase = (process.env.SERVER_API_URL).trim();
    const apiBase = envBase.replace(/\/$/, "");
    const url = apiBase ? `${apiBase}/promotions` : "";
    console.log("Promotion evnBase:", envBase);
    console.log("Promotion apiBase:", apiBase);
    console.log("Promotion url:", url);

    if (!apiBase) {
      toast.error("Missing API base URL. Please set NEXT_PUBLIC_SERVE (e.g., http://localhost:8000/api)");
      return;
    }

    if (apiBase.includes("localhost:3000") || apiBase.startsWith("/")) {
      toast.error(`Invalid API base URL: ${apiBase}. It must point to backend (e.g., http://localhost:8000/api).`);
      return;
    }
    if (!token) {
      toast.error("Please log in to promote");
      return;
    }

    try {
      setLoading(true);

      // TODO: integrate payment. For now we directly create the promotion.
      const body = {
        card_id: Number(cardId),
        promotion_price: Number(tier.price),
        promotion_type: tier.type,
        promotion_duration: tier.type === 'time' ? Number(tier.duration) : null,
        max_views: tier.type === 'impression' ? Number(tier.max_views) : null,
      };

      console.log("Promotion body:", body);

      const res = await fetch(url, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({
          ...body,
          // Also send seller_inventory_id for backward compatibility
          seller_inventory_id: Number(cardId),
        }),
      });

      let data;
      try {
        data = await res.json();
      } catch (_) {
        throw new Error(`Unexpected response (${res.status}). Check API base URL: ${apiBase}`);
      }
      if (!res.ok || data?.status === 'error') {
        const msg = data?.message || (data?.errors ? Object.values(data.errors).flat().join(', ') : '') || 'Failed to create promotion';
        throw new Error(msg);
      }

      toast.success("Promotion created! Your card will appear in Spotlight Deals.");
      onClose?.();
      // Redirect to promote cards page
      router.push('/promote-cards');
    } catch (e) {
      console.error('Promote error:', e);
      toast.error(e.message || "Failed to promote");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
      <div className="bg-white w-full max-w-md rounded-md p-5">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold">Promote this Card</h3>
          <button onClick={onClose} className="text-gray-500 hover:text-gray-700">✕</button>
        </div>

        <div className="space-y-3">
          {tiers.map(t => (
            <label key={t.id} className="flex items-center gap-3 p-3 border rounded cursor-pointer">
              <input
                type="radio"
                name="promotion_tier"
                value={t.id}
                checked={selected === t.id}
                onChange={() => setSelected(t.id)}
              />
              <div className="flex-1">
                <div className="font-medium">{t.name}</div>
                <div className="text-sm text-gray-600">
                  {t.type === 'time' ? `${t.duration} hours` : `${t.max_views} views`}
                </div>
              </div>
              <div className="font-semibold">${t.price}</div>
            </label>
          ))}
        </div>

        <div className="mt-5 flex justify-end gap-3">
          <button onClick={onClose} className="px-4 h-10 border rounded">Cancel</button>
          <button
            onClick={handleConfirm}
            disabled={loading}
            className="px-4 h-10 rounded text-white"
            style={{ backgroundColor: '#16a34a' }}
          >
            {loading ? 'Processing...' : 'Pay & Promote'}
          </button>
        </div>
      </div>
    </div>
  );
}


