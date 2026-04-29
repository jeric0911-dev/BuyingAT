import 'package:classified/utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/app_color.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String? secondValue;
  final bool isStatus;
  final bool showAmountUSD;
  final double? sizeWidth;

  const InfoRow({
    required this.label,
    required this.value,
    this.secondValue,
    this.isStatus = false,
    this.showAmountUSD = false,
    super.key, this.sizeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: sizeWidth ?? 140.w,
            child: Text(
              label,
              style: sansMedium.copyWith(
                fontSize: 16.sp,
                height: 1.5.h,
                color: AppColor.primaryColor,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 32.w),
            child: Text(
              ':',
              style: sansMedium.copyWith(
                fontSize: 16.sp,
                height: 1.5.h,
                color: AppColor.primaryColor,
              ),
            ),
          ),
          Flexible(
            child: isStatus ?  Container(
              padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 4.5.h),
              decoration: BoxDecoration(
                color: value == "success"
                    ? AppColor.leafGreen1
                    : AppColor.amberOrange1,
                borderRadius: BorderRadius.circular(107.r)
                
              ),
              child: Text(
                  // Show the actual status text instead of forcing "Failed"
                  value.isNotEmpty ? value : 'unknown',
                style:  interSemiBold.copyWith(
                  fontSize: 15.sp,
                  height: 1.42.h,
                  letterSpacing: .5,
                  color:  value == "success"
                      ? AppColor.leafGreen
                      : AppColor.amberOrange2,

            )))
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  showAmountUSD
                      ? (value.isNotEmpty ? "$value USD" : '0 USD')
                      : value,
                  style: sansReg.copyWith(
                    fontSize: 14.sp,
                    height: 1.4.h,
                    color: AppColor.coolGray11,
                  ),
                ),
                if (secondValue != null && secondValue!.isNotEmpty)
                  Text(
                    secondValue!,
                    style: sansBold.copyWith(
                      fontSize: 14.sp,
                      height: 1.4.h,
                      color: AppColor.coolGray11,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}