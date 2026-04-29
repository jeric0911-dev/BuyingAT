import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controller/user_status_controller.dart';
import '../utils/app_color.dart';
import '../utils/app_fonts.dart';
import 'package:get/get.dart';

class UserStatusBadge extends StatelessWidget {
  final int userId;
  final double size;
  final bool showText;
  final EdgeInsets? badgePosition;

  const UserStatusBadge({
    super.key,
    required this.userId,
    this.size = 12.0,
    this.showText = false,
    this.badgePosition,
  });

  @override
  Widget build(BuildContext context) {
    final userStatusController = Get.find<UserStatusController>();
    
    return FutureBuilder<UserStatus?>(
      future: userStatusController.getUserStatus(userId),
      builder: (context, snapshot) {
        final status = snapshot.data;
        final isOnline = status?.isOnline ?? false;
        final statusText = status?.statusText ?? 'Offline';

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Status indicator badge
            Positioned(
              right: badgePosition?.right ?? 0,
              bottom: badgePosition?.bottom ?? 0,
              top: badgePosition?.top,
              left: badgePosition?.left,
              child: Container(
                width: size.w,
                height: size.w,
                decoration: BoxDecoration(
                  color: isOnline ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2.sp,
                  ),
                ),
              ),
            ),
            // Status text (if enabled)
            if (showText && status != null)
              Positioned(
                left: (size + 4).w,
                bottom: 0,
                child: Text(
                  statusText,
                  style: sansReg.copyWith(
                    fontSize: 10.sp,
                    color: isOnline ? Colors.green : AppColor.coolGray21,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

