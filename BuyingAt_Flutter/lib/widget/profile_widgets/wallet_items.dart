import 'package:classified/utils/app_fonts.dart';
import 'package:classified/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/app_color.dart';

class WalletItems extends StatelessWidget {
  final String type;
  final String balance;
  final Color color;

  const WalletItems({
    super.key,
    required this.type,
    required this.balance,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 126.w,
      height: 88.h,
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border.all(color: AppColor.coolGray12),
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.dark.withValues(alpha: 0.02),
            offset: Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: 10.h),
          Text(
            type,
            style: sansMedium.copyWith(
              fontSize: 14.sp,
              color: AppColor.coolGray11,
            ),
          ),
          SizedBox(height: 4.3.h),
          Text(
            balance,
            style: sansBold.copyWith(fontSize: 20.sp, color: color),
            maxLines: 1,

          ),
          SizedBox(height: 6.1.h),
          Text(
            "( ${AppText.credit} )",
            style: sansMedium.copyWith(
              fontSize: 10.sp,
              color: AppColor.primaryColor,
            ),
          ),
          SizedBox(height: 15.h),
        ],
      ),
    );
  }
}
