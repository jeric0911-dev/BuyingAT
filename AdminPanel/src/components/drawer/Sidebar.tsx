import React, { useCallback, useEffect, useState } from "react";
import {
  Box,
  List,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Collapse,
  Stack,
  SvgIcon,
  Typography,
} from "@mui/material";
import { ExpandLess, ExpandMore } from "@mui/icons-material";
import navItems, { TNavItem } from "../../constants/navItems";
import { NavLink, useLocation } from "react-router-dom";
import { useGetWebSettingsQuery } from "../../redux/features/webSettings/webSettingsApi";

type PathMap = {
  [key: string]: number | undefined;
};

const pathToSubmenu: PathMap = {
  "/category": 1,
  "/sub-category": 1,
  "/child-category": 1,
  "/brand": 1,
  "/product-management": 1,
  "/reports": 1,
  "/shop-management": 2,
  "/package-category": 2,
  "/package": 2,
  "/currency": 3,
  "/transaction-history": 3,
  "/blogs": 4,
  "/blog-category": 4,
  "/pages": 4,
  "/faqs": 4,
  "/slider": 5,
  "/hero-section": 5,
  "/advertisement": 5,
  "/footer": 5,
  "/countries": 6,
  "/cities": 6,
  "/states": 6,
  "/admins": 7,
  "/role-permission": 7,
  "/user-management": 7,
  "/support-ticket": 8,
  "/client-query": 8,
  "/configs": 9,
  "/payment-credentials": 9,
  "/social-credentials": 9,
};

const NavListItem = React.memo(
  ({
    item,
    isActive,
    isSubItem,
    onClick,
  }: {
    item: TNavItem;
    isActive: boolean;
    isSubItem?: boolean;
    onClick?: () => void;
  }) => {
    return (
      <ListItem
        disablePadding
        sx={{
          bgcolor: isActive && !isSubItem ? "primary.main" : "white",
          "&:hover": {
            bgcolor: isActive && !isSubItem ? "primary.main" : "primary.light",
            borderRadius: "10px",
          },
          borderRadius: "10px",
          mb: 1,
        }}
      >
        <ListItemButton
          onClick={onClick}
          sx={{ pl: isSubItem ? 4 : 2, borderRadius: "10px" }}
          aria-label={item.title}
        >
          <ListItemIcon sx={{ minWidth: "38px" }}>
            <SvgIcon
              component={item.icon}
              sx={{
                color:
                  isActive && !isSubItem
                    ? "white"
                    : isActive && isSubItem
                    ? "primary.main"
                    : "text.secondary",
              }}
            />
          </ListItemIcon>
          <ListItemText
            primary={
              <Typography
                fontWeight="600"
                color={
                  isActive && !isSubItem
                    ? "white"
                    : isActive && isSubItem
                    ? "primary.main"
                    : "text.secondary"
                }
              >
                {item.title}
              </Typography>
            }
          />
          {item.subItems &&
            (isActive ? (
              <ExpandLess sx={{ color: "white" }} />
            ) : (
              <ExpandMore />
            ))}
        </ListItemButton>
      </ListItem>
    );
  }
);

const Sidebar = () => {
  const { data } = useGetWebSettingsQuery(undefined);
  const { pathname } = useLocation();
  const [openSubmenu, setOpenSubmenu] = useState<number | null>(null);

  const toggleSubmenu = useCallback((index: number) => {
    setOpenSubmenu((prev) => (prev === index ? null : index));
  }, []);

  useEffect(() => {
    const matchedKey = Object.keys(pathToSubmenu).find((key) =>
      pathname.startsWith(key)
    );
    setOpenSubmenu(
      matchedKey && pathToSubmenu[matchedKey] !== undefined
        ? pathToSubmenu[matchedKey]!
        : null
    );
  }, [pathname]);

  return (
    <Box sx={{ bgcolor: "white", height: "100vh", px: "16px" }}>
      <Stack height={64} justifyContent="center" alignItems="center">
        <img
          src={`${import.meta.env.VITE_IMG_URL}/${data?.data.web_app_logo}`}
          alt="Logo"
          style={{ maxWidth: "90%" }}
        />
      </Stack>
      <List>
        {navItems.map((item, index) => (
          <React.Fragment key={index}>
            {item.subItems ? (
              <>
                <NavListItem
                  item={item}
                  isActive={openSubmenu === index}
                  onClick={() => toggleSubmenu(index)}
                />
                <Collapse in={openSubmenu === index} timeout="auto">
                  <List disablePadding>
                    {item.subItems.map((subItem) => (
                      <NavLink
                        key={subItem.path}
                        to={subItem.path as string}
                        style={{ textDecoration: "none" }}
                      >
                        {({ isActive }) => (
                          <NavListItem
                            item={subItem}
                            isActive={isActive}
                            isSubItem
                          />
                        )}
                      </NavLink>
                    ))}
                  </List>
                </Collapse>
              </>
            ) : (
              <NavLink
                key={item.path}
                to={item.path as string}
                style={{ textDecoration: "none" }}
              >
                {({ isActive }) => (
                  <NavListItem item={item} isActive={isActive} />
                )}
              </NavLink>
            )}
          </React.Fragment>
        ))}
      </List>
    </Box>
  );
};

export default Sidebar;
