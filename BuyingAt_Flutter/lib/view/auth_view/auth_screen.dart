import 'package:classified/utils/app_text.dart';
import 'package:classified/view/auth_view/sign_in_screen.dart';
import 'package:classified/view/auth_view/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controller/auth_controller.dart';
import '../../utils/app_color.dart';
import '../../utils/app_fonts.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late AuthController authController;

  @override
  void initState() {
    super.initState();
    authController = Get.find<AuthController>();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 65.h),
            Obx(() {
              return Text(
                authController.tabIndex.value == 0
                    ? AppText.getStartedNow
                    : AppText.register,
                style: interBold.copyWith(
                  fontSize: 28.sp,
                  height: 1.3.h,
                  color: AppColor.textColor,
                  letterSpacing: -.2,
                ),
                textAlign: TextAlign.center,
              );
            }),
            SizedBox(height: 8.h),
            Text(
              AppText.createAnAccountOrLogTxt,
              style: sansReg.copyWith(
                fontSize: 14.sp,
                color: AppColor.coolGray4,
                height: 1.5.h,
                letterSpacing: -0.1,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 40.h),
            Obx(
              () => Container(
                padding: EdgeInsets.all(2.5.sp),
                height: 41.h,
                decoration: BoxDecoration(
                  color: AppColor.coolGray2,
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: AppColor.coolGray2, width: 1.15.sp),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => authController.switchTab(0),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: authController.tabIndex.value == 0
                                ? Colors.white
                                : AppColor.coolGray2,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            AppText.logIn,
                            style: interMedium.copyWith(
                              fontSize: 16.sp,
                              color: authController.tabIndex.value == 0
                                  ? AppColor.textColor
                                  : AppColor.coolGray3,
                              height: 1.5.h,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => authController.switchTab(1),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: authController.tabIndex.value == 1
                                ? AppColor.white
                                : AppColor.coolGray2,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            AppText.signUp,
                            style: interMedium.copyWith(
                              fontSize: 16.sp,
                              color: authController.tabIndex.value == 1
                                  ? AppColor.textColor
                                  : AppColor.coolGray3,
                              height: 1.5.h,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 28.h),
            Flexible(
              child: Obx(() {
                return authController.tabIndex.value == 0
                    ? SignInScreen(authController: authController)
                    : SignUpScreen(authController: authController);
              }),
            ),
          ],
        ),
      ),
    );
  }
}
