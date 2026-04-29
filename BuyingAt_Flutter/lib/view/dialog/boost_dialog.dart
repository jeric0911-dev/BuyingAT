import 'package:classified/model/product_model.dart';
import 'package:classified/widget/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controller/dashboard_controller.dart';
import '../../utils/_constant.dart';
import '../../utils/app_color.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_image.dart';
import '../../utils/app_text.dart';
import '../../utils/image_loader.dart';
import '../../widget/custom_button.dart';
import '../../widget/custom_text_field_widget.dart';

class BoostDialog extends StatelessWidget {
  final ProductsItem item;
  final DashboardController dashboardController;

  BoostDialog(
      {super.key, required this.item, required this.dashboardController});

  final durationCtrl = TextEditingController();
  final FocusNode fDurationCtrl = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColor.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 32.h,),
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(AppImage.icFeature,
                        colorFilter: ColorFilter.mode(
                            AppColor.buttonColor, BlendMode.srcIn),),
                      SizedBox(width: 6.w,),
                      Text(
                        AppText.boost,
                        textAlign: TextAlign.center,
                        style: sansSemiBold.copyWith(
                          fontSize: 28.sp,
                          color: AppColor.primaryColor,
                          letterSpacing: .25,
                          height: 1.42.h,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: -10.w,
                    top: 0,
                    child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        Get.back();
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 10.h),
                        child: SvgPicture.asset(
                          AppImage.icCrossDialog,
                          height: 14,
                          colorFilter: ColorFilter.mode(AppColor.primaryColor,
                              BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Divider(height: 1.h, color: AppColor.coolGray19,),
              SizedBox(height: 20.h,),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: ImageLoader(
                  url:
                  "${Constant.imageBaseUrl}${item.getGalleryImages?.first.img ??
                      ''}",
                  boxFit: BoxFit.cover,
                  width: Get.width,
                  height: 150.h,
                ),
              ),
              SizedBox(height: 8.h,),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  item.productTitle.toString(),
                  style: interSemiBold.copyWith(
                      fontSize: 18.sp,
                      color: AppColor.dark1,
                      height: 1.5.h
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 12.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  item.discountedPrice ?? '',
                  style: interReg.copyWith(
                    color: AppColor.coolGray3,
                    fontSize: 16.sp,
                    height: 1.5.h,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              SizedBox(height: 20.h,),
              CustomTextFieldWidget(
                hintText: AppText.duration,
                titleText: '7 days',
                maxLines: 1,
                controller: durationCtrl,
                focusNode: fDurationCtrl,
                inputType: TextInputType.number,
                showTitle: true,
              ),

              SizedBox(height: 37.h),
              Obx(() {
                return CustomButton(
                  text: AppText.start,
                  marginRight: 0,
                  marginLeft: 0,
                  isLoading: dashboardController.isBoostLoading.value,
                  height: 48.h,
                  onPressed: () {
                    durationCtrl.text.isNotEmpty ?
                    dashboardController.featureProperty(
                        pId: item.id, duration: durationCtrl.text) :
                    showCustomSnackBar('Please Select Duration');
                  },
                );
              }),
              SizedBox(height: 32.h,),
            ],
          ),
        ),
      ),
    );
  }
}
