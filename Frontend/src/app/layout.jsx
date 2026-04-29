import { Public_Sans } from "next/font/google";
import "./globals.css";
import dynamic from "next/dynamic";
const Navbar = dynamic(() => import("@/components/shared/navbar/Navbar"), {
  ssr: false,
  loading: () => <NavbarLoading />,
});
import "slick-carousel/slick/slick.css";
import "slick-carousel/slick/slick-theme.css";
import NextBreadcrumb from "@/components/shared/NextBreadcrumb";
import { Toaster } from "sonner";
import FacebookPixel from "@/components/facebookPixel/FacebookPixel";
import { getCategories, getSettings } from "@/actions/others";
import { GoogleAnalytics } from "@next/third-parties/google";
import CategoryBar from "@/components/shared/navbar/CategoryBar";
import Footer from "@/components/shared/Footer";
import AuthProviders from "@/providers/AuthProviders";
import NavbarLoading from "@/components/shared/navbar/NavbarLoading";
import { ViewTransitions } from "next-view-transitions";

const publicSans = Public_Sans({
  subsets: ["latin"],
  variable: "--font-publicSans",
});

export const generateMetadata = async () => {
  const { data } = await getSettings();

  return {
    title: { template: `%s | ${data?.meta_title}`, default: data?.meta_title },
    description: data?.meta_description,
    openGraph: {
      title: data?.meta_title,
      description: data?.meta_description,
      images: [
        { url: `${process.env.NEXT_PUBLIC_IMG_URL}/${data?.web_app_logo}` },
      ],
    },
    icons: {
      icon: [
        {
          url: `${process.env.NEXT_PUBLIC_IMG_URL}/${data?.fav_icon}`,
          type: "image/x-icon",
        },
      ],
    },
  };
};

export default async function RootLayout({ children }) {
  const [{ data: settings }, { data: categories }] = await Promise.all([
    getSettings(),
    getCategories(),
  ]);

  return (
    <ViewTransitions>
      <html lang="en" className="scroll-smooth">
        <body className={`${publicSans.variable} font-publicSans`}>
          <AuthProviders>
            {settings?.pixel_id && <FacebookPixel id={settings?.pixel_id} />}
            {settings?.google_analytics_id && (
              <GoogleAnalytics gaId={data?.google_analytics_id} />
            )}

            <Navbar settings={settings} />
            <CategoryBar categories={categories} />
            <NextBreadcrumb capitalizeLinks />
            {children}
            <Footer />
            <Toaster richColors position="top-right" closeButton />
          </AuthProviders>
        </body>
      </html>
    </ViewTransitions>
  );
}
