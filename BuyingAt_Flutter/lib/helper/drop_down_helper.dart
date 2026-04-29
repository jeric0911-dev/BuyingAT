import 'package:classified/utils/app_color.dart';
import 'package:classified/utils/app_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widget/custom_dropdown_widget.dart';

List<DropdownItem<int>> generateDropdownItems<T>(
  List<T> list,
  String? Function(T) getName,
  int? Function(T) getId,
) {
  return list.map((item) {
    return DropdownItem<int>(
      value: getId(item),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          getName(item) ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: sansMedium.copyWith(
            fontSize: 14.sp,
            color: AppColor.textColor,
            height: 1.4.h,
          ),
        ),
      ),
    );
  }).toList();
}
