export const regData = "regData";
export const authKey = "accessToken";
export const success = "success";
import { PiStackBold } from "react-icons/pi";
import { PiStorefrontBold } from "react-icons/pi";
import { FiSettings } from "react-icons/fi";
import { FiShoppingCart } from "react-icons/fi";
import { RiAddBoxLine, RiWallet3Line } from "react-icons/ri";
import { IoPersonCircleOutline } from "react-icons/io5";
import { RiHome3Line } from "react-icons/ri";
import { MdOutlineContactPage, MdSupportAgent } from "react-icons/md";
import { RiBloggerLine } from "react-icons/ri";
import { BsChatDots } from "react-icons/bs";

export const navItemsPublic = [
  { label: "Home", link: "/", icon: <RiHome3Line size={20} /> },
  {
    label: "Contact",
    link: "/contact-us",
    icon: <MdOutlineContactPage size={20} />,
  },
  { label: "Blog", link: "/blog", icon: <RiBloggerLine size={20} /> },
];

export const navItemsPrivate = [
  {
    label: "Add Card",
    link: "/add-card",
    icon: <RiAddBoxLine size={20} />,
  },
  // {
  //   label: "My Inventory",
  //   link: "/my-inventory",
  //   icon: <PiStorefrontBold size={20} />,
  // },
  {
    label: "Promote Cards",
    link: "/promote-cards",
    icon: <PiStorefrontBold size={20} />,
  },
  {
    label: "My Cards",
    link: "/my-cards",
    icon: <FiShoppingCart size={20} />,
  },
  { label: "Wallet", link: "/wallet", icon: <RiWallet3Line size={20} /> },
  {
    label: "Chats",
    link: "/chats",
    icon: <BsChatDots size={20} />,
  },
  {
    label: "Support Ticket",
    link: "/support-ticket",
    icon: <MdSupportAgent size={20} />,
  },
  { label: "Profile", link: "/profile", icon: <PiStackBold size={20} /> },
  { label: "Settings", link: "/settings", icon: <FiSettings size={20} /> },
];

// Seller-specific menu items
export const navItemsSeller = [
  {
    label: "Add Card",
    link: "/add-card",
    icon: <RiAddBoxLine size={20} />,
  },
  // {
  //   label: "My inventory",
  //   link: "/my-inventory",
  //   icon: <PiStorefrontBold size={20} />,
  // },
  {
    label: "Promote Cards",
    link: "/promote-cards",
    icon: <PiStorefrontBold size={20} />,
  },
  {
    label: "My Cards",
    link: "/my-cards",
    icon: <PiStorefrontBold size={20} />,
  },
  { label: "Wallet", link: "/wallet", icon: <RiWallet3Line size={20} /> },
  {
    label: "Buyer Profiles",
    link: "/buyer-profiles",
    icon: <IoPersonCircleOutline size={20} />,
  },
  {
    label: "Chats",
    link: "/chats",
    icon: <BsChatDots size={20} />,
  },
  {
    label: "Support Ticket",
    link: "/support-ticket",
    icon: <MdSupportAgent size={20} />,
  },
  { label: "Profile", link: "/profile", icon: <PiStackBold size={20} /> },
  { label: "Settings", link: "/settings", icon: <FiSettings size={20} /> },
];

// Buyer-specific menu items
export const navItemsBuyer = [
  {
    label: "Browse Cards",
    link: "/cards",
    icon: <RiAddBoxLine size={20} />,
  },
  {
    label: "My Orders",
    link: "/my-orders",
    icon: <PiStorefrontBold size={20} />,
  },
  {
    label: "My Wishlist",
    link: "/wishlist",
    icon: <PiStorefrontBold size={20} />,
  },
  {
    label: "Shopping Cart",
    link: "/shopping-cart",
    icon: <FiShoppingCart size={20} />,
  },
  { label: "Wallet", link: "/wallet", icon: <RiWallet3Line size={20} /> },
  {
    label: "Membership",
    link: "/membership-plan",
    icon: <IoPersonCircleOutline size={20} />,
  },
  {
    label: "Chats",
    link: "/chats",
    icon: <BsChatDots size={20} />,
  },
  {
    label: "Support Ticket",
    link: "/support-ticket",
    icon: <MdSupportAgent size={20} />,
  },
  { label: "Profile", link: "/buyer-profile", icon: <PiStackBold size={20} /> }
];

export const tableHead = [
  "Gateway | Transaction",
  "Initiated",
  "Amount",
  "Conversion",
  "Status",
];

export const shimmer = (w = 200, h = 200) => `
<svg width="${w}" height="${h}" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
  <defs>
    <linearGradient id="g">
      <stop stop-color="#e5e7eb" offset="20%" />
      <stop stop-color="#d1d5db" offset="50%" />
      <stop stop-color="#e5e7eb" offset="70%" />
    </linearGradient>
  </defs>
  <rect width="${w}" height="${h}" fill="#e5e7eb" />
  <rect id="r" width="${w}" height="${h}" fill="url(#g)" />
  <animate xlink:href="#r" attributeName="x" from="-${w}" to="${w}" dur="1s" repeatCount="indefinite" />
</svg>`;
