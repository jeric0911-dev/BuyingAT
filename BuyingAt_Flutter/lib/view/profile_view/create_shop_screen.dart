import 'package:classified/controller/create_shop_controller.dart';
import 'package:classified/utils/app_color.dart';
import 'package:classified/utils/app_fonts.dart';
import 'package:classified/utils/app_image.dart';
import 'package:classified/utils/app_text.dart';
import 'package:classified/utils/image_loader.dart';
import 'package:classified/widget/custom_app_bar.dart';
import 'package:classified/widget/custom_button.dart';
import 'package:classified/widget/custom_text_field_widget.dart';
import 'package:classified/widget/custom_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../utils/_constant.dart';

class CreateShopScreen extends StatefulWidget {
  const CreateShopScreen({super.key});

  @override
  State<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  late CreateShopController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CreateShopController>();
    controller.fetchShopData();

    ever(controller.shopDataList, (shopData) {
      controller.shopName.text = shopData.first.name ?? '';
      controller.description.text = shopData.first.description ?? '';
      controller.shopBanner.value = shopData.first.banner ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Scaffold(
          backgroundColor: AppColor.white,
          appBar: CustomAppBar(title: AppText.createShop,),
          body: ListView(
            padding: EdgeInsets.symmetric(horizontal: 27.w),
            children: [
              CustomTextFieldWidget(
                controller: controller.shopName,
                focusNode: controller.fShopName,
                nextFocus: controller.fDescription,
                titleText: AppText.shopName,
                hintText: AppText.listingTitle,
                showTitle: true,
              ),

              SizedBox(height: 18.h,),
              CustomTitleBar(title: AppText.bannerImage),
              SizedBox(height: 3.h,),
              Obx(() =>
                  InkWell(
                    onTap: () async {
                      await controller.pickBannerImage();
                    },
                    child: Container(
                      height: 143.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(
                            color: AppColor.coolGray6, width: 1.15.sp),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.coolGray7.withValues(alpha: 0.24),
                            spreadRadius: 1.5,
                            blurRadius: 2.3,
                            offset: Offset(0, 1.15),
                          ),
                        ],
                      ),
                      child: controller.bannerImage.value != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: Image.file(
                          controller.bannerImage.value!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 143.h,
                        ),
                      )
                          : controller.shopBanner.isNotEmpty ? ImageLoader(
                        radius: 4.r,
                        url: "${Constant.imageBaseUrl}${controller
                            .shopBanner}",) : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(AppImage.icGallery),
                          SizedBox(height: 12.h,),
                          Text(AppText.selectBannerImage, style: sansReg
                              .copyWith(
                              height: 1.42,
                              fontSize: 14.sp,
                              color: AppColor.coolGray9),)
                        ],
                      ),
                    ),
                  )),

              SizedBox(height: 18.h,),
              CustomTextFieldWidget(
                controller: controller.description,
                focusNode: controller.fDescription,
                titleText: AppText.description,
                hintText: AppText.addDescription,
                showTitle: true,
                maxLines: 10,
              ),

              SizedBox(height: 28.h,),
              Obx(() {
                return CustomButton(
                  marginLeft: 0,
                  marginRight: 0,
                  isLoading: controller.isCreateShopLoading.value,
                  text: controller.isShopAvailable.value? AppText.updateShop : AppText.createShop,
                  onPressed: () {
                    controller.createShop();
                  },
                );
              }),
              SizedBox(height: 28.h,),


            ],
          ),
        ),
        Obx(() {
          return controller.isShopDataLoading.value ?CircularProgressIndicator(
            strokeWidth: 2, color: AppColor.buttonColor,) : SizedBox.shrink();
        })
      ],
    );
  }
}
