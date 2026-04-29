import 'package:classified/controller/dashboard_controller.dart';
import 'package:classified/utils/app_color.dart';
import 'package:classified/utils/app_fonts.dart';
import 'package:classified/utils/app_image.dart';
import 'package:classified/utils/image_loader.dart';
import 'package:classified/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../controller/account_settings_controller.dart';
import '../../controller/user_data_controller.dart';
import '../../routes/app_routes.dart';
import '../../transition/fade_transition.dart';
import '../../utils/_constant.dart';
import '../../utils/app_text.dart';
import '../../widget/custom_app_bar.dart';
import '../../widget/profile_widgets/dashboard_items.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late AccountSettingsController accountSettingsController;
  late UserDataController userDataController;
  late DashboardController dashboardController;

  @override
  void initState() {
    super.initState();
    accountSettingsController = Get.find<AccountSettingsController>();
    userDataController = Get.find<UserDataController>();
    dashboardController = Get.find<DashboardController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userDataController.fetchUserData();
      accountSettingsController.fetchBillingData();
      dashboardController.fetchUserOrderData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppText.profile,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          Obx(() {
            return Skeletonizer(
              enabled: dashboardController.isUserOrderDataLoading.value,
              child: DashboardItems(
                color: AppColor.babyBlue,
                icon: AppImage.icTotalOrder,
                subTitle: AppText.totalOrders,
                title: dashboardController.userOrderData.value.totalOrders
                        ?.toString() ??
                    '0',
              ),
            );
          }),
          Obx(() {
            return Skeletonizer(
              enabled: dashboardController.isUserOrderDataLoading.value,
              child: DashboardItems(
                color: AppColor.lightGreen,
                icon: AppImage.icCompleteOrder,
                subTitle: AppText.completedOrders,
                title: dashboardController
                        .userOrderData.value.completedOrders
                        ?.toString() ??
                    '0',
              ),
            );
          }),
          Obx(() {
            return Skeletonizer(
              enabled: dashboardController.isUserOrderDataLoading.value,
              child: DashboardItems(
                color: AppColor.softPeach,
                icon: AppImage.icPendingOrder,
                subTitle: AppText.pendingOrders,
                title: dashboardController.userOrderData.value.pendingOrders
                        ?.toString() ??
                    '0',
              ),
            );
          }),
          SizedBox(height: 10.h),

          /// Account info
          Obx(() {
            final isLoading = userDataController.isUserDataLoading.value;

            return Skeletonizer(
              enabled: isLoading,
              textBoneBorderRadius:
                  TextBoneBorderRadius.fromHeightFactor(0.5),
              child: _InfoSection(
                title: AppText.accountInfo.toUpperCase(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 22.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile Image
                        ClipOval(
                          child: userDataController
                                          .userData.value.profileImg !=
                                      null &&
                                  userDataController
                                      .userData.value.profileImg!.isNotEmpty
                              ? ImageLoader(
                                  height: 48.w,
                                  width: 48.w,
                                  url:
                                      "${Constant.imageBaseUrl}${userDataController.userData.value.profileImg!.startsWith('/') ? userDataController.userData.value.profileImg!.substring(1) : userDataController.userData.value.profileImg}",
                                )
                              : Image.asset(
                                  AppImage.icDefaultDp,
                                  height: 48.w,
                                  width: 48.w,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        SizedBox(width: 16.w),

                        // Name & Address
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userDataController.userData.value.name
                                      ?.toString() ??
                                  '',
                              style: sansSemiBold.copyWith(
                                fontSize: 16.sp,
                                height: 1.5.h,
                                color: AppColor.primaryColor,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              userDataController.userData.value.address ??
                                  'N/A',
                              style: sansReg.copyWith(
                                fontSize: 14.sp,
                                height: 1.42.h,
                                color: AppColor.coolGray14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Email
                    Row(
                      children: [
                        Text(
                          'Email: ',
                          style: sansReg.copyWith(
                            fontSize: 14.sp,
                            height: 1.42.h,
                            color: AppColor.primaryColor,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            userDataController.userData.value.email
                                    ?.toString() ??
                                '',
                            style: sansReg.copyWith(
                              fontSize: 14.sp,
                              height: 1.42.h,
                              color: AppColor.coolGray14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),

                    // Phone
                    (userDataController.userData.value.phone != null &&
                            userDataController
                                .userData.value.phone!.isNotEmpty)
                        ? Padding(
                            padding: EdgeInsets.only(top: 10.h),
                            child: Row(
                              children: [
                                Text(
                                  'Phone: ',
                                  style: sansReg.copyWith(
                                    fontSize: 14.sp,
                                    height: 1.42.h,
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    userDataController.userData.value.phone
                                            ?.toString() ??
                                        '',
                                    style: sansReg.copyWith(
                                      fontSize: 14.sp,
                                      height: 1.42.h,
                                      color: AppColor.coolGray14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),

                    SizedBox(height: 22.h),
                    CustomButton(
                      width: 155.w,
                      marginRight: 0.w,
                      marginLeft: 0,
                      color: AppColor.white,
                      text: AppText.editAccount,
                      textStyle: sansBold.copyWith(
                        fontSize: 14.sp,
                        height: 3.42.h,
                        color: AppColor.buttonColor,
                        letterSpacing: .12,
                      ),
                      borderColor: AppColor.babyBlue1,
                      onPressed: () {
                        FadeScreenTransition(
                          routeName: Routes.accountSettingsRoute,
                        ).navigate();
                      },
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            );
          }),

          /// Billing address
          Obx(() {
            return Skeletonizer(
              enabled: accountSettingsController.isBillingLoading.value,
              child: _InfoSection(
                title: AppText.billingAddress.toUpperCase(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 22.h),
                    Text(
                      "${accountSettingsController.billingData.value.firstName ?? 'N/A'} ${accountSettingsController.billingData.value.lastName ?? ''}",
                      style: sansMedium.copyWith(
                        fontSize: 14.sp,
                        height: 1.42.h,
                        color: AppColor.primaryColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      accountSettingsController.billingData.value.address ??
                          'N/A',
                      style: sansReg.copyWith(
                        fontSize: 14.sp,
                        height: 1.42.h,
                        color: AppColor.coolGray14,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    Row(
                      children: [
                        Text(
                          'Email: ',
                          style: sansReg.copyWith(
                            fontSize: 14.sp,
                            height: 1.42.h,
                            color: AppColor.primaryColor,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            accountSettingsController
                                    .billingData.value.email ??
                                'N/A',
                            style: sansReg.copyWith(
                              fontSize: 14.sp,
                              height: 1.42.h,
                              color: AppColor.coolGray14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),

                    // Phone
                    (accountSettingsController.billingData.value.phone !=
                                null &&
                            accountSettingsController
                                .billingData.value.phone!.isNotEmpty)
                        ? Padding(
                            padding: EdgeInsets.only(top: 10.h),
                            child: Row(
                              children: [
                                Text(
                                  'Phone: ',
                                  style: sansReg.copyWith(
                                    fontSize: 14.sp,
                                    height: 1.42.h,
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    userDataController.userData.value.phone
                                            ?.toString() ??
                                        '',
                                    style: sansReg.copyWith(
                                      fontSize: 14.sp,
                                      height: 1.42.h,
                                      color: AppColor.coolGray14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                    SizedBox(height: 22.h),
                    CustomButton(
                      width: 155.w,
                      marginRight: 0.w,
                      marginLeft: 0,
                      color: AppColor.white,
                      text: AppText.editAddress,
                      textStyle: sansBold.copyWith(
                        fontSize: 14.sp,
                        height: 3.42.h,
                        color: AppColor.buttonColor,
                        letterSpacing: .12,
                      ),
                      borderColor: AppColor.babyBlue1,
                      onPressed: () {
                        FadeScreenTransition(
                          routeName: Routes.billingAddressRoute,
                        ).navigate();
                      },
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            );
          }),

          SizedBox(height: 70.h),
        ],
      ),
    );
  }
}

// Info box section
class _InfoSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: AppColor.coolGray12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 24.w, top: 16.h, bottom: 16.h),
            child: Text(
              title,
              style: sansMedium.copyWith(
                fontSize: 14.sp,
                color: AppColor.primaryColor,
                height: 1.42.h,
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 16.h),
            child: child,
          ),
        ],
      ),
    );
  }
}

