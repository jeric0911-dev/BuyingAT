import 'package:classified/controller/customer_order_controller.dart';
import 'package:classified/model/customer_order_model.dart';
import 'package:classified/utils/app_color.dart';
import 'package:classified/utils/app_fonts.dart';
import 'package:classified/utils/app_image.dart';
import 'package:classified/utils/app_text.dart';
import 'package:classified/widget/custom_app_bar.dart';
import 'package:classified/widget/custom_title_bar.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late CustomerOrderController controller;
  late dynamic oId;
  final List<String> _statusOptions = const [
    'pending',
    'processing',
    'completed',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    oId = Get.arguments?['Id'] ?? 0;
    controller = Get.find<CustomerOrderController>();
    controller.fetchOrderDetails(oId: oId, isReload: true);
  }

  @override
  Widget build(BuildContext context) {
    final int orderId = oId is int ? oId : int.tryParse(oId.toString()) ?? 0;

    return Scaffold(
      appBar: CustomAppBar(title: AppText.orderDetails),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Obx(() {
                return Skeletonizer(
                  enabled: controller.isOrderDtlLoading.value,
                  child: Container(
                    padding: EdgeInsets.all(24.sp),
                    decoration: BoxDecoration(
                      color: AppColor.buttonColor4,
                      border: Border.all(color: AppColor.buttonColor3),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() {
                          return Text(
                            controller.orderDetailsData.value.orderId
                                .toString(),
                            style: sansReg.copyWith(
                              fontSize: 20.sp,
                              color: AppColor.primaryColor,
                              height: 1.4.h,
                            ),
                          );
                        }),
                        SizedBox(height: 8.h),


                        Obx(() {
                          final order = controller.orderDetailsData.value;
                          return Text(
                            '${order.quantity} Products • Order Placed in ${formatDate(
                              order.createdAt.toString(),
                            )}',
                            style: sansReg.copyWith(
                              fontSize: 14.sp,
                              color: AppColor.coolGray9,
                              height: 1.42.h,
                            ),
                          );
                        }),

                        SizedBox(height: 17.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Obx(() {
                              final amount =
                                  controller.orderDetailsData.value.amount ??
                                      '0';
                              return Text(
                                '\$$amount',
                                style: sansSemiBold.copyWith(
                                  fontSize: 28.sp,
                                  color: AppColor.buttonColor,
                                ),
                              );
                            }),
                            Obx(() {
                              final order = controller.orderDetailsData.value;
                              final currentStatus =
                                  (order.orderStatus ?? '').toLowerCase();
                              final isUpdating =
                                  controller.isUpdatingStatus.value;

                              Color statusColor = AppColor.primaryColor;
                              if (currentStatus == 'pending') {
                                statusColor = AppColor.buttonColor;
                              } else if (currentStatus == 'processing') {
                                statusColor = AppColor.amberOrange3;
                              } else if (currentStatus == 'completed') {
                                statusColor = AppColor.leafGreen;
                              } else if (currentStatus == 'cancelled') {
                                statusColor = Colors.redAccent;
                              }

                              return Row(
                                children: [
                                  SvgPicture.asset(
                                    AppImage.icPackage,
                                    height: 24.h,
                                  ),
                                  SizedBox(width: 12.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(
                                        color: statusColor.withOpacity(0.4),
                                        width: 1,
                                      ),
                                      color: statusColor.withOpacity(0.06),
                                    ),
                                    child: PopupMenuButton<String>(
                                      padding: EdgeInsets.zero,
                                      onSelected: (value) {
                                        if (orderId > 0 &&
                                            !controller
                                                .isUpdatingStatus.value) {
                                          controller.updateOrderStatus(
                                            orderId: orderId,
                                            status: value,
                                          );
                                        }
                                      },
                                      itemBuilder: (context) {
                                        return _statusOptions
                                            .map(
                                              (status) => PopupMenuItem<String>(
                                                value: status,
                                                child: Text(
                                                  status,
                                                  style:
                                                      sansReg.copyWith(
                                                    fontSize: 12.sp,
                                                    color: AppColor
                                                        .primaryColor,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList();
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (isUpdating)
                                            SizedBox(
                                              width: 14.w,
                                              height: 14.w,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(statusColor),
                                              ),
                                            )
                                          else
                                            Text(
                                              (order.orderStatus ?? '')
                                                      .isNotEmpty
                                                  ? (order.orderStatus ?? '')
                                                  : 'Status',
                                              style: sansMedium.copyWith(
                                                fontSize: 14.sp,
                                                color: statusColor,
                                              ),
                                            ),
                                          Icon(
                                            Icons.arrow_drop_down,
                                            size: 18.w,
                                            color: statusColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: 24.h),
              CustomTitleBar(
                title: AppText.orderActivity,
                titleStyle: sansBold.copyWith(
                  height: 1.33.h,
                  fontSize: 18.sp,
                  color: AppColor.primaryColor,
                ),
              ),

              SizedBox(height: 16.h),
              Obx(() {
                final isLoading = controller.isOrderDtlLoading.value;
                final orderDtlData =
                    controller.orderDetailsData.value.orderStatusDetail;
                return Skeletonizer(
                  enabled: isLoading,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: isLoading ? 3 : orderDtlData?.length,
                    itemBuilder: (context, index) {
                      final item = isLoading
                          ? OrderStatusDetail()
                          : orderDtlData?[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              item?.status == "placed"
                                  ? AppImage.icOrderConfirmed
                                  : item?.status == "packaging"
                                  ? AppImage.icOrderPackaged
                                  : item?.status == "on_the_way"
                                  ? AppImage.icOnTheWay
                                  : item?.status == "delivered"
                                  ? AppImage.icOrderDelivered
                                  : item?.status == "cancelled"
                                  ? AppImage.icOrderFailed
                                  : AppImage.icOrderDef,
                              height: 48.h,
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    item?.message.toString() ?? '',
                                    style: sansReg.copyWith(
                                      fontSize: 14.sp,
                                      height: 1.42.h,
                                      color: AppColor.primaryColor,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    formatDate("${item?.createdAt ?? ''}"),
                                    style: sansReg.copyWith(
                                      fontSize: 14.sp,
                                      height: 1.42.h,
                                      color: AppColor.coolGray1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),

              SizedBox(height: 14.h),
              Obx(() {
                return Skeletonizer(
                  enabled: controller.isOrderDtlLoading.value,
                  child: CustomTitleBar(
                    title:
                    '${AppText.product} (${controller.orderDetailsData.value
                        .quantity ?? 0})',
                    titleStyle: sansBold.copyWith(
                      height: 1.33.h,
                      fontSize: 18.sp,
                      color: AppColor.primaryColor,
                    ),
                  ),
                );
              }),

              SizedBox(height: 16.h),
              DottedLine(dashColor: AppColor.coolGray19),

              Obx(() {
                final isLoading = controller.isOrderDtlLoading.value;
                final orderDtlData =
                    controller.orderDetailsData.value.orderStatusDetail;
                return Skeletonizer(
                  enabled: isLoading,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: isLoading ? 3 : orderDtlData?.length,
                    itemBuilder: (context, index) {
                      final item = isLoading
                          ? OrderStatusDetail()
                          : orderDtlData?[index];
                      return Padding(
                        padding: EdgeInsets.only(top: 20.h),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                  item?.status == "placed"
                                      ? AppImage.icOrderConfirmed
                                      : item?.status == "packaging"
                                      ? AppImage.icOrderPackaged
                                      : item?.status == "on_the_way"
                                      ? AppImage.icOnTheWay
                                      : item?.status == "delivered"
                                      ? AppImage.icOrderDelivered
                                      : item?.status == "cancelled"
                                      ? AppImage.icOrderFailed
                                      : AppImage.icOrderDef,
                                  height: 72.h,
                                ),
                                SizedBox(width: 16.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      item?.message.toString() ?? '',
                                      style: sansReg.copyWith(
                                        fontSize: 14.sp,
                                        height: 1.42.h,
                                        color: AppColor.primaryColor,
                                      ),
                                    ),

                                    Text(
                                      formatDate("${item?.createdAt ?? ''}"),
                                      style: sansReg.copyWith(
                                        fontSize: 14.sp,
                                        height: 1.42.h,
                                        color: AppColor.coolGray1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 19.h),
                            DottedLine(dashColor: AppColor.coolGray19),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

String formatDate(String? input) {
  if (input == null || input.isEmpty) {
    return '';
  }
  try {
    final dateTime = DateTime.parse(input).toLocal();
    return DateFormat("dd MMM, yyyy 'at' h:mm a").format(dateTime);
  } catch (_) {
    return '';
  }
}
