import {
  AccountBalanceRounded,
  AdminPanelSettingsRounded,
  ArticleRounded,
  AssessmentRounded,
  AutoAwesomeRounded,
  BorderBottomRounded,
  // CampaignRounded,
  CategoryRounded,
  CurrencyExchangeRounded,
  // FeedRounded,
  FlagRounded,
  GridViewRounded,
  HelpOutlineRounded,
  InterestsRounded,
  Inventory2Rounded,
  // LabelRounded,
  LiveHelpRounded,
  // LocationCityRounded,
  LockPersonRounded,
  ManageAccountsRounded,
  MapRounded,
  PaletteRounded,
  PaymentRounded,
  PsychologyAltRounded,
  PublicRounded,
  ReceiptLongRounded,
  SettingsApplicationsRounded,
  SettingsRounded,
  ShareRounded,
  ShoppingCartRounded,
  // SlideshowRounded,
  // StorefrontRounded,
  StoreMallDirectoryRounded,
  // StoreRounded,
  SupervisorAccountRounded,
  SupportAgentRounded,
  // ViewCarouselRounded,
  VpnKeyRounded,
  WebStoriesRounded,
} from "@mui/icons-material";
import { SvgIconProps } from "@mui/material";
// import Dashboard from "../assets/icon/dashboard.svg?react";

export type TNavItem = {
  path?: string;
  title: string;
  icon: React.ComponentType<SvgIconProps>;
  subItems?: TNavItem[];
};

const navItems: TNavItem[] = [
  {
    path: "/",
    title: "Dashboard",
    icon: GridViewRounded,
  },
  {
    title: "Card Management",
    icon: ShoppingCartRounded,
    subItems: [
      // {
      //   path: "/category",
      //   title: "Category",
      //   icon: CategoryRounded,
      // },
      // {
      //   path: "/sub-category",
      //   title: "Sub Category",
      //   icon: CategoryRounded,
      // },
      // {
      //   path: "/child-category",
      //   title: "Child Category",
      //   icon: CategoryRounded,
      // },
      // {
      //   path: "/brand",
      //   title: "Brand",
      //   icon: StoreRounded,
      // },
      // {
      //   path: "/product-management",
      //   title: "Products",
      //   icon: Inventory2Rounded,
      // },
      {
        path: "/card-management",
        title: "Cards",
        icon: Inventory2Rounded,
      },
      {
        path: "/reports",
        title: "Reported Cards",
        icon: AssessmentRounded,
      },
    ],
  },
  {
    title: "Membership Management",
    icon: StoreMallDirectoryRounded,
    subItems: [
      // {
      //   path: "/shop-management",
      //   title: "Shops",
      //   icon: StorefrontRounded,
      // },
      {
        path: "/package-category",
        title: "Package Category",
        icon: CategoryRounded,
      },
      {
        path: "/package",
        title: "Package",
        icon: WebStoriesRounded,
      },
    ],
  },
  {
    title: "Financial Management",
    icon: AccountBalanceRounded, // or MonetizationOnRounded
    subItems: [
      {
        path: "/currency",
        title: "Currency",
        icon: CurrencyExchangeRounded,
      },
      {
        path: "/transaction-history",
        title: "Transaction History",
        icon: ReceiptLongRounded,
      },
    ],
  },
  {
    title: "Content Management",
    icon: ArticleRounded,
    subItems: [
      // {
      //   path: "/blogs",
      //   title: "Blogs",
      //   icon: FeedRounded,
      // },
      // {
      //   path: "/blog-category",
      //   title: "Blog Category",
      //   icon: LabelRounded,
      // },
      {
        path: "/pages",
        title: "Pages",
        icon: AutoAwesomeRounded,
      },
      {
        path: "/faqs",
        title: "FAQ",
        icon: LiveHelpRounded,
      },
    ],
  },
  {
    title: "Appearance",
    icon: PaletteRounded,
    subItems: [
      // { path: "/slider", title: "Slider", icon: SlideshowRounded },
      // {
      //   path: "/hero-section",
      //   title: "Hero Section",
      //   icon: ViewCarouselRounded,
      // },
      // {
      //   path: "/advertisement",
      //   title: "Advertisement",
      //   icon: CampaignRounded,
      // },
      {
        path: "/footer",
        title: "Footer",
        icon: BorderBottomRounded,
      },
    ],
  },
  {
    title: "Location Management",
    icon: PublicRounded,
    subItems: [
      { path: "/countries", title: "Countries", icon: FlagRounded },
      // { path: "/cities", title: "Cities", icon: LocationCityRounded },
      { path: "/states", title: "States", icon: MapRounded },
    ],
  },
  {
    title: "Admin & Permissions",
    icon: AdminPanelSettingsRounded,
    subItems: [
      { path: "/admins", title: "Admins", icon: SupervisorAccountRounded },
      {
        path: "/role-permission",
        title: "Roles & Permissions",
        icon: LockPersonRounded,
      },
      {
        path: "/user-management",
        title: "User Management",
        icon: ManageAccountsRounded,
      },
      {
        path: "/buyer-approvals",
        title: "Buyer Approvals",
        icon: SupervisorAccountRounded,
      },
    ],
  },
  {
    title: "Support",
    icon: SupportAgentRounded,
    subItems: [
      {
        path: "/support-ticket",
        title: "Support Tickets",
        icon: PsychologyAltRounded,
      },
      {
        path: "/client-query",
        title: "Client Query",
        icon: HelpOutlineRounded,
      },
    ],
  },
  {
    title: "Credentials",
    icon: VpnKeyRounded,
    subItems: [
      { path: "/payment-credentials", title: "Payment", icon: PaymentRounded },
      { path: "/social-credentials", title: "Social", icon: ShareRounded },
      { path: "/configs", title: "Configurations", icon: SettingsRounded },
    ],
  },

  {
    path: "/social",
    title: "Social Links",
    icon: InterestsRounded,
  },
  {
    path: "/settings",
    title: "Settings",
    icon: SettingsApplicationsRounded,
  },
];

export const paths = [
  "dashboard",
  "category",
  "sub-category",
  // "child-category",
  "brand",
  "product-management",
  "reports",
  "shop-management",
  "package-category",
  "package",
  "blogs",
  "blog-category",
  "pages",
  "faqs",
  "slider",
  "hero-section",
  "advertisement",
  "footer",
  "countries",
  // "cities",
  "states",
  "admins",
  "role-permission",
  "user-management",
  "buyer-approvals",
  "payment-credentials",
  "social-credentials",
  "currency",
  "transaction-history",
  "configs",
  "support-ticket",
  "client-query",
  "social",
  "settings",
] as const;

export default navItems;
