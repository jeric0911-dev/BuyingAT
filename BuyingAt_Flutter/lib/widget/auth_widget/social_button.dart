import 'package:classified/utils/app_color.dart';
import 'package:classified/utils/app_fonts.dart';
import 'package:classified/utils/app_image.dart';
import 'package:classified/utils/app_text.dart';
import 'package:classified/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialButton extends StatelessWidget {
  final VoidCallback? onGooglePressed;
  const SocialButton({super.key, this.onGooglePressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: CustomButton(
              marginLeft: 0,
              marginRight: 0,
              shadowY: -3.44,
              shadowBlur: 6.89,
              shadowColor: AppColor.ghostWhite1,
              color: Colors.white,
              onPressed: onGooglePressed,
              height: 52.h,
              borderColor: AppColor.coolGray7,
              leading: SvgPicture.asset(AppImage.icGoogle, height: 21.h,),
              iconTextWidth: 12.w,
              textStyle:  interSemiBold.copyWith(
                fontSize: 16.sp,
                height: 1.4.h,
                color: AppColor.textColor,
                letterSpacing: -.1,
              ),
              text: AppText.google,
            )),
        SizedBox(width: 17.w),
        Expanded(
            child: CustomButton(
              marginLeft: 0,
              marginRight: 0,
              shadowY: -3.44,
              shadowBlur: 6.89,
              shadowColor: AppColor.ghostWhite1,
              color: Colors.white,
              height: 52.h,
              borderColor: AppColor.coolGray7,
              leading: SvgPicture.asset(AppImage.icApple,height: 21.h,),
              iconTextWidth: 12.w,
              textStyle:  interSemiBold.copyWith(
                fontSize: 16.sp,
                height: 1.4.h,
                color: AppColor.textColor,
                letterSpacing: -.1,
              ),
              text: AppText.apple,
            )),
      ],
    );
  }
}
