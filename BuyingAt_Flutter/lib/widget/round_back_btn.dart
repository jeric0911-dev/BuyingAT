import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../utils/app_color.dart';

class RoundBackBtn extends StatelessWidget {
  final VoidCallback onTap;
  final String icon;
  final Color? bgColor;
  const RoundBackBtn({
    super.key,
    required this.onTap,
    required this.icon,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height:  29.h,
        width:  29.h,
        decoration: BoxDecoration(
          color: AppColor.buttonColor,
          border: Border.all(width: 1.2.sp,color: Colors.white),
          shape: BoxShape.circle,
        ),
          child: Center(
            child: SvgPicture.asset(
                    icon,
                    height: 15.w,
                    width:  15.w,
                  ),
          )
      ) ,
    );
  }
}
