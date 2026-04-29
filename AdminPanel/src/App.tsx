import { useEffect } from "react";
import ResponsiveDrawer from "./components/drawer/Drawer";
import { useGetWebSettingsQuery } from "./redux/features/webSettings/webSettingsApi";
import ProtectedRoute from "./routes/ProtectedRoute";

const App = () => {
  const { data } = useGetWebSettingsQuery(undefined);

  useEffect(() => {
    if (data?.data.fav_icon) {
      const favicon = document.getElementById("favicon");
      if (favicon) {
        favicon.setAttribute(
          "href",
          `${import.meta.env.VITE_IMG_URL}/${data?.data.fav_icon}`
        );
      }
    }
  }, [data]);

  return (
    <ProtectedRoute>
      <ResponsiveDrawer />
    </ProtectedRoute>
  );
};

export default App;
