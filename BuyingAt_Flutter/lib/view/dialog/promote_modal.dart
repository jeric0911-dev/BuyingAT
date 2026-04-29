import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controller/promote_controller.dart';
import '../../controller/dashboard_controller.dart';
import '../../service/api/api_client.dart';
import '../../utils/app_color.dart';
import '../../utils/app_fonts.dart';
import '../../widget/custom_button.dart';
import '../../widget/custom_snackbar_widget.dart';

class PromoteModal extends StatefulWidget {
  final int cardId;

  const PromoteModal({
    super.key,
    required this.cardId,
  });

  @override
  State<PromoteModal> createState() => _PromoteModalState();
}

class _PromoteModalState extends State<PromoteModal> {
  late PromoteController promoteController;
  String selectedTierId = 'time_72h';

  final List<Map<String, dynamic>> tiers = [
    {
      'id': 'time_72h',
      'name': '72 hours',
      'price': 9.99,
      'type': 'time',
      'duration': 72,
    },
    {
      'id': 'impr_100',
      'name': '100 views',
      'price': 7.99,
      'type': 'impression',
      'max_views': 100,
    },
  ];

  @override
  void initState() {
    super.initState();
    final apiClient = Get.find<ApiClient>();
    promoteController = Get.put(
      PromoteController(apiClient: apiClient),
      tag: 'promote_${widget.cardId}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedTier = tiers.firstWhere((t) => t['id'] == selectedTierId);

    return Dialog(
      backgroundColor: AppColor.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Promote this Card',
                  style: sansSemiBold.copyWith(
                    fontSize: 18.sp,
                    color: AppColor.primaryColor,
                  ),
                ),
                InkWell(
                  onTap: () => Get.back(),
                  child: Icon(
                    Icons.close,
                    size: 24.w,
                    color: AppColor.coolGray21,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Tier Options
            ...tiers.map((tier) {
              final isSelected = tier['id'] == selectedTierId;
              return InkWell(
                onTap: () {
                  setState(() {
                    selectedTierId = tier['id'] as String;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? AppColor.buttonColor
                          : AppColor.coolGray19,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                    color: isSelected
                        ? AppColor.buttonColor.withOpacity(0.05)
                        : AppColor.white,
                  ),
                  child: Row(
                    children: [
                      // Radio Button
                      Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColor.buttonColor
                                : AppColor.coolGray21,
                            width: 2,
                          ),
                          color: isSelected
                              ? AppColor.buttonColor
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 14.w,
                                color: AppColor.white,
                              )
                            : null,
                      ),

                      SizedBox(width: 12.w),

                      // Tier Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tier['name'] as String,
                              style: sansMedium.copyWith(
                                fontSize: 16.sp,
                                color: AppColor.primaryColor,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              tier['type'] == 'time'
                                  ? '${tier['duration']} hours'
                                  : '${tier['max_views']} views',
                              style: sansReg.copyWith(
                                fontSize: 12.sp,
                                color: AppColor.coolGray21,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Price
                      Text(
                        '\$${tier['price']}',
                        style: sansSemiBold.copyWith(
                          fontSize: 16.sp,
                          color: AppColor.buttonColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            SizedBox(height: 24.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Cancel',
                    height: 40.h,
                    color: AppColor.white,
                    borderColor: AppColor.coolGray21,
                    textStyle: sansMedium.copyWith(
                      color: AppColor.coolGray21,
                      fontSize: 14.sp,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Obx(() {
                    return CustomButton(
                      text: promoteController.isLoading.value
                          ? 'Processing...'
                          : 'Pay & Promote',
                      height: 40.h,
                      isLoading: promoteController.isLoading.value,
                      onPressed: promoteController.isLoading.value
                          ? null
                          : () async {
                              final price = selectedTier['price'];
                              final type = selectedTier['type'] as String;
                              final priceValue = price is double 
                                  ? price 
                                  : (price is int 
                                      ? price.toDouble() 
                                      : double.tryParse(price.toString()) ?? 0.0);
                              
                              print("Selected tier: $selectedTier");
                              print("Price value: $priceValue (type: ${priceValue.runtimeType})");
                              print("Type: $type");
                              
                              await promoteController.createPromotion(
                                cardId: widget.cardId,
                                promotionPrice: priceValue,
                                promotionType: type,
                                promotionDuration: type == 'time'
                                    ? (selectedTier['duration'] as int?)
                                    : null,
                                maxViews: type == 'impression'
                                    ? (selectedTier['max_views'] as int?)
                                    : null,
                              );
                              if (promoteController.isSuccess.value) {
                                Get.back();
                                showCustomSnackBar(
                                  'Promotion created! Your card will appear in Spotlight Deals.',
                                  isError: false,
                                );
                                // Refresh My Cards page
                                try {
                                  final dashboardController =
                                      Get.find<DashboardController>();
                                  dashboardController.fetchMyCards(
                                    isReload: true,
                                  );
                                } catch (_) {}
                              }
                            },
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

