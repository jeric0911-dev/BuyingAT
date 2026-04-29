"use client";

import { useState } from "react";
import Image from "next/image";
import { Link, useTransitionRouter } from "next-view-transitions";
import { useForm } from "react-hook-form";
import { toast } from "sonner";
import {
  createUser,
  googleAuthLogin,
  loginUser,
  sendEmail,
} from "@/actions/auth";
import { success } from "@/constants";
import { useGoogleLogin } from "@react-oauth/google";
import { saveCart, saveUser, saveWishlist } from "@/utils/localStorage";

const Login = () => {
  const [active, setActive] = useState("in");
  const [loading, setLoading] = useState(false);
  const router = useTransitionRouter()
  const {
    register,
    reset,
    watch,
    handleSubmit,
    formState: { errors },
  } = useForm();

  const onSubmit = async (values) => {
    console.log('🔍 onSubmit: values', values);
    setLoading(true);
    const toastId = toast.loading("Verifying...");
    if (active === "in") {
      console.log('🔍 onSubmit: loginUser');
      const res = await loginUser(values);
      setLoading(false);
      if (res.status === success) {
        saveUser(res?.user);
        // Handle wishlist - ensure it's an array
        const wishlistArray = Array.isArray(res?.wishlist) 
          ? res.wishlist.map((item) => item.product_id)
          : [];
        saveWishlist(wishlistArray);
        
        // Handle cart - extract IDs from products, cards, or items
        let cartIds = [];
        if (Array.isArray(res?.cart)) {
          // If cart is an array, extract IDs
          cartIds = res.cart.map((item) => item.id || item.card_id || item.product_id);
        } else if (res?.cart?.items && Array.isArray(res.cart.items)) {
          // If cart has items array, extract IDs from items
          cartIds = res.cart.items.map((item) => item.id || item.card_id || item.product_id);
        } else if (res?.cart?.products && res?.cart?.cards) {
          // If cart has products and cards arrays, combine them
          const productIds = Array.isArray(res.cart.products) 
            ? res.cart.products.map((item) => item.id || item.product_id)
            : [];
          const cardIds = Array.isArray(res.cart.cards)
            ? res.cart.cards.map((item) => item.card_id || item.id)
            : [];
          cartIds = [...productIds, ...cardIds];
        }
        saveCart(cartIds);
        toast.success("Login successful.", { id: toastId });
        window.location.replace("/my-cards");
      } else {
        toast.error(res.message || "Something went wrong!", { id: toastId });
      }
    }
    if (active === "up") {
      console.log('🔍 onSubmit: createUser');
      const res = await createUser(values);
      setLoading(false);
      if (res.status === success) {
        saveUser(res?.user);
        // Handle wishlist - ensure it's an array
        const wishlistArray = Array.isArray(res?.wishlist) 
          ? res.wishlist.map((item) => item.product_id)
          : [];
        saveWishlist(wishlistArray);
        
        // Handle cart - extract IDs from products, cards, or items
        let cartIds = [];
        if (Array.isArray(res?.cart)) {
          // If cart is an array, extract IDs
          cartIds = res.cart.map((item) => item.id || item.card_id || item.product_id);
        } else if (res?.cart?.items && Array.isArray(res.cart.items)) {
          // If cart has items array, extract IDs from items
          cartIds = res.cart.items.map((item) => item.id || item.card_id || item.product_id);
        } else if (res?.cart?.products && res?.cart?.cards) {
          // If cart has products and cards arrays, combine them
          const productIds = Array.isArray(res.cart.products) 
            ? res.cart.products.map((item) => item.id || item.product_id)
            : [];
          const cardIds = Array.isArray(res.cart.cards)
            ? res.cart.cards.map((item) => item.card_id || item.id)
            : [];
          cartIds = [...productIds, ...cardIds];
        }
        saveCart(cartIds);
        toast.success("sign up successful.", { id: toastId });
        
        // Always redirect to buyer profile creation after signup
        router.push("/create-buyer-profile");
      } else {
        toast.error(res.error || "Something went wrong!", { id: toastId });
      }
    }
    if (active === "forget") {
      console.log('🔍 onSubmit: sendEmail');
      const res = await sendEmail(values);
      setLoading(false);
      if (res.status === success) {
        localStorage.setItem("email", JSON.stringify(values));
        toast.success(res.message, { id: toastId });
        router.push("/otp-verification");
      } else {
        toast.error(res.message || "Something went wrong!", { id: toastId });
      }
    }
  };

  const handleGoogleLogin = useGoogleLogin({
    onSuccess: async (tokenRes) => {
      try {
        const res = await fetch(
          "https://www.googleapis.com/oauth2/v3/userinfo",
          {
            headers: { Authorization: `Bearer ${tokenRes.access_token}` },
          }
        );
        const data = await res.json();
        if (Object.keys(data).length) {
          const res = await googleAuthLogin({
            email: data.email,
            google_id: data.sub,
            name: data.name,
          });
          if (res.status === "success") {
            saveUser(res?.user);
            // Handle wishlist - ensure it's an array
            const wishlistArray = Array.isArray(res?.wishlist) 
              ? res.wishlist.map((item) => item.product_id)
              : [];
            saveWishlist(wishlistArray);
            
            // Handle cart - extract IDs from products, cards, or items
            let cartIds = [];
            if (Array.isArray(res?.cart)) {
              // If cart is an array, extract IDs
              cartIds = res.cart.map((item) => item.id || item.card_id || item.product_id);
            } else if (res?.cart?.items && Array.isArray(res.cart.items)) {
              // If cart has items array, extract IDs from items
              cartIds = res.cart.items.map((item) => item.id || item.card_id || item.product_id);
            } else if (res?.cart?.products && res?.cart?.cards) {
              // If cart has products and cards arrays, combine them
              const productIds = Array.isArray(res.cart.products) 
                ? res.cart.products.map((item) => item.id || item.product_id)
                : [];
              const cardIds = Array.isArray(res.cart.cards)
                ? res.cart.cards.map((item) => item.card_id || item.id)
                : [];
              cartIds = [...productIds, ...cardIds];
            }
            saveCart(cartIds);
            toast.success("Login successful.");
            window.location.replace("/my-orders");
          }
        }
      } catch (error) {
        console.log(error);
      }
    },
  });


  return (
    <form
      onSubmit={handleSubmit(onSubmit)}
      className="w-full max-w-[424px] border border-border rounded shadow-[0_8px_40px_0px_rgba(0,0,0,0.12)] p-8 pt-0 mt-4"
    >
      <div className={`flex border-b -mx-8 ${active === "forget" && "hidden"}`}>
        <button
          type="button"
          onClick={() => {
            reset();
            setActive("in");
          }}
          className={`w-1/2 py-4 text-xl text-center font-semibold ${
            active === "in" ? "border-b-2 border-skyBlue" : "text-tGray"
          }`}
        >
          Sign In
        </button>
        <button
          type="button"
          onClick={() => {
            reset();
            setActive("up");
          }}
          className={`w-1/2 py-4 text-xl text-center font-semibold ${
            active === "up" ? "border-b-2 border-skyBlue" : "text-tGray"
          }`}
        >
          Sign Up
        </button>
      </div>
      {active === "in" && (
        <div>
          {/* --------------------emailField----------------- */}
          <label className="block mt-6 text-sm">
            Email Address
            <input
              {...register("email")}
              type="email"
              className="mt-2 input-input"
              placeholder="Enter your email"
              required
            />
          </label>
          {/* --------------------passwordField----------------- */}
          <label className="block mt-4 text-sm">
            <p className="flex justify-between">
              <span>Password</span>
              <span
                onClick={() => {
                  reset();
                  setActive("forget");
                }}
                className="text-skyBlue hover:scale-110 active:scale-95 transition-transform duration-200 font-medium cursor-pointer"
              >
                Forget Password
              </span>
            </p>
            <input
              {...register("password")}
              type="password"
              className="mt-2 input-input"
              placeholder="Enter your password"
              required
            />
          </label>
          {/* --------------------submitButton----------------- */}
          <button
            type="submit"
            style={{ "--hover-bg": `black`, "--hover-txt": "white" }}
            className="btn-hover-effect bg-skyBlue  text-white text-sm font-bold py-3 w-full rounded-sm flex items-center justify-center gap-2 mt-6 disabled:cursor-not-allowed"
            disabled={loading}
          >
            <span>SIGN IN</span>
            <Image
              src="/icon/right-arrow-white.svg"
              alt="#"
              width={20}
              height={20}
            />
          </button>
          <div className="flex items-center mt-6">
            <div className="flex-grow h-[1px] bg-border"></div>
            <div className="text-tGray text-sm  px-2">or</div>
            <div className="flex-grow h-[1px] bg-border"></div>
          </div>
          {/* --------------------googleButton----------------- */}
          <button
            onClick={handleGoogleLogin}
            type="button"
            className="w-full h-11 border border-border rounded-sm px-4 py-3 text-sm flex items-center mt-3"
          >
            <Image
              src="/icon/google-login.svg"
              alt="#"
              width={20}
              height={20}
            />
            <p className="flex-grow text-[#475156] text-center">
              Login with Google
            </p>
          </button>
        </div>
      )}
      {active === "up" && (
        <div>
          {/* --------------------nameField----------------- */}
          <label className="block mt-6 text-sm">
            Name
            <input
              {...register("name")}
              type="text"
              className="mt-2 input-input"
              placeholder="Enter your name"
              required
            />
          </label>
          {/* --------------------emailField----------------- */}
          <label className="block mt-6 text-sm">
            Email Address
            <input
              {...register("email")}
              type="email"
              className="mt-2 input-input"
              placeholder="Enter your email"
              required
            />
          </label>
          {/* --------------------passwordField----------------- */}
          <label className="block mt-4 text-sm">
            Password
            <input
              {...register("password")}
              type="password"
              className="mt-2 input-input"
              placeholder="8+ characters"
              required
            />
          </label>
          {/* --------------------confirmPasswordField----------------- */}
          <label className="block mt-4 text-sm">
            Confirm Password
            <input
              {...register("password_confirm", {
                required: true,
                validate: (p) =>
                  p === watch("password") || "Passwords do not match",
              })}
              type="password"
              className="mt-2 input-input"
              placeholder="**********"
              required
            />
            {errors.password_confirm && (
              <p className="text-red-500 text-xs">
                {errors.password_confirm.message}
              </p>
            )}
          </label>
          {/* --------------------terms&conditions----------------- */}
          <label className="text-sm text-[#475156] flex gap-2 mt-4">
            <input
              type="checkbox"
              className="form-checkbox border-border rounded-sm text-skyBlue focus:ring-0 mt-0.5"
              required
            />
            <p>
              Do you agree to the{" "}
              <Link href="/pages/terms-and-conditions" className="text-skyBlue">
                Terms and Conditions
              </Link>{" "}
              and{" "}
              <Link href="/pages/privacy-policy" className="text-skyBlue">
                Privacy Policy.
              </Link>
            </p>
          </label>
          {/* --------------------submitButton----------------- */}
          <button
            type="submit"
            style={{ "--hover-bg": `black`, "--hover-txt": "white" }}
            className="btn-hover-effect bg-skyBlue text-white text-sm font-bold py-3 w-full rounded-sm flex items-center justify-center gap-2 mt-6 disabled:cursor-not-allowed"
            disabled={loading}
          >
            <span>SIGN UP</span>
            <Image
              src="/icon/right-arrow-white.svg"
              alt="#"
              width={20}
              height={20}
            />
          </button>
          <div className="flex items-center mt-6">
            <div className="flex-grow h-[1px] bg-border"></div>
            <div className="text-tGray text-sm px-2">or</div>
            <div className="flex-grow h-[1px] bg-border"></div>
          </div>
          {/* --------------------googleButton----------------- */}
          <button
            onClick={handleGoogleLogin}
            type="button"
            className="w-full h-11 border border-border rounded-sm px-4 py-3 text-sm flex items-center mt-3"
          >
            <Image
              src="/icon/google-login.svg"
              alt="#"
              width={20}
              height={20}
            />
            <p className="flex-grow text-[#475156] text-center">
              Login with Google
            </p>
          </button>
        </div>
      )}
      {active === "forget" && (
        <div>
          <p className="mt-8 text-xl font-semibold text-center">
            Forget Password
          </p>
          <p className="mt-3 text-sm text-tGray text-center">
            Enter the email address or mobile phone number associated with your
            account.
          </p>
          {/* --------------------emailField----------------- */}
          <label className="block mt-6 text-sm">
            Email Address
            <input
              {...register("email")}
              type="email"
              className="mt-2 input-input"
              placeholder="Enter your email"
              required
            />
          </label>
          {/* --------------------submitButton----------------- */}
          <button
            type="submit"
            style={{ "--hover-bg": `black`, "--hover-txt": "white" }}
            className="btn-hover-effect bg-skyBlue hover:bg-skyBlueHover text-white text-sm font-bold py-3 w-full rounded-sm flex items-center justify-center gap-2 mt-6 disabled:cursor-not-allowed"
            disabled={loading}
          >
            <span>SEND CODE</span>
            <Image
              src="/icon/right-arrow-white.svg"
              alt="#"
              width={20}
              height={20}
            />
          </button>
          <p className="text-sm text-tGray mt-6">
            Already have account?{" "}
            <span
              onClick={() => {
                reset();
                setActive("in");
              }}
              className="text-skyBlue hover:underline underline-offset-4 transition-transform duration-200 cursor-pointer"
            >
              Sign In
            </span>
          </p>
          <p className="text-sm text-tGray mt-2">
            Don’t have account?{" "}
            <span
              onClick={() => {
                reset();
                setActive("up");
              }}
              className="text-skyBlue hover:underline underline-offset-4 transition-transform duration-200 cursor-pointer"
            >
              Sign Up
            </span>
          </p>
          <hr className="my-6" />
          <p className="text-sm text-tGray">
            You may contact{" "}
            <span className="text-skyBlue">Customer Service</span> for help
            restoring access to your account.
          </p>
        </div>
      )}
    </form>
  );
};

export default Login;
