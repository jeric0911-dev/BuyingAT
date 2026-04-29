import * as React from "react";
import AppBar from "@mui/material/AppBar";
import Box from "@mui/material/Box";
import Drawer from "@mui/material/Drawer";
import IconButton from "@mui/material/IconButton";
import MenuIcon from "@mui/icons-material/Menu";
import Toolbar from "@mui/material/Toolbar";
import Typography from "@mui/material/Typography";
import Sidebar from "./Sidebar";
import { Stack } from "@mui/material";
import AccountMenu from "./AccountMenu";
import { Outlet } from "react-router-dom";
import { useAppSelector } from "../../redux/hooks";
import { selectCurrentUser } from "../../redux/features/auth/authSlice";
import { useGetWebSettingsQuery } from "../../redux/features/webSettings/webSettingsApi";

const drawerWidth = 300;

const ResponsiveDrawer = () => {
  const [mobileOpen, setMobileOpen] = React.useState(false);
  const [isClosing, setIsClosing] = React.useState(false);
  const user = useAppSelector(selectCurrentUser);
  const { data } = useGetWebSettingsQuery(undefined);

  const handleDrawerClose = () => {
    setIsClosing(true);
    setMobileOpen(false);
  };

  const handleDrawerTransitionEnd = () => {
    setIsClosing(false);
  };

  const handleDrawerToggle = () => {
    if (!isClosing) {
      setMobileOpen(!mobileOpen);
    }
  };

  return (
    <Box sx={{ display: "flex", width: "100%", maxWidth: "100vw" }}>
      <AppBar
        position="fixed"
        sx={{
          width: { md: `calc(100% - ${drawerWidth}px)` },
          ml: { md: `${drawerWidth}px` },
          bgcolor: "white",
          boxShadow: "none",
          borderBottom: "1px solid #E0E0E0",
        }}
      >
        <Toolbar>
          <Box sx={{ display: { md: "none" } }}>
            <img
              src={`${import.meta.env.VITE_IMG_URL}/${data?.data?.fav_icon}`}
              width={32}
              style={{ marginTop: 6 }}
            />
          </Box>
          <IconButton
            aria-label="open drawer"
            edge="start"
            onClick={handleDrawerToggle}
            sx={{ mx: 1, display: { md: "none" } }}
          >
            <MenuIcon sx={{ color: "text.primary" }} />
          </IconButton>
          <Stack direction="row" alignItems="center" ml="auto">
            <Typography variant="body2">{user?.username}</Typography>
            <AccountMenu />
          </Stack>
        </Toolbar>
      </AppBar>
      <Box
        component="nav"
        sx={{ width: { md: drawerWidth }, flexShrink: { md: 0 } }}
        aria-label="menu options"
      >
        <Drawer
          variant="temporary"
          open={mobileOpen}
          onTransitionEnd={handleDrawerTransitionEnd}
          onClose={handleDrawerClose}
          ModalProps={{
            keepMounted: true,
          }}
          sx={{
            display: { xs: "block", md: "none" },
            "& .MuiDrawer-paper": {
              boxSizing: "border-box",
              width: drawerWidth,
            },
          }}
        >
          <Sidebar />
        </Drawer>
        <Drawer
          variant="permanent"
          sx={{
            display: { xs: "none", md: "block" },
            "& .MuiDrawer-paper": {
              boxSizing: "border-box",
              width: drawerWidth,
            },
          }}
          open
        >
          <Sidebar />
        </Drawer>
      </Box>
      <Box
        component="main"
        sx={{
          flexGrow: 1,
          p: 3,
          width: { md: `calc(100% - ${drawerWidth}px)`, xs: "100%" },
          minHeight: "100vh",
          bgcolor: "#F8F9FA",
        }}
      >
        <Toolbar />
        <Outlet />
      </Box>
    </Box>
  );
};

export default ResponsiveDrawer;
