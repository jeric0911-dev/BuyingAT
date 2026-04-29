export default async function robots() {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL;
  const sitemapReferences = [`${baseUrl}/sitemap.xml`];

  return {
    rules: {
      userAgent: "*",
      allow: "/",
      disallow: [
        "/customer-orders",
        "/deposit",
        "/my-listings",
        "/my-orders",
        "/profile",
        "/settings",
        "/support-ticket",
        "/wallet",
        "/my-shop",
        "/chats",
        "/add-product",
        "/edit-product",
        "/login",
        "/membership-plan",
        "/otp-verification",
        "/reset-password",
        "/shop/create-shop",
        "/shop/update-shop",
        "/shopping-cart",
        "/shopping-cart/",
        "/wishlist",
      ],
    },
    sitemap: sitemapReferences,
  };
}
