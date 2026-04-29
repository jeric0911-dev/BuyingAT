import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controller/dashboard_controller.dart';
import '../../routes/app_routes.dart';
import '../../transition/fade_transition.dart';
import '../../utils/app_color.dart';
import '../../utils/app_fonts.dart';
import '../../widget/custom_button.dart';

class CardAddedDialog extends StatelessWidget {
  const CardAddedDialog({super.key});

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
              'Card created successfully!\nIt is now waiting for admin approval.',
              style: sansSemiBold.copyWith(
                fontSize: 18.sp,
                color: AppColor.primaryColor,
                height: 1.5.h,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 40),
            CustomButton(
              text: 'okay',
              width: 100.w,
              onPressed: () {
                Get.back(); // Close dialog
                Get.back(); // Close add card screen
                
                // Navigate to My Cards page and refresh
                try {
                  final dashboardController = Get.find<DashboardController>();
                  dashboardController.setStatus('Pending'); // Show pending cards by default
                  FadeScreenTransition(
                    routeName: Routes.myShopRoute,
                    arguments: {'type': 'pen'}, // 'pen' for pending
                  ).navigate();
                } catch (_) {
                  // If navigation fails, just go back
                }
              },
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}

