"use client";

import { useEffect, useState } from "react";
import Image from "next/image";
import { getWishlist, toggleWishlistItem } from "@/utils/localStorage";
import useAuth from "@/hooks/useAuth";

export default function CardWishlistList() {
  const { setWishlist } = useAuth();
  const [ids, setIds] = useState([]);
  const [items, setItems] = useState([]);

  useEffect(() => {
    const list = getWishlist();
    setIds(list);
  }, []);

  useEffect(() => {
    const load = async () => {
      try {
        const base = (process.env.NEXT_PUBLIC_SERVE || process.env.SERVER_API_URL || "").replace(/\/$/, "");
        if (!base || ids.length === 0) { setItems([]); return; }
        // fetch each card concurrently
        const results = await Promise.all(
          ids.map(id => fetch(`${base}/home/cards/${id}`, { next: { revalidate: 0 } }).then(r => r.json()).catch(() => null))
        );
        const mapped = results
          .map((res, idx) => ({ res, id: ids[idx] }))
          .filter(x => x?.res?.data)
          .map(x => x.res.data);
        setItems(mapped);
      } catch (_) {
        setItems([]);
      }
    };
    load();
  }, [ids]);

  const remove = (id) => {
    const updated = toggleWishlistItem(id);
    setIds(updated);
    // immediately update navbar badge via context
    try { setWishlist(updated); } catch (_) {}
  };

  if (ids.length === 0) {
    return (
      <Image
        src="/images/empty-wishlist.png"
        alt="no item found"
        width={0}
        height={0}
        sizes="100vw"
        className="w-full md:w-1/2 lg:w-2/5 h-auto mx-auto mt-10 lg:mt-20"
      />
    );
  }

  return (
    <div className="p-6 space-y-4">
      {items.length > 0 ? items.map((item) => (
        <div key={item.id} className="grid grid-cols-[1fr_80px_180px] md:grid-cols-[1fr_100px_200px] lg:grid-cols-[1fr_200px_220px] gap-5 text-sm h-[72px]">
          <div className="flex items-center gap-4 h-full">
            <Image
              src={item.images?.[0] ? `${process.env.NEXT_PUBLIC_IMG_URL}/${item.images[0]}` : "/placeholder-card.jpg"}
              alt={item.card_title}
              width={72}
              height={72}
              className="object-cover rounded"
            />
            <p className="text-tGray pr-10 line-clamp-1">{item.card_title}</p>
          </div>
          <div className="h-full leading-[72px]">${item.price}</div>
          <div className="h-full flex items-center justify-between">
            <a
              href={`/cards/${item.id}`}
              className="px-5 md:px-6 py-2.5 md:py-3 bg-skyBlue rounded-sm text-white text-xs md:text-sm"
            >
              VIEW CARD
            </a>
            <button onClick={() => remove(item.id)} className="transition-transform hover:scale-110 active:scale-90">
              <Image src="/icon/cross.svg" alt="#" width={24} height={24} />
            </button>
          </div>
        </div>
      )) : (
        <Image
          src="/images/empty-wishlist.png"
          alt="no item found"
          width={0}
          height={0}
          sizes="100vw"
          className="w-full md:w-1/2 lg:w-2/5 h-auto mx-auto mt-10 lg:mt-20"
        />
      )}
    </div>
  );
}


