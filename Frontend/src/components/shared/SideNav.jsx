"use client";

import { logoutUser } from "@/actions/auth";
import { navItemsSeller, navItemsBuyer, success } from "@/constants";
import { Link, useTransitionRouter } from "next-view-transitions";
import { usePathname } from "next/navigation";
import { toast } from "sonner";
import { MdOutlineLogout } from "react-icons/md";
import { useState, useEffect } from "react";

const SideNav = ({ user }) => {
  const path = usePathname();
  const router = useTransitionRouter();
  const [activeMenu, setActiveMenu] = useState("primary");
  
  // Check user role to determine which menus to show
  const userRole = user?.role || 'seller';
  const isBuyer = userRole === 'buyer';
  
  // Automatically set activeMenu based on current path
  useEffect(() => {
    // Check if current path belongs to buyer menu
    const buyerMenuLinks = navItemsBuyer.map(item => item.link);
    const isBuyerPath = buyerMenuLinks.some(link => path === link || path.startsWith(link + '/'));
    
    if (isBuyerPath && isBuyer) {
      setActiveMenu("secondary");
    } else {
      setActiveMenu("primary");
    }
  }, [path, isBuyer]);
  
  // Debug logging
  console.log('🔍 SideNav Debug:', {
    user: user,
    userRole: userRole,
    isBuyer: isBuyer,
    userRoleType: typeof userRole,
    path: path,
    activeMenu: activeMenu
  });

  const handleLogout = async () => {
    const toastId = toast.loading("Logging out...");
    const res = await logoutUser();
    if (res.status === success) {
      toast.success(res.message, { id: toastId });
      router.push("/");
    } else {
      toast.error(res.message || "Something went wrong! Try again", {
        id: toastId,
      });
    }
  };

  const renderMenuItems = (menuId) => {
    // Use different menu items based on menuId
    const menuItems = menuId === "primary" ? navItemsSeller : navItemsBuyer;
    
    return menuItems.map(({ icon, label, link }) => {
      const isVendor = user?.user_type === "vendor";
      const adjustedLink =
        isVendor && link === "/my-cards" ? "/my-shop" : link;
      const adjustedLabel =
        isVendor && link === "/my-cards" ? "My Shop" : label;
      // Check if path matches this link
      const pathMatches = path === adjustedLink || path.startsWith(adjustedLink + '/');
      // Show active state if path matches AND it's in the correct menu section
      const isActive = pathMatches && menuId === activeMenu;
      
      const handleClick = () => {
        setActiveMenu(menuId);
      };
      
      return (
        <Link
          key={`${menuId}-${adjustedLink}`}
          href={adjustedLink}
          onClick={handleClick}
          className={`flex items-center gap-3 px-6 py-2  ${
            isActive
              ? "bg-skyBlue text-white"
              : "hover:bg-skyBlue/30 text-tGray hover:text-skyBlue"
          }`}
        >
          {icon}
          <span className={`text-sm font-semibold`}>{adjustedLabel}</span>
        </Link>
      );
    });
  };

  return (
    <aside className="border border-border shadow-lg rounded hidden lg:flex flex-col h-max md:sticky md:top-10">
      {/* Seller Menu - Always shown */}
      <div>
        <h3 className="text-lg font-bold text-skyBlue px-6 py-2 bg-skyBlue/10 border-t-2 border-skyBlue border-b border-skyBlue/20 text-center">
          Seller
        </h3>
        {renderMenuItems("primary")}
      </div>

      {/* Buyer Menu - Only shown if user role is 'buyer' */}
      {isBuyer && (
        <>
          {/* Separator */}
          <div className="border-t border-border my-2"></div>

          {/* Buyer Menu */}
          <div>
            <h3 className="text-lg font-bold text-skyBlue px-6 py-2 bg-skyBlue/10 border-t-2 border-skyBlue border-b border-skyBlue/20 text-center">
              Buyer
            </h3>
            {renderMenuItems("secondary")}
          </div>
        </>
      )}
      
      {/* Logout Button - Single logout button at the bottom */}
      <div className="border-t border-border my-2"></div>
      <button
        onClick={handleLogout}
        type="button"
        className="flex items-center gap-3 px-6 py-2 text-tGray hover:text-red-400 hover:bg-skyBlue/30 group"
      >
        <MdOutlineLogout size={20} />
        <span className=" text-sm font-semibold">Log-out</span>
      </button>
    </aside>
  );
};

export default SideNav;
