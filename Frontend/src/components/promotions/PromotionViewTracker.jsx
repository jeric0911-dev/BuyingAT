"use client";

import { useEffect, useRef } from "react";
import useAuth from "@/hooks/useAuth";

export default function PromotionViewTracker({ cardId, sellerId }) {
  const { user, token } = useAuth();
  const firedRef = useRef(false);

  useEffect(() => {
    const run = async () => {
      try {
        if (firedRef.current) return; // guard against strict mode double-call
        // Skip if viewer is the seller
        if (user && sellerId && user.id === sellerId) return;

        const base = (
          process.env.NEXT_PUBLIC_SERVE ||
          process.env.NEXT_PUBLIC_API_URL ||
          process.env.SERVER_API_URL ||
          ""
        ).replace(/\/$/, "");
        if (!base || !cardId) return;

        // Get active promotion id for this card
        const statusRes = await fetch(`${base}/promotions/status?card_id=${cardId}`, { cache: 'no-store' });
        const statusJson = await statusRes.json();
        const promoId = statusJson?.data?.id;
        if (!promoId) return;

        // Prevent duplicate count per page load and per session
        const cacheKey = `promo_viewed:${promoId}`;
        if (sessionStorage.getItem(cacheKey)) { firedRef.current = true; return; }
        // Mark as fired BEFORE sending request to guard against double-invoke
        sessionStorage.setItem(cacheKey, '1');
        firedRef.current = true;

        // Track a view. Auth is optional; include if present.
        const res = await fetch(`${base}/promotions/${promoId}/view`, {
          method: 'POST',
          headers: token ? { Authorization: `Bearer ${token}` } : undefined,
        });
        // Optionally read response to ensure request completes
        await res.text().catch(() => {});
      } catch (_) {}
    };
    run();
  }, [cardId, sellerId]);

  return null;
}


