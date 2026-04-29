import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_color.dart';
import '../utils/app_fonts.dart';
import '../utils/app_image.dart';

class NoDataWidget extends StatelessWidget {
  final dynamic text;
  final dynamic height;
  final dynamic width;
  const NoDataWidget({super.key, required this.text, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 180.h),
        SvgPicture.asset(
          AppImage.icNoData,
          height: height ?? 200.h,
          width: width ?? 275.w,
        ),
        SizedBox(height: 29.h),
        Text(
          text,
          style: interMedium.copyWith(
            color: AppColor.coolGray11,
            fontSize: 15.sp,
          ),
        ),
      ],
    );
  }
}
