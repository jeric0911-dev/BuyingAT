import Pagination from "@/components/shared/Pagination";
import MyPromotions from "@/components/promotions/MyPromotions";

export const metadata = {
  title: "Promote Cards",
  robots: { index: false },
};

async function fetchMyPromotions(page = 1) {
  const apiBase = (process.env.SERVER_API_URL || "").replace(/\/$/, "");
  const { cookies } = await import("next/headers");
  const token = cookies().get("accessToken")?.value;
  const res = await fetch(`${apiBase}/promotions/mine?page=${page}`, {
    headers: { Authorization: `Bearer ${decodeURIComponent(token || '')}` },
    next: { revalidate: 0 },
  });
  const json = await res.json();
  return { data: json?.data?.data || [], pagination: json?.data };
}

function formatRemaining(p) {
  if (p.promotion_type === 'time') {
    if (p.remaining == null) return '—';
    const sec = Number(p.remaining);
    const h = Math.floor(sec / 3600);
    const m = Math.floor((sec % 3600) / 60);
    return `${h}h ${m}m left`;
  }
  if (p.promotion_type === 'impression') {
    if (p.max_views == null) return `${p.promotion_views} views`;
    return `${p.promotion_views}/${p.max_views} views`;
  }
  return '—';
}

const PromoteCardsPage = async ({ searchParams: { page = 1 } }) => {
  const { data, pagination } = await fetchMyPromotions(page).catch(() => ({ data: [], pagination: null }));

  return (
    <section className="border border-border rounded overflow-hidden p-4">
      <h1 className="text-xl font-semibold mb-4">My Promoted Cards</h1>
      {/* Client-rendered list to ensure token-based fetch works reliably */}
      <MyPromotions />
      <Pagination total_pages={pagination?.last_page} className="!my-12" />
    </section>
  );
};

export default PromoteCardsPage;
