import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../utils/app_color.dart';

class NavItemCard extends StatelessWidget {
  final String imagePath;
  final String imagePathActive;
  final String? name;
  final double size;
  final bool active;
  final bool isAdd;

  const NavItemCard({
    super.key,
    required this.imagePath,
    required this.size,
     this.name,
    required this.active,
    required this.imagePathActive,
    this.isAdd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isAdd)
          Container(
            height: size.h,
            width: size.h,
            decoration: BoxDecoration(
              color: AppColor.buttonColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.add,
              size: (size * 0.55).h,
              color: Colors.white,
            ),
          )
        else
          SvgPicture.asset(
            active ? imagePathActive : imagePath,
            height: size.h,
            width: size.h,
            colorFilter: active 
                ? ColorFilter.mode(AppColor.buttonColor, BlendMode.srcIn)
                : ColorFilter.mode(AppColor.coolGray4, BlendMode.srcIn),
          ),
        SizedBox(height: isAdd ? 5.8.h : 11.8.h),
        if (!isAdd)
          Container(
            width: 25.w,
            height: 4.h,
            decoration: BoxDecoration(
                color: active ? AppColor.buttonColor : null,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10.h),
                  topLeft: Radius.circular(10.h),
                )),
          )
      ],
    );
  }
}
