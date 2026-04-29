import 'package:classified/controller/fetch_product_info_controller.dart';
import 'package:classified/utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controller/add_products_controller.dart';
import '../../utils/app_color.dart';
import '../../utils/app_text.dart';
import '../../widget/custom_drop_dawn_btn.dart';
import '../../widget/custom_text_field_widget.dart';
import '../../widget/custom_title_bar.dart';

class AddProductOne extends StatefulWidget {
  const AddProductOne({super.key});

  @override
  State<AddProductOne> createState() => _AddProductOneState();
}

class _AddProductOneState extends State<AddProductOne> {
  late AddProductsController addProductsController;
  late FetchProductInfoController fetchProductInfoController;


  @override
  void initState() {
    super.initState();
    addProductsController = Get.find<AddProductsController>();
    fetchProductInfoController = Get.find<FetchProductInfoController>();
    // fetchProductInfoController.fetchCategory(isReload: true);
    //  fetchProductInfoController.fetchBrand(isReload: true);
    // getBrandsController.getCarTypes(isReload: true);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backGround,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 14.h),

              CustomTextFieldWidget(
                titleText: AppText.title,
                hintText: AppText.listingTitle1,
                controller: addProductsController.title,
                focusNode: addProductsController.fTitleNode,
                nextFocus: addProductsController.fPriceNode,
                inputType: TextInputType.text,
                showTitle: true,
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
                    addProductsController.categoryId.value = value!;
                    fetchProductInfoController.filterCategoryByCategoryId(value);
                    fetchProductInfoController.filterSubCategoryByCategory(value);
                  },
                  title: addProductsController.categoryName.value.isNotEmpty
                      ? addProductsController.categoryName.value
                      : 'Select  Category',
                  isSelected: addProductsController.categoryName.value.isNotEmpty
                ? true : false,
                  btnHeight: 48.h,
                );
              }),

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
              Obx(() {
                return CustomDropDawnBtn(
                  items: fetchProductInfoController.subCategorySelectedTypeList.value,
                  onChange: (int? value, int index) {
                    addProductsController.subCategoryId.value = value!;
                    fetchProductInfoController.filterSubCategoryByCategoryId(value);
                  },
                  title: addProductsController.subCategoryName.value.isNotEmpty
                      ? addProductsController.subCategoryName.value
                      : 'Select SubCategory',
                  isSelected: addProductsController.subCategoryName.value.isNotEmpty
                      ? true : false,
                  btnHeight: 48.h,
                );
              }),

              SizedBox(height: 18.h),
              CustomTextFieldWidget(
                titleText: AppText.description,
                hintText: 'Write Description',
                controller: addProductsController.description,
                focusNode: addProductsController.fDescriptionNode,
                inputType: TextInputType.text,
                maxLines: 7,
                showTitle: true,
              ),

              SizedBox(height: 18.h,),
              CustomTitleBar(
                title: AppText.brand,
                titleStyle: sansMedium.copyWith(
                    fontSize: 14.sp,
                    height: 1.6.h,
                    color: AppColor.coolGray4,
                    letterSpacing: -.1
                ),
              ),
              SizedBox(height: 3.h),
              Obx(() {
                return CustomDropDawnBtn(
                  items: fetchProductInfoController.selectedBrandList.value,
                  onChange: (int? value, int index) {
                     addProductsController.brandId.value = value!;
                      addProductsController.brandName.value = fetchProductInfoController.brandList[index].brandName!;

                  },
                  title: addProductsController.brandName.value.isNotEmpty
                      ? addProductsController.brandName.value
                      : 'Select Brand',
                  isSelected: addProductsController.brandName.value.isNotEmpty
                      ? true : false,
                  btnHeight: 48.h,
                );
              }),


              SizedBox(height: 350.h,),
              // AnimatedContainerWidget(
              //   height: MediaQuery.of(context).viewInsets.bottom,
              // ),

            ],
          ),
        ),
      ),
    );
  }


}
