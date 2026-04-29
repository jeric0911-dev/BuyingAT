export const sitemapRoutes = [
  {
    url: "/",
    lastModified: new Date(),
    changeFrequency: "weekly",
    priority: 1,
  },
  {
    url: "/contact-us",
    lastModified: new Date(),
    changeFrequency: "weekly",
    priority: 0.9,
  },
  {
    url: "/products",
    lastModified: new Date(),
    changeFrequency: "weekly",
    priority: 0.9,
  },
  {
    url: "/products?sort_by=discount",
    lastModified: new Date(),
    changeFrequency: "weekly",
    priority: 0.9,
  },
  {
    url: "/products?is_featured=1",
    lastModified: new Date(),
    changeFrequency: "weekly",
    priority: 0.9,
  },
  {
    url: "/products?sort_by=rating&sort_direction=desc",
    lastModified: new Date(),
    changeFrequency: "weekly",
    priority: 0.9,
  },
];

export const PUBLIC = ["/login", "/reset-password", "/otp-verification"];
export const PROTECTED = [
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
  "/membership-plan",
  "/shop/create-shop",
  "/shop/update-shop",
  "/shopping-cart",
  "/wishlist",
];
