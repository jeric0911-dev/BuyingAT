import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/promote_cards_controller.dart';
import '../service/api/api_client.dart';
import '../utils/_constant.dart';
import '../utils/app_color.dart';
import '../utils/app_fonts.dart';
import '../utils/image_loader.dart';
import '../widget/custom_app_bar.dart';
import '../widget/custom_snackbar_widget.dart';

class PromoteCardsScreen extends StatefulWidget {
  const PromoteCardsScreen({super.key});

  @override
  State<PromoteCardsScreen> createState() => _PromoteCardsScreenState();
}

class _PromoteCardsScreenState extends State<PromoteCardsScreen> {
  late PromoteCardsController promoteCardsController;

  @override
  void initState() {
    super.initState();
    final apiClient = Get.find<ApiClient>();
    promoteCardsController = Get.put(
      PromoteCardsController(apiClient: apiClient),
      tag: 'promote_cards',
    );
    promoteCardsController.fetchMyPromotions();
  }

  String _formatRemaining(Map<String, dynamic> promotion) {
    try {
      final promotionType = promotion['promotion_type']?.toString();
      if (promotionType == 'time') {
        final expiresAt = promotion['expires_at'];
        if (expiresAt == null) return '—';
        try {
          final expiresAtDate = DateTime.parse(expiresAt.toString());
          final now = DateTime.now();
          if (expiresAtDate.isBefore(now)) return 'Expired';
          // Format as MM/DD/YYYY
          final month = expiresAtDate.month.toString().padLeft(2, '0');
          final day = expiresAtDate.day.toString().padLeft(2, '0');
          final year = expiresAtDate.year.toString();
          return '$month/$day/$year';
        } catch (e) {
          return '—';
        }
      }
      if (promotionType == 'impression') {
        final views = promotion['promotion_views'] ?? 0;
        final maxViews = promotion['max_views'];
        if (maxViews == null) return '$views views';
        return '$views/$maxViews views';
      }
    } catch (e) {
      print("Error formatting remaining: $e");
    }
    return '—';
  }

