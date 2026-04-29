"use client";

import { useEffect, useState } from "react";
import useAuth from "@/hooks/useAuth";
import Image from "next/image";

function formatRemaining(p) {
  if (p.promotion_type === 'time') {
    if (!p.expires_at) return '—';
    try {
      return new Date(p.expires_at).toLocaleDateString();
    } catch (_) {
      return '—';
    }
  }
  if (p.promotion_type === 'impression') {
    if (p.max_views == null) return `${p.promotion_views} views`;
    return `${p.promotion_views}/${p.max_views} views`;
  }
  return '—';
}

export default function MyPromotions() {
  const { token } = useAuth();
  const [items, setItems] = useState([]);
  const [error, setError] = useState("");
  const statusClass = (status) => {
    switch ((status || '').toLowerCase()) {
      case 'active':
        return 'bg-emerald-100 text-emerald-700 ring-1 ring-emerald-300';
      case 'expired':
      case 'completed':
        return 'bg-gray-100 text-gray-700 ring-1 ring-gray-200';
      default:
        return 'bg-yellow-50 text-yellow-700 ring-1 ring-yellow-200';
    }
  };


  useEffect(() => {
    const load = async () => {
      try {
        setError("");
        const base = (process.env.SERVER_API_URL || "").replace(/\/$/, "");
        if (!base) {
          setError("Missing SERVER_API_URL env");
          return;
        }
        const res = await fetch(`${base}/promotions/mine`, {
          headers: {
            Authorization: `Bearer ${token || ''}`
          },
          cache: 'no-store'
        });
        const json = await res.json();
        const data = json?.data?.data || json?.data || [];
        setItems(Array.isArray(data) ? data : []);
      } catch (e) {
        setError("Failed to load promotions");
      }
    };
    if (token) load();
  }, [token]);

  if (error) return <p className="text-red-600 text-sm">{error}</p>;

  if (!items.length) return <p className="text-gray-600">No promotions yet.</p>;

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {items.map((p) => (
        <div
          key={p.id}
          className={`rounded-xl p-5 bg-white shadow-sm hover:shadow-md transition border ${p.status === 'active' ? 'border-emerald-200' : 'border-gray-200'}`}
        >
          <div className="flex items-start gap-4">
            <div className="w-24 h-24 bg-gray-100 rounded-lg overflow-hidden flex items-center justify-center ring-1 ring-gray-200 shrink-0">
              {(() => {
                const base = (process.env.NEXT_PUBLIC_IMG_URL || '').replace(/\/$/, '');
                console.log("Promote Card Image URL:", base);
                console.log("Promote Card Image Path:", p?.item?.image_path);
                const rawPath = (p?.item?.image_path || '').replace(/^\/?storage\//, '');
                const src = base && rawPath ? `${base}/${rawPath}` : (p?.item?.image || null);
                return src ? <img src={src} alt={p?.item?.title || 'card'} className="w-full h-full object-cover" /> : null;
              })()}
            </div>
            <div className="min-w-0 flex-1">
              <div className="flex items-start justify-between">
                <div className="font-semibold truncate text-gray-900">{p?.item?.title || 'Card'}</div>
                <span className={`px-2 py-0.5 text-xs rounded-full ${statusClass(p.status)}`}>{(p.status || '').toUpperCase()}</span>
              </div>
              <div className="text-sm text-gray-600 mt-0.5">${p?.item?.price ?? p.promotion_price}</div>
              <div className="mt-2 flex flex-wrap gap-2">
                <span className="text-[10px] px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700 ring-1 ring-emerald-200">{p.promotion_type}</span>
                {p.promotion_type === 'impression' ? (
                  <span className="text-[10px] px-2 py-0.5 rounded-full bg-blue-50 text-blue-700 ring-1 ring-blue-200">{p.promotion_views}/{p.max_views || '∞'} views</span>
                ) : null}
              </div>
            </div>
          </div>
          <div className="mt-4 grid grid-cols-2 gap-3 text-sm">
            <div>
              <span className="text-gray-500">{p.promotion_type === 'time' ? 'Ends on: ' : 'Remaining: '}</span>
              <span className="font-medium">{formatRemaining(p)}</span>
            </div>
            <div className="text-right">
              <span className="text-gray-500">Price: </span>
              <span className="font-medium">${p.promotion_price}</span>
            </div>
            <div className="col-span-2 text-xs text-gray-500">Started: {new Date(p.created_at).toLocaleString()}</div>
          </div>
        </div>
      ))}
    </div>
  );
}


