import 'package:classified/model/customer_order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../helper/date_format.dart';
import '../routes/app_routes.dart';
import '../transition/fade_transition.dart';
import '../utils/app_color.dart';
import '../utils/app_fonts.dart';
import '../utils/app_text.dart';
import '../utils/clean_text.dart';

class OrderItemsWidget extends StatelessWidget {
  final CustomerOrder item;
  const OrderItemsWidget({
    super.key,
     required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: (){
        FadeScreenTransition(routeName: Routes.orderDetailsRoute, arguments: {'Id': item.id}).navigate();
      },
      child: Container(
        width: 1.sw,
        margin: EdgeInsets.only(bottom: 16.w, left: 16.w,right: 16.w),
         padding: EdgeInsets.all(20.sp),
        decoration: BoxDecoration(
          color: AppColor.white,
          border: Border.all(color: AppColor.coolGray12, width: 1.20.sp),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150.w,
                  child: Text(
                    AppText.orderId,
                    style: sansSemiBold.copyWith(
                      fontSize: 16.sp,
                      height: 1.5.h,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 32.w),
                  child: Text(
                    ':',
                    style: sansSemiBold.copyWith(
                      fontSize: 16.sp,
                      height: 1.5.h,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ),
                Spacer(),
                Text(
                  cleanText(item.orderId.toString()),
                  style: sansSemiBold.copyWith(
                    height: 1.4.h,
                    fontSize: 14.sp,
                    color: AppColor.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                 width: 150.w,
                  child: Text(
                    AppText.date,
                    style: sansSemiBold.copyWith(
                      fontSize: 16.sp,
                      height: 1.5.h,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 32.w),
                  child: Text(
                    ':',
                    style: sansSemiBold.copyWith(
                      fontSize: 16.sp,
                      height: 1.5.h,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ),
                Spacer(),
                Text(
                  formatDateTime(item.createdAt.toString()),
                  style: sansReg.copyWith(
                    height: 1.4.h,
                    fontSize: 14.sp,
                    color: AppColor.coolGray11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150.w,
                  child: Text(
                    AppText.total,
                    style: sansSemiBold.copyWith(
                      fontSize: 16.sp,
                      height: 1.5.h,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 32.w),
                  child: Text(
                    ':',
                    style: sansSemiBold.copyWith(
                      fontSize: 16.sp,
                      height: 1.5.h,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ),

                Spacer(),
                Text(
                  '\$${getWholeNumber(item.amount.toString())} (${item.quantity} Products)',
                  style: sansReg.copyWith(
                    height: 1.4.h,
                    fontSize: 14.sp,
                    color: AppColor.coolGray11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                SizedBox(
                  width: 150.w,
                  child: Text(
                    AppText.status,
                    style: sansSemiBold.copyWith(
                      fontSize: 16.sp,
                      height: 1.5.h,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 52.w),
                  child: Text(
                    ':',
                    style: sansSemiBold.copyWith(
                      fontSize: 16.sp,
                      height: 1.5.h,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 13.w,
                    vertical: 4.5.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(107.r),
                    color:
                    item.orderStatus == 'processing'
                        ? AppColor.buttonColor2
                        :  item.orderStatus == 'pending' ? AppColor.buttonColor
                        :  item.orderStatus == 'completed' ? AppColor.leafGreen1 : AppColor.amberOrange1,
                  ),
                  child: Text(
                    item.orderStatus.toString(),
                    style: interSemiBold.copyWith(
                      fontSize: 15.sp,
                      height: 1.42.h,
                      letterSpacing: .5,
                      color:
                      item.orderStatus == 'processing'
                          ? AppColor.buttonColor
                          :  item.orderStatus == 'pending' ? AppColor.white
                          :  item.orderStatus == 'completed' ? AppColor.leafGreen : AppColor.amberOrange2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
String getWholeNumber(String? value) {
  if (value == null || value.isEmpty) return '0'; // default fallback
  try {
    double number = double.parse(value);
    return number.toInt().toString();
  } catch (e) {
    return '0'; // fallback on parsing error
  }
}
