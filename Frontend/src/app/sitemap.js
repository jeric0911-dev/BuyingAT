import {
  getAllShopSlug,
  getBlogs,
  getCategories,
  getPages,
} from "@/actions/others";
import { sitemapRoutes } from "@/constants/seo";
import getSearchParams from "@/utils/getSearchParams";

export default async function sitemap() {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL;

  const staticRoutes = sitemapRoutes.map((item) => ({
    ...item,
    url: `${baseUrl}${item.url.replace(/&/g, "&amp;")}`,
  }));

  const { data: categories } = await getCategories();
  const categoryRoutes = categories?.map((item) => ({
    url: `${baseUrl}/products?category_id=${item?.id}`,
    lastModified: new Date(),
  }));

  const { data: shops } = await getAllShopSlug();
  const shopsRoutes = shops?.map((item) => ({
    url: `${baseUrl}/shop/${item}`,
    lastModified: new Date(),
  }));

  const { data: pages } = await getPages();
  const pagesRoutes = pages?.map((item) => ({
    url: `${baseUrl}/pages/${item?.slug}`,
    lastModified: new Date(),
  }));

  const { data: blogs } = await getBlogs(getSearchParams({ limit: 999 }));
  const blogsRoutes = blogs?.items?.map((item) => ({
    url: `${baseUrl}/blogs/${encodeURIComponent(item?.slug)}`,
    lastModified: new Date(),
  }));

  return [
    ...staticRoutes,
    ...categoryRoutes,
    ...shopsRoutes,
    ...pagesRoutes,
    ...blogsRoutes,
  ];
}
