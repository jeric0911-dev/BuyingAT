import 'package:classified/model/product_model.dart';
import 'package:classified/utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../controller/navigation_controller.dart';
import '../../utils/_constant.dart';
import '../../utils/image_loader.dart';
import '../../utils/session_manager.dart';
import '../controller/dashboard_controller.dart';
import '../helper/format_price_helper.dart';
import '../helper/time_ago_helper.dart';
import '../routes/app_routes.dart';
import '../transition/fade_transition.dart';
import '../utils/app_color.dart';
import '../utils/app_image.dart';
import '../utils/app_text.dart';
import '../view/bottom_sheet/stock_manage_bottom_sheet.dart';
import '../view/dialog/boost_dialog.dart';
import 'custom_button.dart';

class MyShopWidget extends StatefulWidget {
  final ProductsItem? myProducts;
  final DashboardController dashboardController;
  final double? bottomMargin;
  final double? topMargin;

  const MyShopWidget({
    super.key,
    this.myProducts,
    this.bottomMargin,
    this.topMargin, required this.dashboardController,
  });

  @override
  State<MyShopWidget> createState() => _MyShopWidgetState();
}

class _MyShopWidgetState extends State<MyShopWidget> {
  late dynamic myUserId;
  late dynamic isLoggedIn;
  late NavigationController navigationController;

  @override
  void initState() {
    super.initState();
    myUserId = SessionManager.getValue(kUserId, value: 0);
    isLoggedIn = SessionManager.getValue(kIsLOGIN, value: false);
    navigationController = Get.find<NavigationController>();
  }

