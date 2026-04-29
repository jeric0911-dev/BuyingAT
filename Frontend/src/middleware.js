import { cookies } from "next/headers";
import { authKey } from "./constants";
import { NextResponse } from "next/server";
import { PROTECTED, PUBLIC } from "./constants/seo";

export async function middleware(request) {
  const token = cookies().get(authKey)?.value;
  const { pathname } = request.nextUrl;

  // Always redirect to login page first, regardless of authentication status
  if (pathname === "/") {
    return NextResponse.redirect(new URL("/login", request.url));
  }

  if (!token && PROTECTED.includes(pathname)) {
    return NextResponse.redirect(new URL("/login", request.url));
  } else if (token && PUBLIC.includes(pathname) && pathname !== "/login") {
    return NextResponse.redirect(new URL("/home", request.url));
  } else {
    return NextResponse.next();
  }
}

export const config = {
  matcher: [
    "/",
    "/home",
    "/customer-orders",
    "/promote-cards",
    "/deposit",
    "/my-listings",
    "/my-cards",
    "/my-orders",
    "/my-inventory",
    "/profile",
    "/profile-settings",
    "/settings",
    "/support-ticket",
    "/wallet",
    "/my-shop",
    "/chats",
    "/add-product",
    "/add-card",
    "/edit-product",
    "/login",
    "/membership-plan",
    "/shop/create-shop",
    "/shop/update-shop",
    "/shopping-cart",
    "/wishlist",
    "/cards",
    "/reset-password",
    "/otp-verification",
  ],
};
