import 'dart:convert';
import 'package:classified/model/card_model.dart';
import 'package:classified/utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controller/dashboard_controller.dart';
import '../../controller/navigation_controller.dart';
import '../../routes/app_routes.dart';
import '../../transition/fade_transition.dart';
import '../../utils/_constant.dart';
import '../../utils/app_color.dart';
import '../../utils/app_image.dart';
import '../../utils/app_text.dart';
import '../../utils/image_loader.dart';
import '../../widget/custom_app_bar.dart';
import '../../widget/custom_button.dart';
import '../../widget/custom_snackbar_widget.dart';
import '../../widget/my_shop_widget.dart';
import '../../view/dialog/promote_modal.dart';
import '../../controller/dashboard_controller.dart';


class MyShopScreen extends StatefulWidget {
  const MyShopScreen({super.key});

  @override
  State<MyShopScreen> createState() => _MyShopScreenState();
}

class _MyShopScreenState extends State<MyShopScreen> {
  late DashboardController dashboardController;
  bool isFavorite = false;
  int currentImageIndex = 0;
  late dynamic type;
  late dynamic routeType;
  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    type = args?['type'];
    routeType = args?['route'];
    dashboardController = Get.find<DashboardController>();
    if (type == 'my') {
      dashboardController.setStatus('Active');
    }
    else if(type == 'pen'){
      dashboardController.setStatus('Pending');
    }else if(type == 'rej'){
      dashboardController.setStatus('Rejected');
    }

