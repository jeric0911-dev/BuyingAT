import 'package:classified/controller/auth_controller.dart';
import 'package:classified/utils/app_color.dart';
import 'package:classified/utils/app_image.dart';
import 'package:classified/utils/app_text.dart';
import 'package:classified/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../transition/fade_transition.dart';
import '../../utils/app_fonts.dart';
import '../../widget/auth_widget/horizontal_divider_with_text.dart';
import '../../widget/auth_widget/social_button.dart';
import '../../widget/custom_text_field_widget.dart';

class SignInScreen extends StatelessWidget {
  final AuthController authController;

  const SignInScreen({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextFieldWidget(
            controller: authController.signInEmail,
            focusNode: authController.fSignInEmail,
            nextFocus: authController.fSignInPassword,
            showTitle: true,
            titleText: AppText.email,
            hintText: AppText.demoGmail,
            inputType: TextInputType.emailAddress,
          ),

          SizedBox(height: 18.h),
          CustomTextFieldWidget(
            controller: authController.signInPassword,
            focusNode: authController.fSignInPassword,
            showTitle: true,
            titleText: AppText.password,
            hintText: AppText.hintPassword,
            isPassword: true,
            inputType: TextInputType.visiblePassword,
          ),
          SizedBox(height: 13.h,),
          Obx(() {
            return Row(
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    authController.rememberMe.value =
                    !authController.rememberMe.value;
                  },
                  child: Padding(
                    padding: EdgeInsets.all(5.sp),
                    child: Container(
                      height: 13.h,
                      width: 13.h,
                      decoration: BoxDecoration(
                        color: authController.rememberMe.value
                            ? AppColor.buttonColor
                            : Colors.transparent,
                        border: Border.all(
                          color: authController.rememberMe.value
                              ? AppColor.buttonColor
                              : AppColor.coolGray4,
                          width: 2.sp,
                        ),
                      ),
                      child: authController.rememberMe.value
                          ? Center(child: SvgPicture.asset(AppImage.icCheck))
                          : null,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  AppText.rememberMe,
                  style: interMedium.copyWith(
                      fontSize: 14.sp,
                      color: AppColor.coolGray4,
                      height: 1.5.h,
                      letterSpacing: -.1
                  ),
                ),
                Spacer(),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    const FadeScreenTransition(
                      routeName: Routes.getOtpRoute).navigate();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.h),
                    child: Text(
                      AppText.forgotPassword,
                      style: interSemiBold.copyWith(
                          fontSize: 14.sp,
                          color: AppColor.buttonColor,
                          height: 1.4.h,
                          letterSpacing: -.1
                      ),
                    ),
                  ),
                ),

              ],
            );
          }),
          SizedBox(height: 23.h,),

          Obx(() {
            return CustomButton(
              isLoading: authController.isLoginLoading.value,
              marginRight: 0,
              marginLeft: 0,
              color:  authController.isSignInFormValid.value ? AppColor.buttonColor : AppColor.buttonColor.withValues(alpha: .5),
              text: AppText.logIn,
              borderColor: Colors.white,
              onPressed: authController.isSignInFormValid.value
                  ? () {
                authController.manualLogin();
              }
                  : null,
            );
          }),

          SizedBox(height: 40.h,),

          HorizontalDividerWithText(),
          SizedBox(height: 20.h,),

          SocialButton(onGooglePressed: (){
            authController.signIn();
          },),

          SizedBox(height: 30.h,),

        ],
      ),
    );
  }
}
