import 'package:classified/utils/app_color.dart';
import 'package:classified/utils/app_fonts.dart';
import 'package:classified/utils/app_image.dart';
import 'package:classified/utils/app_text.dart';
import 'package:classified/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../controller/auth_controller.dart';
import '../../widget/custom_loader.dart';

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({super.key});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {

  late AuthController authController;

  @override
  void initState() {
    super.initState();
    authController = Get.find<AuthController>();
  }


  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 42.h,
      height: 44.h,
      textStyle: sansExtraBold.copyWith(
          fontSize: 24.sp,
          height: .90.h,
          color: AppColor.buttonColor
      ),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
    );


    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border(
        bottom: BorderSide(width: 2, color: AppColor.buttonColor),
      ),

    );
    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border(
        bottom: BorderSide(width: 2, color: AppColor.buttonColor),
      ),

    );
    final followingPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border(
        bottom: BorderSide(width: .9, color: AppColor.coolGray10),
      ),

    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 27.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 226.h,),
              Text(AppText.otpVerification, style: interBold.copyWith(
                  fontSize: 28.sp,
                  height: 1.30.h,
                  color: AppColor.textColor,
                  letterSpacing: -.2), textAlign: TextAlign.center,),
              SizedBox(height: 8.h,),
              Text(AppText.enterYourEmailMsg, style: interReg.copyWith(
                  fontSize: 14.sp,
                  height: 1.50.h,
                  color: AppColor.coolGray4,
                  letterSpacing: -.1),),
              SizedBox(height: 20.h,),
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Padding(
                  padding: EdgeInsets.all(4.sp),
                  child: Text(AppText.editEmail, style: sansBold.copyWith(
                    fontSize: 16.sp,
                    height: 1.42.h,
                    color: AppColor.textColor,),),
                ),
              ),


              SizedBox(height: 36.h,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 42.w),
                child: Pinput(
                  length: 4,
                  controller: authController.otpController,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  followingPinTheme: followingPinTheme,
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  showCursor: true,
                  autofocus: true,
                ),
              ),

              SizedBox(height: 34.h,),
              Obx(() {
                final seconds = authController.otpTimer.value;
                final minutesStr = (seconds ~/ 60).toString().padLeft(2, '0');
                final secondsStr = (seconds % 60).toString().padLeft(2, '0');
                return Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '($minutesStr:$secondsStr)',
                        style: sansBold.copyWith(color: AppColor.buttonColor,
                            height: 2.h,
                            fontSize: 16.sp),
                      ),
                      TextSpan(
                        text: ' ',
                      ),
                      TextSpan(
                        text: AppText.doNotReceiveOtp,
                        style: sansReg.copyWith(color: AppColor.textColor,
                            height: 2.h,
                            fontSize: 16.sp),
                      ),
                    ],
                  ),
                );
              }),
              Obx(() {
                final canResend = authController.otpTimer.value == 0 &&
                    authController.isSendResetOtpFormValid.value;
                return authController.isReSendOtpLoading.value
                    ? CustomLoader(size: 20.sp)
                    : InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: canResend
                      ? () {
                    authController.sendResetOtp();
                  }
                      : null,
                  child: Text(
                    AppText.resendOTP,
                    style: sansBold.copyWith(
                      color: AppColor.buttonColor.withValues(alpha:  canResend
                          ? 1.0
                          : 0.5),
                      fontSize: 16.sp,
                      height: 2.h,
                    ),
                  ),
                );
              }),

              SizedBox(height: 40.h,),
              Obx(() {
                final isEnabled = authController.isVerifyOtpFormValid.value;
                return CustomButton(
                  marginRight: 0,
                  marginLeft: 0,
                  isLoading: authController.isVerifyOtpLoading.value,
                  color: isEnabled ? AppColor.buttonColor : AppColor.buttonColor.withValues(alpha: 0.5),
                  text: AppText.verify,
                  textStyle: sansBold.copyWith(
                    fontSize: 14.sp,
                    height: 3.h,
                    letterSpacing: .12,
                    color: AppColor.white,
                  ),
                  textIconWidth: 12.w,
                  trailing: SvgPicture.asset(
                    AppImage.icArrowRight, height: 20.h,),
                  onPressed: isEnabled ? () {
                    authController.verifyOtp();
                  } : null,
                );
              }),
              SizedBox(height: 40.h,),

            ],
          ),
        ),
      ),
    );
  }
}
