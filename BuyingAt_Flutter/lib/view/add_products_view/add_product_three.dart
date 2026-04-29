import 'package:classified/utils/app_fonts.dart';
import 'package:classified/utils/image_loader.dart';
import 'package:classified/widget/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../controller/add_products_controller.dart';
import '../../utils/app_color.dart';
import '../../utils/app_image.dart';
import '../../utils/app_text.dart';
import '../../widget/custom_title_bar.dart';

class AddProductThree extends StatefulWidget {
  const AddProductThree({super.key});

  @override
  State<AddProductThree> createState() => _AddProductThreeState();
}

class _AddProductThreeState extends State<AddProductThree> {
  late AddProductsController addProductsController;

  @override
  initState() {
    super.initState();
    addProductsController = Get.find<AddProductsController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 14.h),
              CustomTitleBar(
                title: AppText.uploadPhotos,
                titleStyle: interSemiBold.copyWith(
                  fontSize: 18.sp,
                  color: AppColor.dark2,
                ),
              ),
              SizedBox(height: 18.h),

              Obx(
                () => Align(
                  alignment: Alignment.topLeft,
                  child: Wrap(
                    spacing: 16.w,
                    runSpacing: 16.h,
                    children: [
                      for (
                        int i = 0;
                        i < addProductsController.pickedProductImages.length;
                        i++
                      )
                        Stack(
                          alignment: Alignment.topLeft,
                          children: [
                  Container(
                  width: 122.w,
                  height: 90.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.buttonColor),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: () {
                      final file = addProductsController.pickedProductImages[i];
                      final path = file.path;
                      if (path.startsWith('http')) {
                        return ImageLoader(
                          url: path,
                          boxFit: BoxFit.cover,
                          width: 122.w,
                          height: 90.h,
                        );
                      } else {
                        return Image.file(
                          file,
                          fit: BoxFit.cover,
                          width: 122.w,
                          height: 90.h,
                        );
                      }
                    }(),
                  ),
                ),


                  Positioned.fill(
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    addProductsController.removeProductImage(i);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: SvgPicture.asset(
                                      AppImage.icDelete,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      // Add button
                      if (addProductsController.pickedProductImages.length < 6)
                        InkWell(
                          onTap: () {
                            addProductsController.pickProductImage();
                          },
                          child: Container(
                            width: 122.w,
                            height: 90.h,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColor.coolGray26),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Center(
                              child: Container(
                                height: 34.h,
                                width: 34.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColor.buttonColor.withValues(
                                    alpha: .08,
                                  ),
                                  border: Border.all(
                                    color: AppColor.buttonColor.withValues(
                                      alpha: .20,
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: SvgPicture.asset(AppImage.icAddTwo),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 18.h),
              addProductsController.selectedIndex.value == -1
                  ? const SizedBox.shrink()
                  : Row(
                      children: [
                        Expanded(
                          child: CustomTextFieldWidget(
                            titleText: AppText.originalPrice,
                            showTitle: true,
                            hintText: AppText.zeroZero,
                            inputType: TextInputType.number,
                            controller: addProductsController.originalPrice,
                            focusNode: addProductsController.fOriginalPrice,
                            nextFocus:
                                addProductsController.fVariantDiscountPrice,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: CustomTextFieldWidget(
                            titleText: AppText.discountedPrice,
                            showTitle: true,
                            hintText: AppText.zeroZero,
                            inputType: TextInputType.number,
                            controller: addProductsController.discountPrice,
                            focusNode: addProductsController.fDiscountPrice,
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
