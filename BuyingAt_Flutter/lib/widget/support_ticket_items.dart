import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../model/support_ticket_model.dart';
import '../routes/app_routes.dart';
import '../utils/app_color.dart';
import '../utils/app_fonts.dart';
import '../utils/app_image.dart';
import '../utils/app_text.dart';
import '../utils/clean_text.dart';

class SupportTicketItems extends StatelessWidget {
  final TicketData ticketData;
  const SupportTicketItems({
    super.key,
     required this.ticketData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      margin: EdgeInsets.only(top: 16.w, left: 16.w,right: 16.w),
      padding: EdgeInsets.all(24.sp),
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border.all(color: AppColor.coolGray6),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 129.w,
                child: Text(
                  AppText.subject,
                  style: sansMedium.copyWith(
                    fontSize: 18.sp,
                    height: 1.35.h,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 32.w),
                child: Text(
                  ':',
                  style: sansMedium.copyWith(
                    fontSize: 18.sp,
                    height: 1.35.h,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  cleanText(ticketData.subject.toString()),
                  style: sansReg.copyWith(
                    height: 1.4.h,
                    color: AppColor.coolGray11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 129.w,
                child: Text(
                  AppText.status,
                  style: sansMedium.copyWith(
                    fontSize: 18.sp,
                    height: 1.35.h,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 32.w),
                child: Text(
                  ':',
                  style: sansMedium.copyWith(
                    fontSize: 18.sp,
                    height: 1.35.h,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 13.w,
                  vertical: 4.5.h,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(107.r),
                  color: ticketData.status == 0 ?AppColor.amberOrange8 : AppColor.leafGreen1
                ),
                child: Text(
                  ticketData.status == 0 ? 'Close' : 'Open',
                  style: sansMedium.copyWith(
                    fontSize: 18.sp,
                    height: 1.35.h,
                    letterSpacing: .5,
                    color: ticketData.status == 0 ?AppColor.amberOrange6 : AppColor.deepGreen,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 129.w,
                child: Text(
                  AppText.priority,
                  style: sansMedium.copyWith(
                    fontSize: 18.sp,
                    height: 1.35.h,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 32.w),
                child: Text(
                  ':',
                  style: sansMedium.copyWith(
                    fontSize: 18.sp,
                    height: 1.35.h,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 13.w,
                  vertical: 4.5.h,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(107.r),
                  color:
                  ticketData.priority == 'medium'
                          ? AppColor.amberOrange7
                          : AppColor.amberOrange8,
                ),
                child: Text(
                  ticketData.priority.toString(),
                  style: sansMedium.copyWith(
                    fontSize: 18.sp,
                    height: 1.45.h,
                    letterSpacing: .5,
                    color:
                    ticketData.priority == 'medium'
                        ? AppColor.amberOrange5
                        : AppColor.amberOrange6,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              SizedBox(
                width: 129.w,
                child: Text(
                  AppText.action,
                  style: sansMedium.copyWith(
                    fontSize: 18.sp,
                    height: 1.35.h,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 52.w),
                child: Text(
                  ':',
                  style: sansMedium.copyWith(
                    fontSize: 18.sp,
                    height: 1.35.h,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  if( ticketData.status == 0){
                    Get.toNamed(Routes.msgSupportTicketRoute, arguments: {'item': ticketData.ticketId, 'status': ticketData.status,'id': ticketData.id,});
                  }else{
                    Get.toNamed(Routes.replySupportTicketRoute, arguments: {'id': ticketData.id, 'ticketId': ticketData.ticketId, 'item': ticketData});
                  }

                },
                child: SvgPicture.asset(AppImage.icVisible),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
