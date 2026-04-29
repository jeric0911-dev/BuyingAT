import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../utils/app_color.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_image.dart';
import '../../utils/app_text.dart';

Widget sortWidget(
  BuildContext context, {
  required Function onTap,
  required int index,
  bool? isSelect = false,
}) {
  return InkWell(
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    onTap: () {
      onTap();
    },
    child: SizedBox(
      height: 54.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                index == 0 ? AppImage.icFilter : AppImage.icSort,
              ),
              SizedBox(width: 8.w),
              Stack(
                alignment: Alignment.centerRight,
                clipBehavior: Clip.none,
                children: [
                  Text(
                    index == 0 ? AppText.filters : AppText.sort,
                    style: sansMedium.copyWith(
                      fontSize: 18.sp,
                      color: AppColor.primaryColor,
                      height: 1.h,
                    ),
                  ),
                  isSelect!
                      ? Positioned(
                    top: -12.h,
                    right: -8.w,
                    child: SvgPicture.asset(
                      AppImage.icSelected,
                      height: 14.h,
                    ),
                  )
                      : SizedBox.shrink(),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
