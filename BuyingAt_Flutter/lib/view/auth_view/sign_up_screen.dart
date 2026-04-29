import 'package:classified/controller/auth_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../controller/more_page_controller.dart';
import '../../routes/app_routes.dart';
import '../../transition/fade_transition.dart';
import '../../utils/app_color.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_image.dart';
import '../../utils/app_text.dart';
import '../../widget/auth_widget/horizontal_divider_with_text.dart';
import '../../widget/auth_widget/social_button.dart';
import '../../widget/custom_button.dart';
import '../../widget/custom_text_field_widget.dart';

class SignUpScreen extends StatefulWidget {
  final AuthController authController;
  const SignUpScreen({super.key, required this.authController});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late MorePageController morePageController;

  @override
  void initState() {
    super.initState();
    morePageController = Get.find<MorePageController>();
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextFieldWidget(
            controller: widget.authController.signUpName,
            focusNode: widget.authController.fSignUpName,
            nextFocus: widget.authController.fSignUpEmail,
            showTitle: true,
            titleText: AppText.name,
            hintText: AppText.name,
            inputType: TextInputType.text,
          ),

          SizedBox(height: 18.h),
          CustomTextFieldWidget(
            controller: widget.authController.signUpEmail,
            focusNode: widget.authController.fSignUpEmail,
            nextFocus: widget.authController.fSignUpPassword,
            showTitle: true,
            titleText: AppText.email,
            hintText: AppText.demoGmail,
            inputType: TextInputType.emailAddress,
          ),

          SizedBox(height: 18.h,),
          CustomTextFieldWidget(
            controller: widget.authController.signUpPassword,
            focusNode: widget.authController.fSignUpPassword,
            nextFocus: widget.authController.fSignUpConfirmPassword,
            showTitle: true,
            isPassword: true,
            titleText: AppText.setPassword,
            hintText: AppText.setPassword,
            inputType: TextInputType.visiblePassword,
          ),

          SizedBox(height: 18.h),
          CustomTextFieldWidget(
            controller: widget.authController.signUpConfirmPassword,
            focusNode: widget.authController.fSignUpConfirmPassword,
            showTitle: true,
            titleText: AppText.confirmPassword,
            hintText: AppText.confirmPassword,
            isPassword: true,
            inputType: TextInputType.visiblePassword,
          ),

          SizedBox(height: 23.h,),
          Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    widget.authController.toggleAgreeTerms();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 5.h, right: 8.w),
                    child: Container(
                      height: 20.h,
                      width: 20.h,
                      decoration: BoxDecoration(
                        color: widget.authController.agreeTerms.value
                            ? AppColor.buttonColor
                            : Colors.transparent,
                        border: Border.all(
                          color: widget.authController.agreeTerms.value
                              ? AppColor.buttonColor
                              : AppColor.coolGray4,
                          width: 2.sp,
                        ),
                      ),
                      child: widget.authController.agreeTerms.value
                          ? Center(child: SvgPicture.asset(AppImage.icCheck))
                          : null,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: AppText.areYouAgreeTxt,
                      style: sansReg.copyWith(fontSize: 14.sp,height: 1.42.h,color: AppColor.coolGray9),
                      children: [
                        TextSpan(
                          text: AppText.termsAndConditions,
                          style: sansMedium.copyWith(
                            color: AppColor.buttonColor,
                              fontSize: 14.sp,height: 1.42.h
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              final termsPage = morePageController.morePageList
                                  .firstWhereOrNull((s) => s.slug == "terms-and-conditions");

                              if (termsPage != null) {
                                FadeScreenTransition(
                                  routeName: Routes.morePageScreenRoute,
                                  arguments: {
                                    "title": termsPage.title.toString(),
                                    "value": termsPage,
                                  },
                                ).navigate();
                              }

                            },
                        ),
                        TextSpan(text: AppText.and),
                        TextSpan(
                          text: AppText.privacyPolicy,
                          style: sansReg.copyWith(
                            color: AppColor.buttonColor,
                              fontSize: 14.sp,height: 1.42.h
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              final privacyPage = morePageController.morePageList
                                  .firstWhereOrNull((s) => s.slug == "privacy-policy");

                              if (privacyPage != null) {
                                FadeScreenTransition(
                                  routeName: Routes.morePageScreenRoute,
                                  arguments: {
                                    "title": privacyPage.title.toString(),
                                    "value": privacyPage,
                                  },
                                ).navigate();
                              }
                            },
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            );
          }),

          SizedBox(height: 23.h,),
          Obx(() {
            var isLoading =widget.authController.isSignUpFormValid.value;
            return CustomButton(
              isLoading: widget.authController.isLoginLoading.value,
              marginRight: 0,
              marginLeft: 0,
              color: isLoading  ? AppColor.buttonColor : AppColor.buttonColor.withValues(alpha: .5),
              text: AppText.register,
              borderColor: Colors.white,
              onPressed: isLoading
                  ? () {
                widget.authController.manualSignUp();
              }
                  : null,
            );
          }),

          SizedBox(height: 40.h,),

          HorizontalDividerWithText(),

          SizedBox(height: 20.h,),

          SocialButton(onGooglePressed: (){
            widget.authController.signIn();
          },),

          SizedBox(height: 30.h,),

        ],
      ),
    );
  }
}
