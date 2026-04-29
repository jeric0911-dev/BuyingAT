import { paths } from "../constants";
import { selectCurrentUser } from "../redux/features/auth/authSlice";
import { useAppSelector } from "../redux/hooks";

const GetPermission = (name: (typeof paths)[number]) => {
  const user = useAppSelector(selectCurrentUser);
  const permission = user?.admin_type.role_parameters.find(
    (item) => item.name === name
  );
  return permission;
};

export default GetPermission;
