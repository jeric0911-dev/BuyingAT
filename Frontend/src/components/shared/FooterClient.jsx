"use client";

import Container from "./Container";
import Image from "next/image";
import { Link } from "next-view-transitions";
import { usePathname } from "next/navigation";

const FooterClient = ({ data, socials, pages, categories }) => {
  const pathname = usePathname();
  const isChat = pathname.includes("chats");

  return (
    <section className={`${isChat ? "hidden xl:block" : ""}`}>
      <footer className="mt-24 bg-tBlack text-[#929FA5]">
        <Container>
          <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-7 gap-10 md:gap-6 py-[72px]">
            <div className="col-span-2 md:col-span-2 lg:col-span-2">
              <Image
                src={`${process.env.NEXT_PUBLIC_IMG_URL}/${data?.footer_logo}`}
                alt="logo"
                width={192}
                height={48}
                className="w-[192px]"
              />
              <p className="text-sm mt-6">Customer Supports:</p>
              <p className="text-lg font-medium text-white">{data?.number}</p>
              <p className="my-3 max-w-[24ch]">{data?.address}</p>
              <p className="font-medium text-white">{data?.mail}</p>
            </div>
            {/* <div className="col-span-1">
              <p className="text-white font-medium">TOP CATEGORY</p>
              <ul className="mt-4 text-sm font-medium space-y-2">
                {categories?.slice(0.7)?.map((category) => (
                  <li key={category.id}>
                    <Link href={`/products?category_id=${category?.id}`}>
                      {category?.category_name}
                    </Link>
                  </li>
                ))}
              </ul>
            </div> */}
            <div className="col-span-1">
              <p className="text-white font-medium">QUICK LINKS</p>
              <ul className="mt-4 space-y-2 text-sm font-medium">
                <li>
                  <Link href="/contact-us">Contact Us</Link>
                </li>
                <li>
                  <Link href="/faqs">FAQ</Link>
                </li>
                <li>
                  <Link href="/blogs">Blogs</Link>
                </li>
                {pages?.map((item) => (
                  <li key={item.id}>
                    <Link href={`/pages/${item?.slug}`}>{item?.title}</Link>
                  </li>
                ))}
              </ul>
            </div>
            <div className="col-span-2 md:col-span-1">
              <p className="text-white font-medium">DOWNLOAD APP</p>
              <div className="flex md:flex-col gap-4 md:gap-0">
                <Link href={data?.google_play} target="_blank">
                  <Image
                    src="/footer/google-play.png"
                    alt="#"
                    width={175}
                    height={68}
                    className="mt-[18px]"
                  />
                </Link>
                <Link href={data?.app_store} target="_blank">
                  <Image
                    src="/footer/app-store.png"
                    alt="#"
                    width={175}
                    height={68}
                    className="mt-[18px]"
                  />
                </Link>
              </div>
            </div>
            <div className="col-span-1 md:col-span-2 lg:col-span-2">
              <p className="text-white font-medium">FOLLOW US</p>
              <div className="mt-[18px] flex items-center gap-4 md:gap-12">
                {socials.map((item, i) => (
                  <Link key={i} href={item?.link} target="_blank">
                    <Image
                      src={`${process.env.NEXT_PUBLIC_IMG_URL}/${item?.icon}`}
                      alt="#"
                      width={24}
                      height={27}
                    />
                  </Link>
                ))}
              </div>
              <p className="mt-12 text-white font-medium">NEWSLETTER</p>
              <div className="flex h-9 mt-[18px]">
                <input
                  type="email"
                  className="flex-grow h-full px-3 rounded-l-[2px]"
                  placeholder="Email address"
                />
                <button className="h-full bg-skyBlue text-white text-[10px] px-4 rounded-r-[2px]">
                  SUBSCRIBE
                </button>
              </div>
            </div>
          </div>
        </Container>
      </footer>
      <footer className="bg-tBlack border-t border-border/10">
        <Container>
          <p className="text-sm text-[#ADB7BC] text-center py-6">
            {data?.copyright}
          </p>
        </Container>
      </footer>
    </section>
  );
};

export default FooterClient;
