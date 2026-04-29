import 'package:classified/controller/premium_controller.dart';
import 'package:classified/model/package_model.dart';
import 'package:classified/utils/app_color.dart';
import 'package:classified/utils/app_fonts.dart';
import 'package:classified/utils/app_image.dart';
import 'package:classified/utils/app_text.dart';
import 'package:classified/utils/session_manager.dart';
import 'package:classified/widget/custom_app_bar.dart';
import 'package:classified/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  PremiumScreenState createState() => PremiumScreenState();
}

class PremiumScreenState extends State<PremiumScreen> {

  late PremiumController premiumController;
  late dynamic userPackage;
  late dynamic packageId;

  @override
  void initState() {
    super.initState();
    premiumController = Get.find<PremiumController>();
    loadPackageData();
  }

  void loadPackageData() {
    userPackage = SessionManager.getValue(kUserPackage);
    packageId = SessionManager.getValue(kPackageId);
    premiumController.packageId.value = packageId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Membership Plan',),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 6.h),
        child: Obx(() {
          final isLoading = premiumController.isLoadingPackages.value;
          return Skeletonizer(
            enabled: isLoading,
            child: Column(
              children: [
                _buildSubscriptionToggle(),
                SizedBox(height: 30),
                Obx(() {
                  // Check if packageList has at least 3 items (indices 0, 1, 2)
                  final hasFreePlan = !isLoading && 
                      premiumController.packageList.length > 2 &&
                      premiumController.packageList[2].packages != null &&
                      premiumController.packageList[2].packages!.isNotEmpty;
                  
                  final pkg = isLoading || !hasFreePlan 
                      ? Package() 
                      : premiumController.packageList[2].packages![0];
                  final isCurrent = pkg?.id == premiumController.packageId.value;
                  return
                    _buildPlanCard(
                        price: 'FREE PLAN',
                        item: isLoading || !hasFreePlan ? Package() : premiumController.packageList[2].packages![0],
                        isHighlighted: isCurrent,
                        bgImage: AppImage.icPremiumOne,
                        onTap: () {
                          if (hasFreePlan) {
                          premiumController.packageId.value = pkg?.id ?? 0;
                          }
                        }
                    );
                }),
                SizedBox(height: 20),
                Obx(() {
                  final selected = premiumController.selectedIndex.value;
                  // Check if packageList has the selected index and has packages
                  final hasSelectedPlan = !isLoading && 
                      premiumController.packageList.length > selected &&
                      premiumController.packageList[selected].packages != null &&
                      premiumController.packageList[selected].packages!.isNotEmpty;
                  
                  final pkg = isLoading || !hasSelectedPlan 
                      ? Package() 
                      : premiumController.packageList[selected].packages![0];
                  final item = isLoading || !hasSelectedPlan 
                      ? PackageData() 
                      : premiumController.packageList[selected];
                  final isCurrent = pkg.id == premiumController.packageId.value;
                  return _buildPlanCard(
                      price: "\$${pkg.price ?? '0.00'}",
                      type: "(${item.title ?? ''})",
                      item: pkg,
                      isHighlighted: isCurrent,
                      bgImage: AppImage.icPremiumTwo,
                      onTap: () {
                        if (hasSelectedPlan) {
                        premiumController.packageId.value = pkg.id ?? 0;
                      }
                      }
                  );
                }),
                SizedBox(height: 32),
                Obx(() {
                  return CustomButton(
                    color: (premiumController.packageId.value == 1 ||
                        premiumController.packageId.value <= packageId)
                        ? AppColor.buttonColor.withValues(alpha: .5)
                        : AppColor.buttonColor,
                    borderColor: (premiumController.packageId.value == 1 ||
                        premiumController.packageId.value == packageId)
                        ? AppColor.buttonColor.withValues(alpha: .5)
                        : AppColor.buttonColor,
                    marginLeft: 0,
                    marginRight: 0,
                    isLoading: premiumController.isPackageLoading.value,
                    text: premiumController.packageId.value == 1
                        ? 'Free Plan'
                        : premiumController.packageId.value == packageId
                        ? AppText.currentPlan
                        : 'Upgrade Plan',
                    onPressed: () {
                      if (premiumController.packageId.value == 1 ||
                          premiumController.packageId.value <= packageId ) {}
                      else {
                        premiumController.purchasePackage();
                      }
                    },
                  );
                }),
                SizedBox(height: 100.h,),
              ],
            ),
          );
        }),
      ),
    );
  }


  Widget _buildSubscriptionToggle() {
    return Obx(() {
      return Container(
        height: 38.h,
        width: 184.w,
        decoration: BoxDecoration(
          color: AppColor.coolGray16,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [

            AnimatedAlign(
              alignment: premiumController.isMonthlySelected.value
                  ? Alignment.centerLeft : Alignment.centerRight,
              duration: Duration(milliseconds: 150),
              child: Container(
                width: 99.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColor.buttonColor,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

            // Static text layer
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      premiumController.selectMonthly();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          bottomLeft: Radius.circular(30),
                        ),
                        border: Border(
                          bottom: BorderSide(
                              color: AppColor.buttonColor.withValues(
                                  alpha: 0.06)),
                          left: BorderSide(
                              color: AppColor.buttonColor.withValues(
                                  alpha: 0.06)),
                          top: BorderSide(
                              color: AppColor.buttonColor.withValues(
                                  alpha: 0.06)),
                        ),
                      ),
                      child: Text(
                        'Monthly',
                        textAlign: TextAlign.center,
                        style: sansSemiBold.copyWith(
                          color: premiumController.isMonthlySelected.value
                              ? Colors.white
                              : AppColor.dark1,
                          fontSize: 16.sp,
                          height: 1.25.h,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      premiumController.selectYearly();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        border: Border(
                          bottom: BorderSide(
                              color: AppColor.buttonColor.withValues(
                                  alpha: 0.06)),
                          right: BorderSide(
                              color: AppColor.buttonColor.withValues(
                                  alpha: 0.06)),
                          top: BorderSide(
                              color: AppColor.buttonColor.withValues(
                                  alpha: 0.06)),
                        ),
                      ),
                      child: Text(
                        'Yearly',
                        textAlign: TextAlign.center,
                        style: sansSemiBold.copyWith(
                          color: !premiumController.isMonthlySelected.value
                              ? Colors.white
                              : AppColor.dark1,
                          fontSize: 16.sp,
                          height: 1.25.h,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }


  Widget _buildPlanCard({
    required String bgImage,
    String? price,
    VoidCallback? onTap,
    String? type,
    required Package item,
    bool isHighlighted = false,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(
          minHeight: 300.h,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          boxShadow: isHighlighted ? [
            BoxShadow(
                spreadRadius: 0,
                blurRadius: 24,
                offset: Offset(0, 6),
                color: AppColor.buttonColor1.withValues(alpha: .10)
            )
          ] : null,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: AppColor.buttonColor.withValues(
              alpha: isHighlighted ? .60 : .30)),
          color: isHighlighted
              ? AppColor.buttonColor.withValues(alpha: .15)
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: SvgPicture.asset(bgImage, 
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 52.w, top: 40.h, right: 52.w, bottom: 40.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title.toString().toUpperCase(),
                    style: sansSemiBold.copyWith(
                      fontSize: 16.sp,
                      height: 1.25.h,
                      color: AppColor.dark1,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColor.dark1,
                    ),

                  ),
                  SizedBox(height: 40),
                  Row(
                    children: [
                      Text(
                        price!,
                        style: sansSemiBold.copyWith(
                            fontSize: 24.sp,
                            color: AppColor.buttonColor,
                            letterSpacing: -.2
                        ),
                      ),
                      SizedBox(width: 3.w,),
                      Flexible(
                        child: Text(
                        type ?? '',
                        style: sansSemiBold.copyWith(
                            fontSize: 20.sp,
                            color: AppColor.dark1.withValues(alpha: .5),
                            letterSpacing: -.2
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  ...List.generate(
                    item.packageAdvantage?.length ?? 0,
                    (index) => _buildFeatureRow(
                          item.packageAdvantage![index].title.toString(),
                      isHighlighted,
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String text, bool isHighlighted) {
    return Padding(
      padding: EdgeInsets.only(bottom: 17.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(AppImage.icCheckThree, height: 9.h, width: 12.w,),
          SizedBox(width: 17.w),
          Expanded(
            child: Text(
              text,
              style: sansMedium.copyWith(
                fontSize: 15.sp,
                height: 1.19.h,
                color: AppColor.dark1.withValues(alpha: .70),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }


}