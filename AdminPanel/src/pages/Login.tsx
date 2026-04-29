import { Box, Button, Stack, Typography } from "@mui/material";
import RCForm from "../components/form/RCForm";
import { FieldValues, SubmitHandler } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import RCInput from "../components/form/RCInput";
import bg from "../assets/images/loginBg.svg";
import { LoginValidation } from "../schemas";
import { useLoginMutation } from "../redux/features/auth/authApi";
import { useAppDispatch } from "../redux/hooks";
import { login } from "../redux/features/auth/authSlice";
import handleAsyncToast from "../utils/handleAsyncToast";
import { useGetWebSettingsQuery } from "../redux/features/webSettings/webSettingsApi";
import HeaderTitle from "../components/seo/HeaderTitle";
import { useEffect } from "react";

const Login = () => {
  const { data } = useGetWebSettingsQuery(undefined);
  const [loginUser, { isLoading }] = useLoginMutation();
  const dispatch = useAppDispatch();

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

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    await handleAsyncToast({
      promise: loginUser(values).unwrap(),
      success: (res) => {
        dispatch(login({ user: res.data.admin, token: res.data.token }));
        return "Logged in successfully";
      },
    });
  };

  return (
    <>
      <HeaderTitle title="Login" />
      <Stack
        justifyContent="center"
        alignItems="center"
        minHeight="100vh"
        sx={{
          background: `url(${bg}) center / cover no-repeat`,
        }}
      >
        <Box
          width="100%"
          maxWidth="400px"
          bgcolor="white"
          p="32px"
          pt="24px"
          border="1px solid #E0E2E7"
          borderRadius="10px"
          sx={{ boxShadow: "0px 20px 30px 0px #1018280F" }}
        >
          <Stack justifyContent="center" alignItems="center">
            <img
              src={`${import.meta.env.VITE_IMG_URL}/${
                data?.data?.web_app_logo
              }`}
              alt="logo"
              style={{ maxWidth: "50%" }}
            />
          </Stack>
          <Typography
            mt={2}
            fontSize="20px"
            fontWeight="500"
            color="#030229"
            textAlign="center"
            mb="36px"
          >
            {data?.data?.login_page_title}
          </Typography>
          <RCForm
            onSubmit={onSubmit}
            resolver={zodResolver(LoginValidation)}
            defaultValues={{ email: "", password: "" }}
          >
            <RCInput
              name="email"
              label="Email or User Name"
              placeholder="admin"
            />
            <RCInput
              name="password"
              type="password"
              label="Password"
              placeholder="********"
              sx={{ mt: "16px" }}
            />
            <Button
              type="submit"
              sx={{ mt: "28px", width: "100%" }}
              disabled={isLoading}
            >
              LOGIN
            </Button>
          </RCForm>
        </Box>
      </Stack>
    </>
  );
};

export default Login;
