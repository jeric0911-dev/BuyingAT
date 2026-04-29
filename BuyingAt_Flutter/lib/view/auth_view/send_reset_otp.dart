import 'package:classified/controller/auth_controller.dart';
import 'package:classified/utils/app_color.dart';
import 'package:classified/utils/app_fonts.dart';
import 'package:classified/utils/app_image.dart';
import 'package:classified/utils/app_text.dart';
import 'package:classified/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../widget/custom_text_field_widget.dart';

class SendResetOtp extends StatefulWidget {
  const SendResetOtp({super.key});

  @override
  State<SendResetOtp> createState() => _SendResetOtpState();
}

class _SendResetOtpState extends State<SendResetOtp> {

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
              Text(AppText.enterYourEmail, style: interBold.copyWith(
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
              SizedBox(height: 68.h,),
          
              CustomTextFieldWidget(
                 controller: authController.sendResetOtpEmail,
                 focusNode: authController.fSendResetOtpEmail,
                showTitle: true,
                titleText: AppText.email,
                hintText: AppText.demoGmail,
                inputType: TextInputType.emailAddress,
              ),
          
              SizedBox(height: 40.h,),
          
              Obx(() {
                final isEnabled = authController.isSendResetOtpFormValid.value;
                return CustomButton(
                  marginRight: 0,
                  marginLeft: 0,
                  isLoading: authController.isSendResetOtpLoading.value,
                  text: AppText.getOtp,
                  textStyle: sansBold.copyWith(
                    fontSize: 14.sp,
                    height: 3.h,
                    letterSpacing: .12,
                    color: AppColor.white,
                  ),
                  textIconWidth: 12.w,
                  trailing: SvgPicture.asset(
                    AppImage.icArrowRight, height: 20.h,),
                  color: isEnabled ? AppColor.buttonColor : AppColor.buttonColor.withValues(alpha: 0.5),
                  onPressed: isEnabled ? () {
                    authController.sendResetOtp(isReload: true);
                  } : null,
                );
              }),
          
            ],
          ),
        ),
      ),
    );
  }
}
