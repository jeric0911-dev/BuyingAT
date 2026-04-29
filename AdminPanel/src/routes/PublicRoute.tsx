import { Navigate } from "react-router-dom";
import { useAppSelector } from "../redux/hooks";
import { selectCurrentToken } from "../redux/features/auth/authSlice";

const PublicRoute = ({ children }: { children: React.ReactNode }) => {
  const token = useAppSelector(selectCurrentToken);

  if (token) {
    return <Navigate to="/" replace={true} />;
  }

  return children;
};

export default PublicRoute;
