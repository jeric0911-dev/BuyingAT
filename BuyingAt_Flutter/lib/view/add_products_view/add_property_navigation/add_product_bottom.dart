import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../controller/add_products_controller.dart';
import '../../../controller/navigation_controller.dart';
import '../../../utils/app_color.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_text.dart';
import '../../../widget/custom_button.dart';
import '../../../widget/custom_snackbar_widget.dart';

class AddProductBottom extends StatefulWidget {
  const AddProductBottom({super.key});

  @override
  State<AddProductBottom> createState() => _AddProductBottomState();
}

class _AddProductBottomState extends State<AddProductBottom> {
  late AddProductsController addProductsController;
  late NavigationController navigationController;


  @override
  void initState() {
    super.initState();
    addProductsController = Get.find<AddProductsController>();
    navigationController = Get.find<NavigationController>();

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColor.backGround),
      padding: EdgeInsets.only(
        top: 16.h,
        bottom: 28.h,
        left: 16.w,
        right: 16.w,
      ),
      child: Obx(() {
        return Row(
          mainAxisAlignment:
              addProductsController.activeIndex.value != 0
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.end,
          children: [
            CustomButton(
              width: 122.w,
              height: 48.h,
              text: AppText.cancel,
              marginLeft: 0,
              marginRight: addProductsController.activeIndex.value == 0 ? 16.w : 0,
              color: AppColor.white,
              borderColor: AppColor.buttonColor,
              textStyle: sansSemiBold.copyWith(
                color: AppColor.buttonColor,
                fontSize: 18.sp,
                height: 1.4.h,
                letterSpacing: -.1,
              ),
              onPressed: () {
                print("object");
                Get.back();
                // if (navigationController.isProfileRoute.value == 'profileRoute') {
                //   navigationController.setActiveIndex(3);
                //   FocusManager.instance.primaryFocus?.unfocus();
                //   addProductsController.cancelBtn();
                // } else {
                //   navigationController.setActiveIndex(0);
                //   addProductsController.cancelBtn();
                // }
              },
            ),

            if (addProductsController.activeIndex.value != 0)
              CustomButton(
                width: 122.w,
                height: 48.h,
                text: AppText.previous,
                color: AppColor.buttonColor.withValues(alpha: .15),
                borderColor: AppColor.buttonColor.withValues(alpha: .20),
                marginLeft: 0,
                marginRight: 0,
                textStyle: sansSemiBold.copyWith(
                  color: AppColor.buttonColor,
                  fontSize: 18.sp,
                  height: 1.4.h,
                  letterSpacing: -.1,
                ),
                onPressed: () {
                  if (addProductsController.activeIndex.value > 0) {
                    addProductsController.setActiveIndex(
                      addProductsController.activeIndex.value -= 1,
                    );
                  }
                },
              ),
            Obx(() {
              return CustomButton(
                width: 122.w,
                height: 48.h,
                isLoading: addProductsController.isStoreProductLoading.value,
                text:
                    addProductsController.activeIndex.value == 2
                        ? AppText.submit
                        : AppText.next,
                color: AppColor.buttonColor,
                borderColor: AppColor.buttonColor,
                textStyle: sansBold.copyWith(
                  color: AppColor.white,
                  fontSize: 18.sp,
                ),
                marginLeft: 0,
                marginRight: 0,
                onPressed: () {
                  if (addProductsController.isFormValidPageOne.value) {
                    if (addProductsController.activeIndex.value < 2) {
                      addProductsController.setActiveIndex(
                        addProductsController.activeIndex.value += 1,
                      );
                    } else {
                      addProductsController.storeProduct();
                    }
                  } else {
                    showCustomSnackBar("Error, Please fill in all fields.");
                  }
                },
              );
            }),
          ],
        );
      }),
    );
  }
}
