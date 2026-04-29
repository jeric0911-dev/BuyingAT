import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/add_card_controller.dart';
import '../service/api/api_client.dart';
import '../utils/app_color.dart';
import '../utils/app_fonts.dart';
import '../utils/app_text.dart';
import '../widget/custom_app_bar.dart';
import '../widget/custom_text_field_widget.dart';
import '../widget/custom_button.dart';
import '../widget/custom_drop_dawn_btn.dart';
import '../widget/custom_dropdown_widget.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  late AddCardController addCardController;
  int? cardId;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    cardId = args?['cardId'] as int?;
    
    final apiClient = Get.find<ApiClient>();
    addCardController = Get.put(
      AddCardController(apiClient: apiClient, cardId: cardId),
      tag: cardId != null ? 'edit_card_$cardId' : 'add_card',
    );
    
    if (cardId != null) {
      addCardController.fetchCardForEdit(cardId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(
        title: cardId != null ? 'Edit Card' : AppText.addProduct,
        onTapBack: () => Get.back(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Title
            CustomTextFieldWidget(
              titleText: 'Card Title *',
              hintText: 'Enter card title',
              controller: addCardController.cardTitleController,
              focusNode: addCardController.cardTitleFocus,
              nextFocus: addCardController.descriptionFocus,
              inputType: TextInputType.text,
              showTitle: true,
            ),

            SizedBox(height: 18.h),

            // Description
            CustomTextFieldWidget(
              titleText: 'Description',
              hintText: 'Enter card description (optional)',
              controller: addCardController.descriptionController,
              focusNode: addCardController.descriptionFocus,
              nextFocus: addCardController.priceFocus,
              inputType: TextInputType.multiline,
              maxLines: 4,
              showTitle: true,
            ),

            SizedBox(height: 18.h),

            // Price, Price Type, Condition, Grade Row
            Row(
              children: [
                // Price
                Expanded(
                  child: CustomTextFieldWidget(
                    titleText: 'Price *',
                    hintText: '0.00',
                    controller: addCardController.priceController,
                    focusNode: addCardController.priceFocus,
                    inputType: TextInputType.numberWithOptions(decimal: true),
                    showTitle: true,
                  ),
                ),
                SizedBox(width: 12.w),
                // Price Type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price is *',
                        style: sansMedium.copyWith(
                          fontSize: 14.sp,
                          height: 1.6.h,
                          color: AppColor.coolGray4,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Obx(() {
                        return CustomDropDawnBtn(
                          items: [
                            DropdownItem<int>(
                              value: 0,
                              child: Padding(
                                padding: EdgeInsets.all(8.w),
                                child: Text(
                                  'FIRM',
                                  style: sansMedium.copyWith(
                                    fontSize: 14.sp,
                                    color: AppColor.textColor,
                                    height: 1.4.h,
                                  ),
                                ),
                              ),
                            ),
                            DropdownItem<int>(
                              value: 1,
                              child: Padding(
                                padding: EdgeInsets.all(8.w),
                                child: Text(
                                  'OBO',
                                  style: sansMedium.copyWith(
                                    fontSize: 14.sp,
                                    color: AppColor.textColor,
                                    height: 1.4.h,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          onChange: (int? value, int index) {
                            addCardController.priceType.value = value == 0 ? 'FIRM' : 'OBO';
                          },
                          title: addCardController.priceType.value,
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 18.h),

            Row(
              children: [
                // Condition
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Condition *',
                        style: sansMedium.copyWith(
                          fontSize: 14.sp,
                          height: 1.6.h,
                          color: AppColor.coolGray4,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Obx(() {
                        return CustomDropDawnBtn(
                          items: addCardController.conditions
                              .asMap()
                              .entries
                              .map((e) => DropdownItem<int>(
                                    value: e.key,
                                    child: Padding(
                                      padding: EdgeInsets.all(8.w),
                                      child: Text(
                                        e.value,
                                        style: sansMedium.copyWith(
                                          fontSize: 14.sp,
                                          color: AppColor.textColor,
                                          height: 1.4.h,
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                          onChange: (int? value, int index) {
                            addCardController.condition.value = addCardController.conditions[index];
                          },
                          title: addCardController.condition.value.isEmpty
                              ? 'Select Condition'
                              : addCardController.condition.value,
                        );
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                // Grade
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Graded',
                        style: sansMedium.copyWith(
                          fontSize: 14.sp,
                          height: 1.6.h,
                          color: AppColor.coolGray4,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Obx(() {
                        return CustomDropDawnBtn(
                          items: [
                            DropdownItem<int>(
                              value: 0,
                              child: Padding(
                                padding: EdgeInsets.all(8.w),
                                child: Text(
                                  'No',
                                  style: sansMedium.copyWith(
                                    fontSize: 14.sp,
                                    color: AppColor.textColor,
                                    height: 1.4.h,
                                  ),
                                ),
                              ),
                            ),
                            DropdownItem<int>(
                              value: 1,
                              child: Padding(
                                padding: EdgeInsets.all(8.w),
                                child: Text(
                                  'Yes',
                                  style: sansMedium.copyWith(
                                    fontSize: 14.sp,
                                    color: AppColor.textColor,
                                    height: 1.4.h,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          onChange: (int? value, int index) {
                            addCardController.grade.value = value == 0 ? 'No' : 'Yes';
                          },
                          title: addCardController.grade.value,
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 18.h),

            // Sport Type and Weight Row
            Row(
              children: [
                // Sport Type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Card Type *',
                        style: sansMedium.copyWith(
                          fontSize: 14.sp,
                          height: 1.6.h,
                          color: AppColor.coolGray4,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Obx(() {
                        return CustomDropDawnBtn(
                          items: addCardController.sportTypes
                              .asMap()
                              .entries
                              .map((e) => DropdownItem<int>(
                                    value: e.key,
                                    child: Padding(
                                      padding: EdgeInsets.all(8.w),
                                      child: Text(
                                        e.value,
                                        style: sansMedium.copyWith(
                                          fontSize: 14.sp,
                                          color: AppColor.textColor,
                                          height: 1.4.h,
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                          onChange: (int? value, int index) {
                            addCardController.sportType.value = addCardController.sportTypes[index];
                          },
                          title: addCardController.sportType.value.isEmpty
                              ? 'Select Card Type'
                              : addCardController.sportType.value,
                        );
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                // Weight
                Expanded(
                  child: CustomTextFieldWidget(
                    titleText: 'Weight (grams)',
                    hintText: '0.0',
                    controller: addCardController.weightController,
                    focusNode: addCardController.weightFocus,
                    inputType: TextInputType.numberWithOptions(decimal: true),
                    showTitle: true,
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Images Section
            Text(
              'Card Images (Max. 6) *',
              style: sansMedium.copyWith(
                fontSize: 14.sp,
                height: 1.6.h,
                color: AppColor.coolGray4,
              ),
            ),
            SizedBox(height: 8.h),
            Obx(() {
              final imageCount = addCardController.selectedImages.length;
              final canAddMore = imageCount < 6;
              
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColor.coolGray19, width: 2),
                  borderRadius: BorderRadius.circular(8.r),
                  color: AppColor.ghostWhite,
                ),
                child: InkWell(
                  onTap: () {
                    if (canAddMore) {
                      addCardController.pickImages();
                    } else {
                      Get.snackbar('Limit Reached', 'Maximum 6 images allowed');
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 48.w,
                          color: AppColor.buttonColor,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Click to upload images',
                          style: sansMedium.copyWith(
                            fontSize: 14.sp,
                            color: AppColor.dark1,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          canAddMore 
                              ? 'PNG, JPG, GIF up to 10MB each'
                              : 'Maximum 6 images reached',
                          style: sansReg.copyWith(
                            fontSize: 12.sp,
                            color: canAddMore ? AppColor.coolGray21 : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // Display selected images
            Obx(() {
              if (addCardController.selectedImages.isEmpty) {
                return SizedBox.shrink();
              }
              return Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.h,
                    childAspectRatio: 1,
                  ),
                  itemCount: addCardController.selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.file(
                            addCardController.selectedImages[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 4.h,
                          right: 4.w,
                          child: InkWell(
                            onTap: () => addCardController.removeImage(index),
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16.w,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            }),

            SizedBox(height: 32.h),

            // Submit Button
            Obx(() {
              final isEdit = addCardController.isEditMode.value;
              final buttonText = addCardController.isLoading.value
                  ? (isEdit ? 'Updating Card...' : 'Adding Card...')
                  : (isEdit ? 'Update Card' : 'Add Card');
              return CustomButton(
                text: buttonText,
                isLoading: addCardController.isLoading.value,
                onPressed: addCardController.isFormValid.value && !addCardController.isLoading.value
                    ? () => addCardController.submitCard()
                    : null,
                marginLeft: 0,
                marginRight: 0,
              );
            }),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

