"use client";

import { otpVerification } from "@/actions/auth";
import Container from "@/components/shared/Container";
import { success } from "@/constants";
import Image from "next/image";
import { Link, useTransitionRouter } from "next-view-transitions";
import { useEffect, useRef, useState } from "react";
import { toast } from "sonner";

const OtpVerificationPage = () => {
  const [otp, setOtp] = useState(Array(4).fill(""));
  const [timer, setTimer] = useState(600);
  const [loading, setLoading] = useState(false);
  const inputRefs = useRef([]);
  const router = useTransitionRouter()

  useEffect(() => {
    if (timer === 0) return;
    const intervalId = setInterval(() => {
      setTimer((p) => p - 1);
    }, 1000);
    return () => clearInterval(intervalId);
  }, [timer]);

  const handleKeyDown = (e) => {
    if (
      !/^[0-9]{1}$/.test(e.key) &&
      e.key !== "Backspace" &&
      e.key !== "Delete" &&
      e.key !== "Tab" &&
      !e.metaKey
    ) {
      e.preventDefault();
    }

    if (e.key === "Delete" || e.key === "Backspace") {
      const index = inputRefs.current.indexOf(e.target);
      if (index > 0) {
        setOtp((prevOtp) => [
          ...prevOtp.slice(0, index - 1),
          "",
          ...prevOtp.slice(index),
        ]);
        inputRefs.current[index - 1]?.focus();
      }
    }
  };

  const handleInput = (e) => {
    const { target } = e;
    const index = inputRefs.current.indexOf(target);
    if (target.value) {
      setOtp((prevOtp) => [
        ...prevOtp.slice(0, index),
        target.value,
        ...prevOtp.slice(index + 1),
      ]);
      if (index < otp.length - 1) {
        inputRefs.current[index + 1]?.focus();
      }
    }
  };

  const handleFocus = (e) => {
    e.target.select();
  };

  const handlePaste = (e) => {
    e.preventDefault();
    const text = e.clipboardData.getData("text");
    if (!new RegExp(`^[0-9]{${otp.length}}$`).test(text)) {
      return;
    }
    const digits = text.split("");
    setOtp(digits);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    const toastId = toast.loading("Verifying...");
    const res = await otpVerification({
      otp: otp.join(""),
      email: JSON.parse(localStorage.getItem("email"))?.email,
    });
    setLoading(false);
    if (res.status === success) {
      toast.success(res.message, { id: toastId });
      localStorage.setItem("otp", JSON.stringify(otp.join("")));
      router.replace("/reset-password");
    } else {
      toast.error(res.message || "Something went wrong!", { id: toastId });
    }
  };

  const isOtpComplete = otp.every((digit) => digit !== "");

  return (
    <section>
      <Container>
        <div className="min-h-[calc(100vh-220px)] flex justify-center items-center">
          <div className="w-full max-w-[424px] border border-border rounded shadow-[0_8px_40px_0px_rgba(0,0,0,0.12)] p-8 pt-0 mt-4">
            <p className="mt-8 text-xl font-semibold text-center">
              OTP Verification
            </p>
            <p className="mt-3 text-sm text-tGray text-center">
              Enter OTP Sent to Your Email
            </p>
            <Link href="/login" className="mt-3 block font-bold text-center">
              Edit email
            </Link>
            <form className="mt-10 w-full" onSubmit={handleSubmit}>
              <div className="flex gap-10 justify-center">
                {otp.map((digit, index) => (
                  <input
                    key={index}
                    type="text"
                    maxLength={1}
                    value={digit}
                    onChange={handleInput}
                    onKeyDown={handleKeyDown}
                    onFocus={handleFocus}
                    onPaste={handlePaste}
                    ref={(el) => {
                      inputRefs.current[index] = el;
                    }}
                    className={`w-11 border-b focus:border-b-2 focus:border-b-skyBlue p-2 text-center text-2xl font-black text-skyBlue outline-none ${
                      digit && "border-skyBlue"
                    }`}
                  />
                ))}
              </div>
              <p className="mt-8 text-center">
                <span className="text-skyBlue font-black">( {timer}s )</span>{" "}
                Didn&apos;t receive the OTP?
              </p>
              <p className="font-bold text-skyBlue text-center mt-1">
                Resend OTP
              </p>
              <button
                type="submit"
                className="bg-skyBlue hover:bg-skyBlueHover text-white text-sm font-bold py-3 w-full rounded-sm flex items-center disabled:cursor-not-allowed justify-center gap-2 mt-10"
                disabled={loading || !isOtpComplete}
              >
                <span>VERIFY</span>
                <Image
                  src="/icon/right-arrow-white.svg"
                  alt="#"
                  width={20}
                  height={20}
                />
              </button>
            </form>
          </div>
        </div>
      </Container>
    </section>
  );
};

export default OtpVerificationPage;
