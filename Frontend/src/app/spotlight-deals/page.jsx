import Image from "next/image";
import Link from "next/link";

export const dynamic = 'force-dynamic';

async function fetchSpotlight(page = 1) {
  const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/promotions/spotlight?page=${page}`, { next: { revalidate: 0 } });
  return res.json();
}

export default async function SpotlightDealsPage({ searchParams }) {
  const page = Number(searchParams?.page || 1);
  const data = await fetchSpotlight(page);
  const items = data?.data?.data || data?.data || [];

  return (
    <main className="container py-8">
      <h1 className="text-2xl font-semibold mb-6">🔥 Spotlight Deals</h1>
      {items.length === 0 ? (
        <p className="text-gray-600">No promoted cards yet.</p>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {items.map((promo) => (
            <div key={promo.id} className="border rounded p-4">
              <div className="text-sm text-gray-600 mb-2">Promotion #{promo.id}</div>
              <div className="text-sm">Type: <span className="font-medium">{promo.promotion_type}</span></div>
              {promo.promotion_type === 'time' && (
                <div className="text-sm">Ends: <span className="font-medium">{promo.expires_at || '—'}</span></div>
              )}
              {promo.promotion_type === 'impression' && (
                <div className="text-sm">Views: <span className="font-medium">{promo.promotion_views}/{promo.max_views || '∞'}</span></div>
              )}
              <div className="text-sm mt-1">Price: <span className="font-medium">${promo.promotion_price}</span></div>
            </div>
          ))}
        </div>
      )}
    </main>
  );
}


