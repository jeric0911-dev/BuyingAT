import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/route_manager.dart';
import '../utils/app_color.dart';
import '../utils/app_fonts.dart';
import '../utils/app_image.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final double? appHeight;
  final Color? color;
  final Function? onTapBack;
  final bool isBackButtonExist;
  final bool centerTitle;
  final double? leadingWidth;
  final Widget? action;
  final double? leftPadding;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    this.title,
    this.appHeight,
    this.onTapBack,
    this.titleWidget,
    this.isBackButtonExist = true,
    this.centerTitle = true,
    this.action,
    this.leadingWidth,
    this.leftPadding,
    this.color,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: color ?? Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      titleSpacing: isBackButtonExist ? 20.w : 16.w,
      title:
          titleWidget ??
          Text(
            title ?? '',
            style: sansBold.copyWith(
              fontSize: 24.sp,
              height: 1.66.h,
              color: AppColor.primaryColor,
            ),
          ),
      leading: GestureDetector(
        onTap: () {
          if (onTapBack != null) {
            onTapBack!();
          } else {
            Get.back();
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.only(left: leftPadding ?? 20.w),
          child: SvgPicture.asset(AppImage.icBackArrow,),
        ),
      ),
      leadingWidth: isBackButtonExist ? (leadingWidth ?? 45).w : 0,
      actions: [if (action != null) action!],
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appHeight ?? 60.h);
}