  @override
  Widget build(BuildContext context) {
    final carId = widget.myProducts?.id?.toString();
    if (carId == null) return const SizedBox();
    int totalStock = 0;
    if (widget.myProducts?.stocks != null && widget.myProducts!.stocks!.isNotEmpty) {
      totalStock = widget.myProducts!.stocks
          !.map((s) => int.tryParse(s.stock?.toString() ?? '0') ?? 0).reduce((a, b) => a + b);
    } else {
      totalStock = int.tryParse(widget.myProducts?.stock?.toString() ?? '0') ?? 0;
    }

    final isOutOfStock = totalStock == 0;

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {

        FadeScreenTransition(routeName: Routes.productDtlRoute, arguments: {'PId':widget.myProducts!.id,'productUserId':widget.myProducts!.userId}).navigate();
      },
      child: Container(
        margin: EdgeInsets.only(
          right: 16.w,
          left: 16.w,
          top: widget.topMargin ?? 14.h,
          bottom: widget.bottomMargin ?? 6.h,
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
            ImageLoader(
              url:
                  '${Constant.imageBaseUrl}${widget.myProducts?.getGalleryImages?.first.img ?? ''}',
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
              height: 200.h,
              width: double.infinity,
              boxFit: BoxFit.cover,
            ),

            SizedBox(height: 14.h),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.myProducts?.productTitle.toString() ?? '',
                            style: interSemiBold.copyWith(
                              fontSize: 18.sp,
                              color: AppColor.dark2,
                              height: 1.h,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              SvgPicture.asset(
                                AppImage.icTimeCircle,
                                width: 16.w,
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                formatTimeAgo(
                                  widget.myProducts?.createdAt.toString() ?? '',
                                ),
                                style: sansReg.copyWith(
                                  fontSize: 16.sp,
                                  color: AppColor.coolGray9,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 14.h),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '\$ ',
                                  style: sansSemiBold.copyWith(
                                    fontSize: 20.sp,
                                    color: AppColor.buttonColor,
                                    height: 1,
                                  ),
                                ),
                                TextSpan(
                                  text: formatPriceHelper(
                                    widget.myProducts?.price.toString(),
                                  ),
                                  style: sansSemiBold.copyWith(
                                    fontSize: 20.sp,
                                    color: AppColor.buttonColor,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 14.h),
                        ],
                      ),

                      Positioned(
                        right: 0,
                        bottom: 15,
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  isOutOfStock
                                      ? 'Stock Out'
                                      : 'In Stock',
                                  style: sansReg.copyWith(
                                    fontSize: 14.sp,
                                    color:isOutOfStock? AppColor.amberOrange: AppColor.coolGray9,
                                    height: 1.42,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  isOutOfStock ?'0' : totalStock.toString(),
                                  style: sansBold.copyWith(
                                    fontSize: 16.sp,
                                    color: AppColor.leafGreen4,
                                    height: 1.25,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 24.w),
                            SizedBox(
                              height: 41.h,
                              child: VerticalDivider(
                                color: AppColor.coolGray15,
                                thickness: 1.w,
                              ),
                            ),
                            SizedBox(width: 24.w),
                            InkWell(
                              onTap: () {
                                Get.bottomSheet(
                                    isDismissible:  false,
                                  isScrollControlled: true,
                                    StockManageBottomSheet(productId: widget.myProducts!.id,dashboardController: widget.dashboardController,productsItem: widget.myProducts ?? ProductsItem(),),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(30.r),
                                      topRight: Radius.circular(30.r),
                                    ),
                                  ),
                                  backgroundColor: Colors.white,
                                );
                              },
                                child: SvgPicture.asset(AppImage.icPlusMinus)
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Divider(color: AppColor.coolGray15, height: .88.h),
                          SizedBox(height: 16.h),
                          if (widget.myProducts?.status == 'Active')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomButton(
                                  color: widget.myProducts?.isFeatured == 1
                                      ? AppColor.leafGreen
                                      : AppColor.goldenYellow1,
                                  height: 38.h,
                                  width: 168.w,
                                  textStyle: interMedium.copyWith(
                                    fontSize: 16.sp,
                                    color: AppColor.white,
                                  ),
                                  leading: SvgPicture.asset(
                                    AppImage.icFeature,
                                    height: 16.h,
                                    width: 12.w,
                                  ),
                                  iconTextWidth: 8.w,
                                  text: AppText.boost,
                                  borderRadius: 4.r,
                                  marginLeft: 0,
                                  marginRight: 0,
                                  onPressed: () {
                                      if (widget.myProducts?.isFeatured != 1) {
                                        Get.dialog(
                                            BoostDialog(item: widget.myProducts ?? ProductsItem(),dashboardController: widget.dashboardController,),
                                            barrierDismissible: false);
                                      }
                                  },
                                ),
                                CustomButton(
                                  color: AppColor.buttonColor.withValues(
                                    alpha: .10,
                                  ),
                                  borderColor: AppColor.buttonColor,
                                  textStyle: interMedium.copyWith(
                                    color: AppColor.buttonColor,
                                    fontSize: 16.sp,
                                  ),
                                  height: 38.h,
                                  width: 168.w,
                                  marginLeft: 0,
                                  marginRight: 0,
                                  text: AppText.unPublish,
                                  onPressed: () {
                                    Get.find<DashboardController>()
                                        .unpublishProperty(
                                          carId: widget.myProducts?.id!.toInt(),
                                        );
                                  },
                                ),
                              ],
                            ),
                          if (widget.myProducts?.status == 'Active')
                            SizedBox(height: 16.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomButton(
                                color: AppColor.leafGreen4.withValues(
                                  alpha: .10,
                                ),
                                borderColor: AppColor.leafGreen4,
                                textStyle: interMedium.copyWith(
                                  color: AppColor.leafGreen4,
                                  fontSize: 16.sp,
                                ),
                                height: 38.h,
                                width: 168.w,
                                marginLeft: 0,
                                marginRight: 0,
                                text: AppText.edit,
                                onPressed: () {
                                  FadeScreenTransition(
                                      routeName: Routes.addProductRoute, arguments: {'routeType': 'editRoute', 'pId': widget.myProducts!.id ?? 0}).navigate();
                                },
                              ),
                              CustomButton(
                                color: AppColor.amberOrange9,
                                textStyle: interMedium.copyWith(
                                  fontSize: 16.sp,
                                  color: Colors.white,
                                ),
                                height: 38.h,
                                width: 168.w,
                                marginLeft: 0,
                                marginRight: 0,
                                text: AppText.delete,
                                onPressed: () {
                                  Get.find<DashboardController>().deleteMyProperty(propertyId: widget.myProducts!.id!.toInt());
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 23.h),
                        ],
                      ),
                    ],
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
