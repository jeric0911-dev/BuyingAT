import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/app_color.dart';
import '../../utils/app_fonts.dart';
import '../../widget/custom_button.dart';

class ProfileUpdatedDialog extends StatelessWidget {
  const ProfileUpdatedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColor.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30.h),
            Text(
              'Profile updated successfully!',
              style: sansSemiBold.copyWith(
                fontSize: 18.sp,
                color: AppColor.primaryColor,
                height: 1.5.h,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 40.h),
            CustomButton(
              text: 'okay',
              width: 100.w,
              onPressed: () {
                Get.back(); // Close dialog
              },
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}

