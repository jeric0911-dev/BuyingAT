import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../utils/app_color.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_image.dart';


class ProfileItems extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  const ProfileItems({super.key, required this.title,  this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onPressed ?? () {},
      child: Container(
        width: double.infinity,
        height: 60.h,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: AppColor.coolGray6, width: 1.15.sp),
          boxShadow: [
            BoxShadow(
              color: AppColor.coolGray7.withValues(alpha: .24),
              blurRadius: 2.3,
              offset: Offset(0, 1.5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                title,
                style: interMedium.copyWith(
                  fontSize: 16.sp,
                  color: AppColor.textColor,
                  height: 1.4.h,
                  letterSpacing: -.1
                ),
                maxLines: 1,
              ),
            ),
            SvgPicture.asset(AppImage.icForward),
          ],
        ),
      ),
    );
  }
}
