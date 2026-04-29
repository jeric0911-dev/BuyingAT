import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_color.dart';
import '../utils/app_fonts.dart';
import 'custom_dropdown_widget.dart';

class CustomDropDawnBtn extends StatelessWidget {
  final List<DropdownItem<int>>? items;
  final String title;
  final bool? isSelected;
  final double? btnHeight;
  final bool isIndexValue;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? textPadding;
  final EdgeInsetsGeometry? iconPadding;
  final dynamic iconSize;
  final bool dropdownStyleWidth;
  final void Function(int? value, int index) onChange;

  const CustomDropDawnBtn({
    super.key,
    required this.items,
    this.iconPadding,
    required this.onChange,
    required this.title,
    this.btnHeight,
    this.isSelected = false,
    this.isIndexValue = false,
    this.textStyle,
    this.textPadding,
    this.iconSize, this.dropdownStyleWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        color: Colors.white,
        border: Border.all(width: 1.15.sp, color: AppColor.coolGray6),
        boxShadow: [
          BoxShadow(
            color: AppColor.coolGray7.withValues(alpha: .24),
            blurRadius: 1.3,
            offset: Offset(0, 1.15),
            spreadRadius: 0,
          ),
        ],
      ),
      child: CustomDropdown<int>(
        iconSize: iconSize,
        onChange: onChange,
        isIndexValue: isIndexValue,
        iconPadding: iconPadding,
        dropdownButtonStyle: DropdownButtonStyle(
          height: btnHeight ?? 52.h,
          padding: EdgeInsets.only(left: 20.w, right: 40.w),
          primaryColor: Colors.white,
        ),
        dropdownStyle: DropdownStyle(
          width: dropdownStyleWidth ? 200.w : null,
          padding: dropdownStyleWidth ? EdgeInsets.zero : EdgeInsets.only(left: 16.w, right: 40.w) ,
          color: Colors.white,
          elevation: 5,
          borderRadius: BorderRadius.circular(4.r),
        ),
        items: items ?? [],
        child: Padding(
          padding: textPadding ?? EdgeInsets.only(left: 12.w),
          child: Text(
            title,
            style:
                textStyle ??
                interMedium.copyWith(
                  fontSize: 16.sp,
                  color: isSelected == false
                      ? AppColor.coolGray5
                      : AppColor.textColor,
                  height: 1.4.h,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
