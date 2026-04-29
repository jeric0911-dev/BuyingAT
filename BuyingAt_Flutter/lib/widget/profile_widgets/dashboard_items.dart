import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/app_color.dart';
import '../../utils/app_fonts.dart';


class DashboardItems extends StatelessWidget {
  final Color color;
  final String icon;
  final String subTitle;
  final String title;
  final VoidCallback? onPressed;
  const DashboardItems({super.key,  this.onPressed, required this.color, required this.icon, required this.subTitle, required this.title});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.symmetric( vertical: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(icon,
              width: 56.h,
            ),
            SizedBox(width: 16.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                 title,
                  style: sansSemiBold.copyWith(
                      fontSize: 20.sp,
                      color: AppColor.primaryColor,
                      height: 1.4.h,
                  ),
                  maxLines: 1,
                ),
                SizedBox(height: 4.h,),
                Text(
                  subTitle,
                  style: sansReg.copyWith(
                      fontSize: 14.sp,
                      color: AppColor.coolGray9,
                      height: 1.42.h,

                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
