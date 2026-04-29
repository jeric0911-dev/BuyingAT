import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../utils/app_color.dart';

class RoundBtn extends StatelessWidget {
  final VoidCallback onTap;
  final double? height;
  final double? icHeight;
  final double? width;
  final double? icWidth;
  final bool? isBorder;
  final String icon;
  final Color? bgColor;
  const RoundBtn({
    super.key,
    required this.onTap,
    this.height,
    this.width,
    this.isBorder = false,
    required this.icon,
    this.icHeight,
    this.icWidth,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: height ?? 36.h,
        width: width ?? 36.h,
        decoration: BoxDecoration(
          border:
          isBorder == true
              ? Border.all(color: AppColor.white.withValues(alpha: .30), width: 0.8.sp)
              : null,
          shape: BoxShape.circle,
        ),
        child: SizedBox.expand().blurred(
          blur: 10,
          borderRadius: BorderRadius.circular(30.r),
          colorOpacity: .2,
           blurColor: AppColor.dark.withValues(alpha: .14),
          overlay: Center(
            child: SvgPicture.asset(
              icon,
              height: icHeight ?? 22.w,
              width: icWidth ?? 22.w,
            ),
          ),
        ),
      ) ,
    );
  }
}