  String _formatStatus(Map<String, dynamic> promotion) {
    try {
      final status = promotion['status']?.toString() ?? 'active';
      return status.toUpperCase();
    } catch (e) {
      return 'ACTIVE';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'expired':
      case 'completed':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(
        title: 'Promote Cards',
        onTapBack: () => Get.back(),
      ),
      body: Obx(() {
        if (promoteCardsController.isLoading.value &&
            promoteCardsController.promotionsList.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColor.buttonColor,
            ),
          );
        }

        if (promoteCardsController.promotionsList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.campaign,
                  size: 64.w,
                  color: AppColor.coolGray21,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No promotions yet.',
                  style: sansReg.copyWith(
                    fontSize: 16.sp,
                    color: AppColor.coolGray21,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Promoted Cards',
                style: sansSemiBold.copyWith(
                  fontSize: 20.sp,
                  color: AppColor.primaryColor,
                ),
              ),
              SizedBox(height: 16.h),
               GridView.builder(
                 shrinkWrap: true,
                 physics: NeverScrollableScrollPhysics(),
                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                   crossAxisCount: 1,
                   mainAxisSpacing: 16.h,
                   crossAxisSpacing: 16.w,
                   childAspectRatio: 2.0,
                 ),
                itemCount: promoteCardsController.promotionsList.length,
                itemBuilder: (context, index) {
                  final promotion = promoteCardsController.promotionsList[index];
                  
                  // Safely access promotion data
                  if (promotion is! Map<String, dynamic>) {
                    return SizedBox.shrink();
                  }
                  
                  final item = promotion['item'] as Map<String, dynamic>?;
                  final status = _formatStatus(promotion);
                  final statusColor = _getStatusColor(status);

                  // Parse image path
                  String? imagePath;
                  if (item != null && item['image_path'] != null) {
                    imagePath = item['image_path'].toString();
                    if (imagePath.startsWith('/storage/')) {
                      imagePath = imagePath.substring(9);
                    } else if (imagePath.startsWith('storage/')) {
                      imagePath = imagePath.substring(8);
                    }
                  }

                   return Container(
                     padding: EdgeInsets.all(12.w),
                     decoration: BoxDecoration(
                       color: AppColor.white,
                       border: Border.all(
                         color: statusColor == Colors.green
                             ? Colors.green.shade200
                             : AppColor.coolGray17,
                         width: 1,
                       ),
                       borderRadius: BorderRadius.circular(12.r),
                       boxShadow: [
                         BoxShadow(
                           color: Colors.black.withOpacity(0.05),
                           blurRadius: 4,
                           offset: Offset(0, 2),
                         ),
                       ],
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       mainAxisSize: MainAxisSize.min,
                       children: [
                        // Card Image and Info
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card Image
                            Container(
                              width: 80.w,
                              height: 80.w,
                              decoration: BoxDecoration(
                                color: AppColor.ghostWhite,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: AppColor.coolGray17,
                                  width: 1,
                                ),
                              ),
                              child: imagePath != null && imagePath.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: ImageLoader(
                                        url: '${Constant.imageBaseUrl}$imagePath',
                                        width: 80.w,
                                        height: 80.w,
                                        boxFit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      Icons.image,
                                      size: 32.w,
                                      color: AppColor.coolGray21,
                                    ),
                            ),
                            SizedBox(width: 12.w),
                             // Card Info
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   Row(
                                     mainAxisAlignment:
                                         MainAxisAlignment.spaceBetween,
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Expanded(
                                         child: Text(
                                           item?['title'] ?? 'Card',
                                           style: sansSemiBold.copyWith(
                                             fontSize: 16.sp,
                                             color: AppColor.primaryColor,
                                           ),
                                           maxLines: 2,
                                           overflow: TextOverflow.ellipsis,
                                         ),
                                       ),
                                       SizedBox(width: 8.w),
                                       Container(
                                         padding: EdgeInsets.symmetric(
                                           horizontal: 8.w,
                                           vertical: 4.h,
                                         ),
                                         decoration: BoxDecoration(
                                           color: statusColor.withOpacity(0.1),
                                           borderRadius:
                                               BorderRadius.circular(12.r),
                                           border: Border.all(
                                             color: statusColor,
                                             width: 1,
                                           ),
                                         ),
                                         child: Text(
                                           status,
                                           style: sansMedium.copyWith(
                                             fontSize: 10.sp,
                                             color: statusColor,
                                           ),
                                         ),
                                       ),
                                     ],
                                   ),
                                   SizedBox(height: 4.h),
                                   Text(
                                     '\$${item?['price']?.toString() ?? promotion['promotion_price']?.toString() ?? '0.00'}',
                                     style: sansBold.copyWith(
                                       fontSize: 18.sp,
                                       color: AppColor.buttonColor,
                                     ),
                                   ),
                                   SizedBox(height: 4.h),
                                   // Promotion type badge
                                   Container(
                                     padding: EdgeInsets.symmetric(
                                       horizontal: 6.w,
                                       vertical: 2.h,
                                     ),
                                     decoration: BoxDecoration(
                                       color: Colors.green.shade50,
                                       borderRadius: BorderRadius.circular(8.r),
                                       border: Border.all(
                                         color: Colors.green.shade200,
                                         width: 1,
                                       ),
                                     ),
                                     child: Text(
                                       promotion['promotion_type']?.toString() ?? '—',
                                       style: sansReg.copyWith(
                                         fontSize: 10.sp,
                                         color: Colors.green.shade700,
                                       ),
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                          ],
                        ),
                         SizedBox(height: 8.h),
                         // Promotion Details
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             // Left side: Ends on / Remaining
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   Text(
                                     promotion['promotion_type']?.toString() == 'time'
                                         ? 'Ends on:'
                                         : 'Remaining:',
                                     style: sansReg.copyWith(
                                       fontSize: 12.sp,
                                       color: AppColor.coolGray21,
                                     ),
                                   ),
                                   SizedBox(height: 2.h),
                                   Text(
                                     _formatRemaining(promotion),
                                     style: sansSemiBold.copyWith(
                                       fontSize: 14.sp,
                                       color: AppColor.primaryColor,
                                     ),
                                   ),
                                   SizedBox(height: 2.h),
                                   Text(
                                     'Started: ${_formatDate(promotion['created_at'])}',
                                     style: sansReg.copyWith(
                                       fontSize: 10.sp,
                                       color: AppColor.coolGray21,
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                            // Right side: Price
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Price:',
                                  style: sansReg.copyWith(
                                    fontSize: 12.sp,
                                    color: AppColor.coolGray21,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  '\$${promotion['promotion_price']?.toString() ?? '0.00'}',
                                  style: sansSemiBold.copyWith(
                                    fontSize: 14.sp,
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '—';
    try {
      final dateTime = DateTime.parse(date.toString());
      final month = dateTime.month.toString().padLeft(2, '0');
      final day = dateTime.day.toString().padLeft(2, '0');
      final year = dateTime.year.toString();
      final hour12 = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final second = dateTime.second.toString().padLeft(2, '0');
      final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
      return '$month/$day/$year, $hour12:$minute:$second $amPm';
    } catch (e) {
      return '—';
    }
  }
}

