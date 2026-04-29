"use client";

import { usePathname } from "next/navigation";
import { Link } from "next-view-transitions";
import React from "react";
import Image from "next/image";
import Container from "./Container";

const NextBreadcrumb = ({ listClasses, capitalizeLinks }) => {
  const paths = usePathname();
  const pathNames = paths.split("/").filter((path) => path);

  if (pathNames.length <= 0) return null;

  return (
    <section className="w-full h-16 bg-lightGray hidden lg:block">
      <Container>
        <ul className="h-full flex items-center gap-1 md:gap-2 text-tGray text-sm">
          <li className="min-w-16">
            <Link href="/profile" className="flex items-center gap-1 md:gap-2">
              <Image
                src="/icon/house.svg"
                alt="Home icon"
                width={20}
                height={20}
              />
              <p>Home</p>
            </Link>
          </li>
          {pathNames.map((link, index) => {
            const href = `/${pathNames.slice(0, index + 1).join("/")}`;
            const itemClasses = paths === href ? "text-skyBlue" : listClasses;
            const itemLink = capitalizeLinks
              ? link[0].toUpperCase() + link.slice(1)
              : link;
            return (
              <React.Fragment key={index}>
                <li className="flex items-center gap-1">
                  <Image
                    src="/icon/caret-right.svg"
                    alt="breadcrumb separator"
                    width={12}
                    height={12}
                  />
                  <Link href={href} className={`${itemClasses} line-clamp-1`}>
                    {itemLink}
                  </Link>
                </li>
              </React.Fragment>
            );
          })}
        </ul>
      </Container>
    </section>
  );
};

export default NextBreadcrumb;
