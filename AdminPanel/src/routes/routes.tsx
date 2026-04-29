import { createBrowserRouter } from "react-router-dom";
import Login from "../pages/Login";
import App from "../App";
import Home from "../pages/Home";
import PublicRoute from "./PublicRoute";
import SubCategory from "../pages/SubCategory";
import Category from "../pages/Category";
import Pages from "../pages/Pages";
import PaymentCredentials from "../pages/PaymentCredential";
import RolePermission from "../pages/RolePermission";
import CreateRolePermission from "../pages/CreateRolePermission";
import EditRolePermission from "../pages/EditRolePermission";
import Admins from "../pages/Admins";
import Package from "../pages/Package";
import Faq from "../pages/Faq";
import SocialCredential from "../pages/SocialCredential";
import Config from "../pages/Config";
import Social from "../pages/Social";
// import ChildCategory from "../pages/ChildCategory";
import BlogCategory from "../pages/BlogCategory";
import Slider from "../pages/Slider";
import Blogs from "../pages/Blogs";
import Brand from "../pages/Brand";
import Country from "../pages/Country";
// import City from "../pages/City";
import State from "../pages/State";
import Advertisement from "../pages/Advertisement";
import Footer from "../pages/Footer";
import HeroSection from "../pages/HeroSection";
import ShopManagement from "../pages/ShopManagement";
import ProductManagement from "../pages/ProductManagement";
import CardManagement from "../pages/CardManagement";
import PackageCategory from "../pages/PackageCategory";
import SupportTicket from "../pages/SupportTicket";
import TicketDetails from "../pages/TicketDetails";
import Settings from "../pages/Settings";
import Reports from "../pages/Reports";
import UserManagement from "../pages/UserManagement";
import UserAds from "../pages/UserAds";
import ClientQuery from "../pages/ClientQuery";
import Transaction from "../pages/Transaction";
import Currency from "../pages/Currency";
import BuyerApprovals from "../pages/BuyerApprovals";

const router = createBrowserRouter([
  {
    path: "/",
    element: <App />,
    children: [
      { index: true, element: <Home /> },
      { path: "category", element: <Category /> },
      { path: "sub-category", element: <SubCategory /> },
      // { path: "child-category", element: <ChildCategory /> },
      { path: "blog-category", element: <BlogCategory /> },
      { path: "blogs", element: <Blogs /> },
      { path: "brand", element: <Brand /> },
      { path: "countries", element: <Country /> },
      // { path: "cities", element: <City /> },
      { path: "states", element: <State /> },
      { path: "slider", element: <Slider /> },
      { path: "advertisement", element: <Advertisement /> },
      { path: "footer", element: <Footer /> },
      { path: "hero-section", element: <HeroSection /> },
      { path: "package-category", element: <PackageCategory /> },
      { path: "package", element: <Package /> },
      { path: "pages", element: <Pages /> },
      { path: "social", element: <Social /> },
      { path: "faqs", element: <Faq /> },
      { path: "shop-management", element: <ShopManagement /> },
      { path: "shop-management/:id", element: <UserAds /> },
      { path: "product-management", element: <ProductManagement /> },
      { path: "card-management", element: <CardManagement /> },
      { path: "role-permission", element: <RolePermission /> },
      {
        path: "role-permission/create",
        element: <CreateRolePermission />,
      },
      { path: "role-permission/:id", element: <EditRolePermission /> },
      { path: "admins", element: <Admins /> },
      { path: "payment-credentials", element: <PaymentCredentials /> },
      { path: "social-credentials", element: <SocialCredential /> },
      { path: "configs", element: <Config /> },
      { path: "support-ticket", element: <SupportTicket /> },
      { path: "support-ticket/:id", element: <TicketDetails /> },
      { path: "settings", element: <Settings /> },
      { path: "reports", element: <Reports /> },
      { path: "user-management", element: <UserManagement /> },
      { path: "user-management/:id", element: <UserAds /> },
      { path: "buyer-approvals", element: <BuyerApprovals /> },
      { path: "client-query", element: <ClientQuery /> },
      { path: "transaction-history", element: <Transaction /> },
      { path: "currency", element: <Currency /> },
    ],
  },
  {
    path: "/login",
    element: (
      <PublicRoute>
        <Login />
      </PublicRoute>
    ),
  },
]);

export default router;
