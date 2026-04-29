import 'package:classified/utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../controller/add_products_controller.dart';
import '../../../controller/navigation_controller.dart';
import '../../../utils/app_color.dart';
import '../../../utils/app_text.dart';
import '../../../widget/custom_app_bar.dart';
import '../../../widget/custom_title_bar.dart';
import '../add_product_one.dart';
import '../add_product_three.dart';
import '../add_product_two.dart';
import 'add_product_bottom.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<AddProductScreen>
    with WidgetsBindingObserver {
  late AddProductsController addProductsController;
  late NavigationController navigationController;


  RxBool isKeyboardVisible = false.obs;
  @override
  void initState() {
    super.initState();
    addProductsController = Get.find<AddProductsController>();
    navigationController = Get.find<NavigationController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {

    });

    WidgetsBinding.instance.addObserver(this);
  }

  final List<String> titleSteps = [
    'Details',
    'Facilities',
    'Images',
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (addProductsController.activeIndex.value > 0) {
          addProductsController.setActiveIndex(
            addProductsController.activeIndex.value -= 1,
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(
          title: AppText.newListing,
          color: AppColor.backGround,
          appHeight: 110.h,
          onTapBack: () {
            if (addProductsController.activeIndex.value > 0) {
              addProductsController.setActiveIndex(
                addProductsController.activeIndex.value -= 1,
              );
            } else {
              Get.back();
            }
          },
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(0.h),
            child: Column(
              children: [
                SizedBox(height: 15.h,),
                Obx(() {
                  return Padding(
                    padding: EdgeInsets.only(left: 16.w),
                    child: CustomTitleBar(
                      title: titleSteps[addProductsController.activeIndex.value],
                      endTitle: '${addProductsController.activeIndex.value + 1}/3',
                      titleStyle: sansSemiBold.copyWith(fontSize: 18.sp, color: AppColor.dark2),
                      endTitleStyle: sansMedium.copyWith(fontSize: 18.sp, color: AppColor.dark2),
                      isSellAll: true,
                    ),
                  );
                }),
                SizedBox(height: 12.h,),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.w,right: 16.w),
                    child: Obx(() {
                      return AnimatedSmoothIndicator(
                        activeIndex: addProductsController.activeIndex.value,
                        count: 3,
                        duration: const Duration(milliseconds: 600),
                        effect: CustomizableEffect(
                          activeDotDecoration: DotDecoration(
                            color: AppColor.buttonColor,
                            width: 130.w,
                            height: 7.h,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                          spacing: 3,
                          dotDecoration: DotDecoration(
                            color: AppColor.buttonColor,
                            width: 130.w,
                            height: 7.h,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                          inActiveColorOverride: (i) {
                            return i < addProductsController.activeIndex.value
                                ? AppColor.buttonColor
                                : AppColor.coolGray23;
                          },
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(height: 10.h,),
              ],
            ),
          ),
        ),
        backgroundColor: AppColor.white,
        body: PageView(
          controller: addProductsController.pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            AddProductOne(),
            AddProductTwo(),
            AddProductThree(),
          ],
        ),
       bottomNavigationBar: AddProductBottom(),


      ),
    );
  }
}
