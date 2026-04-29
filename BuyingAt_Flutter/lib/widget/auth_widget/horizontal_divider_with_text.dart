import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/app_color.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_text.dart';

class HorizontalDividerWithText  extends StatelessWidget {
  const HorizontalDividerWithText ({super.key});

  @override
  Widget build(BuildContext context) {
    return  Row(
      children: [
        Expanded(child: Divider(color: AppColor.coolGray6, thickness: 1.15.h)),
        SizedBox(width: 18.w,),
        Text(AppText.orLoginWith,
          style: interReg.copyWith(
              color: AppColor.coolGray4,
              fontSize: 14.sp,
              height: 1.5.h,
              letterSpacing: -.1
          ),
        ),
        SizedBox(width: 18.w,),
        Expanded(child: Divider(color: AppColor.coolGray6, thickness: 1.15.h)),
      ],
    );
  }
}
