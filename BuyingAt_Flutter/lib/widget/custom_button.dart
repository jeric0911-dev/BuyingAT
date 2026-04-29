import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_color.dart';
import '../utils/app_fonts.dart';

class CustomButton extends StatelessWidget {
  final double? height;
  final double? width;
  final double? fontSize;
  final double? strokeWidth;
  final Color? loadingColor;
  final double? marginLeft;
  final double? marginRight;
  final double? borderWidth;
  final double? iconTextWidth;
  final double? textIconWidth;
  final Color? color;
  final Color? borderColor;
  final double? borderRadius;
  final Color? textColor ;
  final Widget? leading;
  final String? text;
  final TextStyle? textStyle;
  final Widget? trailing;
  final VoidCallback? onPressed;
  final double? shadowX;
  final double? shadowY;
  final double? shadowBlur;
  final double? shadowSpread;
  final Color? shadowColor;
  final Widget? widget;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final BoxShadow? boxShadow;

  const CustomButton({
    super.key,
    this.height,
    this.width,
    this.marginLeft,
    this.marginRight,
    this.borderWidth,
    this.color,
    this.borderColor,
    this.borderRadius,
    this.leading,
    this.text,
    this.textStyle,
    this.trailing,
    this.onPressed,
    this.iconTextWidth,
    this.textIconWidth,
    this.shadowX,
    this.shadowY,
    this.shadowBlur,
    this.shadowSpread,
    this.shadowColor,
    this.widget, this.padding, this.isLoading = false, this.loadingColor, this.strokeWidth, this.textColor, this.boxShadow, this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final hasPadding = padding != null;
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.only(
          left: marginLeft ?? 16.w,
          right: marginRight ?? 16.w,
        ),
        height: hasPadding ? null : (height ?? 48.h),
        width: hasPadding ? null : (width ?? double.infinity),
        padding: padding ?? EdgeInsets.zero ,
        decoration: BoxDecoration(
          color: color ?? AppColor.buttonColor,
          border: Border.all(
            color: borderColor ?? color ?? AppColor.buttonColor,
            width: borderWidth ?? 1.15.sp,
          ),
          borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
          boxShadow: [
            boxShadow ?? BoxShadow(
              color: shadowColor ?? Colors.transparent,
              offset: Offset(shadowX ?? 0, shadowY ?? 0),
              blurRadius: shadowBlur ?? 0,
              spreadRadius: shadowSpread ?? 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        //padding: EdgeInsets.symmetric(horizontal: 10.w),
        child:
            widget ??
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (leading != null) leading!,

                    if (text != null && !isLoading) ...[
                      SizedBox(width: iconTextWidth?.w ?? 0),
                      Text(
                        text ?? '',
                        style: textStyle ??
                            interSemiBold.copyWith(
                              color: textColor ?? AppColor.white,
                              fontSize: fontSize ?? 18.sp,
                              height: 1.4.h,
                              letterSpacing: -.1
                            ),
                      ),
                    ],

                    if (isLoading) ...[
                      SizedBox(width: iconTextWidth?.w ?? 0),
                      FittedBox(
                        child:  Padding(
                          padding:  EdgeInsets.all(10.0),
                          child: CircularProgressIndicator(
                            strokeWidth: strokeWidth ?? 2,
                            color: loadingColor ??  AppColor.white,
                          ),
                        ),
                      ),
                    ],

                    if (trailing != null && !isLoading) ...[
                      SizedBox(width: textIconWidth?.w ?? 0),
                      trailing!,
                    ],
                  ],
                )

      ),
    );
  }
}
