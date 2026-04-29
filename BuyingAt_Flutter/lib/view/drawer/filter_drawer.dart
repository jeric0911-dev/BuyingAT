import 'package:classified/widget/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/instance_manager.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import '../../../controller/filter_search_controller.dart';
import '../../../utils/app_color.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_image.dart';
import '../../../utils/app_text.dart';
import '../../controller/fetch_product_info_controller.dart';
import '../../widget/custom_button.dart';
import '../../widget/custom_drop_dawn_btn.dart';
import '../../widget/custom_title_bar.dart';

class FilterDrawer extends StatefulWidget {
  const FilterDrawer({super.key});

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  late FilterController filterController;
  late FetchProductInfoController fetchProductInfoController;

  @override
  void initState() {
    super.initState();
    filterController = Get.find<FilterController>();
    fetchProductInfoController = Get.find<FetchProductInfoController>();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColor.backGround,
      width: 1.sw,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: ListView(
          children: [
            Stack(
             // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: Text(
                    AppText.filters,
                    style: sansBold.copyWith(
                      fontSize: 24.sp,
                      color: AppColor.textColor,
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    filterController.reset();
                  },
                  child: Align(
                    alignment: Alignment.topRight,
                    child: CustomButton(
                      height: 28.h,
                      width: 72.w,
                      text: AppText.reset,
                      textStyle: interMedium.copyWith(
                        fontSize: 14.sp,
                        height: 1.4.h,
                        letterSpacing: -.1,
                        color: AppColor.white
                      ),
                      marginLeft: 0,
                      marginRight: 0,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        Get.back();
                      },
                      child: SvgPicture.asset(AppImage.icBackArrow)),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 24.h, bottom: 3.h),
              child: Text(
                "priceRange",
                style: pJakartaMedium.copyWith(
                  fontSize: 14.sp,
                  height: 1.6.h,
                  color: AppColor.coolGray4,
                  letterSpacing: -.2
                ),
              ),
            ),
            Row(
              children: [
                Flexible(
                  child: CustomTextFieldWidget(
                    hintText: AppText.min,
                    controller: filterController.minPrice,
                    focusNode: filterController.fMinPrice,
                    nextFocus: filterController.fMaxPrice,
                    inputType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16.w),
                Flexible(
                  child: CustomTextFieldWidget(
                    hintText: AppText.max,
                    controller: filterController.maxPrice,
                    focusNode: filterController.fMaxPrice,
                    inputType: TextInputType.number,
                  ),
                ),
              ],
            ),

            SizedBox(height: 18.h),
            CustomTitleBar(
              title: AppText.category,
              titleStyle: sansMedium.copyWith(
                  fontSize: 14.sp,
                  height: 1.6.h,
                  color: AppColor.coolGray4,
                  letterSpacing: -.1
              ),
            ),
            SizedBox(height: 3.h,),
            Obx(() {
              return CustomDropDawnBtn(
                items: fetchProductInfoController.categorySelectedTypeList.value,
                onChange: (int? value, int index) {
                  filterController.categoryId.value = value!;
                   fetchProductInfoController.filterCategoryByCategoryId(value,route: 'drawerScreen');
                   fetchProductInfoController.filterSubCategoryByCategory(value);
                },
                title: filterController.categoryName.value.isNotEmpty
                    ? filterController.categoryName.value
                    : 'Select Category',
                isSelected: filterController.categoryName.value.isNotEmpty
                    ? true : false,
                btnHeight: 48.h,
              );
            }),


            Obx(() {
              if(fetchProductInfoController.subCategorySelectedTypeList.isEmpty) {
                filterController.subCategoryName.value = '';
                filterController.subCategoryId.value = 0;
                fetchProductInfoController.subCategorySelectedTypeList.value = [];
                return const SizedBox();
              }
              return Column(
                children: [
                  SizedBox(height: 18.h,),
                  CustomTitleBar(
                    title: AppText.subcategory,
                    titleStyle: sansMedium.copyWith(
                        fontSize: 14.sp,
                        height: 1.6.h,
                        color: AppColor.coolGray4,
                        letterSpacing: -.1
                    ),
                  ),
                  SizedBox(height: 3.h),
                  CustomDropDawnBtn(
                    items: fetchProductInfoController.subCategorySelectedTypeList.value,
                    onChange: (int? value, int index) {
                      filterController.subCategoryId.value = value!;
                      fetchProductInfoController.filterSubCategoryByCategoryId(value,route: 'drawerScreen');
                    },
                    title: filterController.subCategoryName.value.isNotEmpty
                        ? filterController.subCategoryName.value
                        : 'Select SubCategory',
                    isSelected: filterController.subCategoryName.value.isNotEmpty ? true : false,
                    btnHeight: 48.h,
                  ),
                ],
              );
            }),

            // SizedBox(height: 18.h,),
            // CustomTitleBar(
            //   title: AppText.sortBy,
            //   titleStyle: sansMedium.copyWith(
            //       fontSize: 14.sp,
            //       height: 1.6.h,
            //       color: AppColor.coolGray4,
            //       letterSpacing: -.1
            //   ),
            // ),
            // SizedBox(height: 3.h),
            // Obx(() {
            //   return CustomDropDawnBtn(
            //     items: filterController.selectedSortByList,
            //     onChange: (int? value, int index) {
            //       filterController.sortBy.value = filterController.sortOptions[index];
            //     },
            //     title: filterController.sortBy.value.isNotEmpty
            //         ? filterController.sortBy.value
            //         : 'Sort By',
            //     isSelected: filterController.sortBy.value.isNotEmpty ? true : false,
            //     btnHeight: 48.h,
            //    // isIndexValue: true,
            //   );
            // }),


            SizedBox(height: 40.h),
            CustomButton(
              text: AppText.applyFilter,
              marginRight: 0,
              marginLeft: 0,
              onPressed: () {
                filterController.filter(isReload: true);
                filterController.isFilter.value = true;
                Get.back();
              },
            )
          ],
        ),
      ),
    );
  }
}
