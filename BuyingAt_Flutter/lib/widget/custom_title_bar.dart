import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_color.dart';
import '../utils/app_fonts.dart';

class CustomTitleBar extends StatelessWidget {
  final String title;
  final String? endTitle;
  final double? fontSize;
  final double? padding;
  final double? paddingRightSeeAll;
  final TextStyle? titleStyle;
  final TextStyle? endTitleStyle;
  final VoidCallback? onTap;
  final bool? isSellAll;
  final EdgeInsets? paddingWidget;

  const CustomTitleBar({
    super.key,
    required this.title,
    this.endTitle,
    this.fontSize,
    this.titleStyle,
    this.isSellAll = false,
    this.endTitleStyle,
    this.padding,
    this.onTap, this.paddingWidget, this.paddingRightSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: paddingWidget ?? EdgeInsets.symmetric(horizontal: padding ?? 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style:
                titleStyle ??
                    pJakartaMedium.copyWith(
                  fontSize: fontSize ?? 14.sp,
                  height: 1.60.h,
                  letterSpacing: -.2.w,
                  color: AppColor.coolGray4,
                ),
          ),
          Spacer(),
          if(isSellAll == true )InkWell(
            onTap: onTap,
            child: Padding(
              padding:EdgeInsets.only(left: 16.w, bottom: 5.h,top: 5.h,right: paddingRightSeeAll ?? 16.w),
              child: Center(
                child: Text(
                  endTitle ?? '',
                  style:
                      endTitleStyle ??
                          sansSemiBold.copyWith(color: AppColor.buttonColor,fontSize: 14.sp,),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
