
import 'package:classified/utils/app_color.dart';
import 'package:classified/utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../routes/app_routes.dart';
import '../transition/fade_transition.dart';
import '../utils/app_image.dart';
import '../utils/app_text.dart';
import '../utils/session_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _imageOpacity = 0.0;
  double _textOpacity = 0.0;

  @override
  void initState() {
    super.initState();


    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _imageOpacity = 1.0;
      });
    });


    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _textOpacity = 1.0;
      });
    });


    Timer(const Duration(milliseconds: 2500), () {
      // Check if user is logged in
      final isLoggedIn = SessionManager.getValue(kIsLOGIN, value: false);
      
      if (isLoggedIn == true) {
        // User is logged in, redirect to My Cards page
      FadeScreenTransition(
        routeName: Routes.myShopRoute, 
        arguments: {'type': 'my'},
        replace: true
      ).navigate();
      } else {
        // User is not logged in, redirect to login/register page
        FadeScreenTransition(
          routeName: Routes.authRoute,
          replace: true
        ).navigate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.buttonColor,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  opacity: _imageOpacity,
                  duration: const Duration(milliseconds: 700),
                  child: SvgPicture.asset(
                    AppImage.appIcon,
                    width: 83.w,
                    height: 83.h,
                  ),
                ),
                SizedBox(height: 16.h),
                AnimatedOpacity(
                  opacity: _textOpacity,
                  duration: const Duration(milliseconds: 1400),
                  child: Text(AppText.classified, style: sansExtraBold.copyWith(fontSize: 24.sp, height: 1.06.h,color: AppColor.dark3),),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