    // Fetch cards on init
    dashboardController.fetchMyCards(isReload: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(title: AppText.myShop,
        onTapBack: () {
          // Always redirect to profile page (bottom nav index 3)
          // Set the index value first (this is safe even if PageView isn't attached yet)
          try {
            final navController = Get.find<NavigationController>();
            navController.index.value = 3; // Set the observable value directly
          } catch (e) {
            // Controller might not be ready yet, will set after navigation
          }
          
          // Navigate to bottom nav route, clearing all previous routes
          // This ensures we always go to profile page, not home page
          Get.offAllNamed(Routes.bottomNavRoute);
          
          // Set index again after navigation completes and PageView is attached
          // Use multiple callbacks to ensure it works
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(milliseconds: 50), () {
              try {
                final controller = Get.find<NavigationController>();
                controller.setIndex(3); // This will check if PageController is attached
              } catch (_) {}
            });
          });
        },
      ),
      body: CustomScrollView(
        slivers: [
          ///  Shrinkable Image Header
          SliverPersistentHeader(
            pinned: true,
            delegate: _ImageHeaderDelegate(
              maxExtent: 78.h,
              minExtent: 0,
              child: Padding(
                padding: EdgeInsets.only(left: 16.w, top: 16.h, bottom: 20.h),
                child: SizedBox(
                  height: 44.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: dashboardController.statusOptions.length,
                    itemBuilder: (context, index) {
                      final status = dashboardController.statusOptions[index];

                      return Obx(() {
                        final isSelected = dashboardController.selectedStatus.value == status;
                        return CustomButton(
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 11.h,
                          ),
                          text: status.toUpperCase(),
                          marginRight: 12.w,
                          marginLeft: 0.w,
                          borderRadius: 3.r,
                          borderWidth: 0.6.w,
                          color:
                          isSelected
                              ? AppColor.buttonColor
                              : AppColor.white,
                          borderColor:AppColor.buttonColor,
                          onPressed: () {
                            dashboardController.setStatus(status);
                          },
                          textStyle:
                          isSelected
                              ? sansBold.copyWith(
                            color: Colors.white,
                            fontSize: 14.sp,
                            letterSpacing: 1.12
                          )
                              : sansMedium.copyWith(
                            color: AppColor.buttonColor,
                            fontSize: 14.sp,
                          ),
                        );
                      });
                    },
                  ),
                ),
              ),
            ),
          ),

          /// normal content - Show cards
          SliverToBoxAdapter(
            child: Obx(() {
              // Check loading state for cards
              if (dashboardController.isCardsLoading.value) {
                return Align(
                  alignment: AlignmentDirectional.bottomCenter,
                  child: Column(
                    children: [
                      SizedBox(height: 200.h,),
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColor.buttonColor,
                      ),
                    ],
                  ),
                );
              }
              
              // Check if cards list is empty
              if (dashboardController.myCardsList.isEmpty) {
                return Align(
                  alignment: AlignmentDirectional.bottomCenter,
                  child: Column(
                    children: [
                      SizedBox(height: 180.h),
                      SvgPicture.asset(
                        AppImage.icNoData,
                        height: 200.h,
                        width: 275.w,
                      ),
                      SizedBox(height: 29.h),
                      Text(
                        'No cards found.',
                        style: sansReg.copyWith(
                          color: AppColor.primaryColor,
                          fontSize: 15.h,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              // Display cards
              return ListView.builder(
                itemCount: dashboardController.myCardsList.length,
                scrollDirection: Axis.vertical,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final cardData = dashboardController.myCardsList[index];
                  final lastIndex = dashboardController.myCardsList.length - 1;
                  
                  // Parse card data to CardItem
                  try {
                    final card = CardItem.fromJson(cardData);
                    return _buildCardWidget(
                      card: card,
                      dashboardController: dashboardController,
                      topMargin: index == 0 ? 0 : 20.h,
                    bottomMargin: index == lastIndex ? 40.h : 0,
                  );
                  } catch (e) {
                    return SizedBox.shrink();
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ImageHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  final double minExtent;
  @override
  final double maxExtent;
  final Widget child;

  _ImageHeaderDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.child,
  });

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _ImageHeaderDelegate old) {
    return old.minExtent != minExtent ||
        old.maxExtent != maxExtent ||
        old.child != child;
  }
}

// Card widget for displaying cards in My Cards page
Widget _buildCardWidget({
  required CardItem card,
  required DashboardController dashboardController,
  required double topMargin,
  required double bottomMargin,
}) {
  // Parse images
  List<String> imageList = [];
  if (card.images != null) {
    try {
      if (card.images is String) {
        try {
          final decoded = jsonDecode(card.images!);
          if (decoded is List) {
            imageList = decoded.map((e) => e.toString()).toList();
          } else if (decoded is String) {
            imageList = [decoded];
          }
        } catch (e) {
          imageList = [card.images!];
        }
      } else if (card.images is List) {
        imageList = (card.images as List).map((e) => e.toString()).toList();
      } else {
        imageList = [card.images.toString()];
      }
    } catch (e) {
      if (card.images != null) {
        imageList = [card.images.toString()];
      }
    }
  }

  final firstImage = imageList.isNotEmpty ? imageList.first : '';
  final status = card.requestStatus ?? 'pending';
  
  // Map status to display text
  String statusText = 'Pending';
  Color statusColor = Colors.orange;
  if (status.toLowerCase() == 'approved') {
    statusText = 'Active';
    statusColor = Colors.green;
  } else if (status.toLowerCase() == 'rejected') {
    statusText = 'Rejected';
    statusColor = Colors.red;
  } else if (status.toLowerCase() == 'pending') {
    statusText = 'Pending';
    statusColor = Colors.orange;
  }

  return Container(
    margin: EdgeInsets.only(
      right: 16.w,
      left: 16.w,
      top: topMargin,
      bottom: bottomMargin,
    ),
    width: double.infinity,
    decoration: BoxDecoration(
      color: AppColor.white,
      border: Border.all(color: AppColor.coolGray17, width: 1.15.sp),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card Image
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.r),
            topRight: Radius.circular(12.r),
          ),
          child: firstImage.isNotEmpty
              ? ImageLoader(
                  url: '${Constant.imageBaseUrl}$firstImage',
                  height: 200.h,
                  width: double.infinity,
                  boxFit: BoxFit.cover,
                )
              : Container(
                  height: 200.h,
                  width: double.infinity,
                  color: AppColor.ghostWhite,
                  child: Icon(Icons.image, size: 48.w, color: AppColor.coolGray21),
                ),
        ),
        
        // Card Details
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Title
              Text(
                card.cardTitle ?? '',
                style: sansSemiBold.copyWith(
                  fontSize: 16.sp,
                  color: AppColor.primaryColor,
                  height: 1.4.h,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: 8.h),
              
              // Status Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Text(
                  statusText.toUpperCase(),
                  style: sansMedium.copyWith(
                    fontSize: 12.sp,
                    color: statusColor,
                  ),
                ),
              ),
              
              SizedBox(height: 12.h),
              
              // Price and Sport Type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${card.price ?? '0.00'}',
                    style: sansBold.copyWith(
                      fontSize: 18.sp,
                      color: AppColor.buttonColor,
                    ),
                  ),
                  if (card.sportType != null && card.sportType!.isNotEmpty)
                    Text(
                      card.sportType!,
                      style: sansMedium.copyWith(
                        fontSize: 14.sp,
                        color: AppColor.coolGray21,
                      ),
                    ),
                ],
              ),
              
              SizedBox(height: 16.h),
              
              // Action Buttons: Edit, Delete, Promote
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Edit',
                      height: 40.h,
                      onPressed: () {
                        // Navigate to edit card screen
                        FadeScreenTransition(
                          routeName: Routes.editCardRoute,
                          arguments: {'cardId': card.id},
                        ).navigate();
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: CustomButton(
                      text: 'Delete',
                      height: 40.h,
                      color: Colors.red,
                      onPressed: () {
                        _showDeleteConfirmation(card, dashboardController);
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Obx(() {
                      final isPromoted = dashboardController.isCardPromoted(card.id);
                      return CustomButton(
                        text: isPromoted ? 'Promoted' : 'Promote',
                        height: 40.h,
                        color: isPromoted ? Colors.grey : AppColor.buttonColor,
                        onPressed: isPromoted
                            ? null
                            : () {
                                // Show promote modal
                                _showPromoteModal(card, dashboardController);
                              },
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

void _showDeleteConfirmation(CardItem card, DashboardController dashboardController) {
  Get.dialog(
    AlertDialog(
      title: Text(
        'Delete Card',
        style: sansSemiBold.copyWith(
          fontSize: 18.sp,
          color: AppColor.primaryColor,
        ),
      ),
      content: Text(
        'Do you want to delete this card?',
        style: sansReg.copyWith(
          fontSize: 14.sp,
          color: AppColor.primaryColor,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Cancel',
            style: sansMedium.copyWith(
              fontSize: 14.sp,
              color: AppColor.coolGray21,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            Get.back();
            await dashboardController.deleteCard(cardId: card.id);
          },
          child: Text(
            'OK',
            style: sansMedium.copyWith(
              fontSize: 14.sp,
              color: Colors.red,
            ),
          ),
        ),
      ],
    ),
  );
}

void _showPromoteModal(CardItem card, DashboardController dashboardController) {
  // Show promote modal dialog
  Get.dialog(
    PromoteModal(cardId: card.id ?? 0),
    barrierDismissible: true,
  );
}
