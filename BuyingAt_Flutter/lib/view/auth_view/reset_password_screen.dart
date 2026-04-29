import 'package:classified/utils/app_color.dart';
import 'package:classified/utils/app_fonts.dart';
import 'package:classified/utils/app_image.dart';
import 'package:classified/utils/app_text.dart';
import 'package:classified/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controller/auth_controller.dart';
import '../../widget/custom_text_field_widget.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late AuthController authController;

  @override
  void initState() {
    super.initState();
    authController = Get.find<AuthController>();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 27.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 226.h,),
              Text(AppText.resetPassword, style: interBold.copyWith(
                  fontSize: 28.sp,
                  height: 1.30.h,
                  color: AppColor.textColor,
                  letterSpacing: -.2), textAlign: TextAlign.center,),
              SizedBox(height: 8.h,),
              Text(AppText.resetPasswordMsg, style: interReg.copyWith(
                  fontSize: 14.sp,
                  height: 1.50.h,
                  color: AppColor.coolGray4,
                  letterSpacing: -.1), textAlign: TextAlign.center,),
              SizedBox(height: 48.h,),

              CustomTextFieldWidget(
                controller: authController.resetPassword,
                focusNode: authController.fResetPassword,
                nextFocus: authController.fResetConfirmPassword,
                showTitle: true,
                titleText: AppText.password,
                hintText: AppText.password,
                inputType: TextInputType.visiblePassword,
                isPassword: true,
              ),

              SizedBox(height: 19.h),
              CustomTextFieldWidget(
                controller: authController.resetConfirmPassword,
                focusNode: authController.fResetConfirmPassword,
                showTitle: true,
                titleText: AppText.confirmPassword,
                hintText: AppText.confirmPassword,
                inputType: TextInputType.visiblePassword,
                isPassword: true,
              ),

              SizedBox(height: 40.h,),

              Obx(() {
                final isEnabled = authController.isResetPasswordFormValid.value;
                return CustomButton(
                  marginRight: 0,
                  marginLeft: 0,
                  color: isEnabled
                      ? AppColor.buttonColor
                      : AppColor.buttonColor.withValues(alpha: 0.5),
                  isLoading: authController.isRestPasswordLoading.value,
                  text: AppText.resetPassword.toUpperCase(),
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
                    authController.resetPass();
                  } : null,
                );
              }),
              SizedBox(height: 20.h,),
            ],
          ),
        ),
      ),
    );
  }
}
