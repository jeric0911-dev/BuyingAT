import 'package:classified/controller/add_products_controller.dart';
import 'package:classified/utils/app_fonts.dart';
import 'package:classified/utils/app_image.dart';
import 'package:classified/widget/custom_snackbar_widget.dart';
import 'package:classified/widget/custom_text_field_widget.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../utils/app_color.dart';
import '../../utils/app_text.dart';
import '../../widget/add_products_widgets/color_item_title.dart';
import '../../widget/add_products_widgets/size_tile_widget.dart';
import '../../widget/custom_button.dart';

class AddProductTwo extends StatefulWidget {
  const AddProductTwo({super.key});

  @override
  State<AddProductTwo> createState() => _AddProductTwoState();
}

class _AddProductTwoState extends State<AddProductTwo> {
  late AddProductsController addProductsController;

  @override
  void initState() {
    super.initState();
    addProductsController = Get.find<AddProductsController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backGround,
      resizeToAvoidBottomInset: false,
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          SizedBox(height: 14.h,),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: AppText.addMoreProductInfo,
                  style: interSemiBold.copyWith(
                    fontSize: 18.sp,
                    color: AppColor.dark2,
                  ),
                ),
                TextSpan(
                  text: " ${AppText.optional}", // Add space if needed
                  style: interMedium.copyWith(
                    fontSize: 16.sp,
                    color: AppColor.coolGray4,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h,),
          SizedBox(
            height: 36.h,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: addProductsController.texts.length,
              itemBuilder: (context, index) {
                return Obx(() {
                  bool isSelected = addProductsController.selectedIndex.value == index;
                  return InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      if (isSelected) {
                        addProductsController.selectedIndex.value = -1;
                      } else {
                        addProductsController.selectedIndex.value = index;
                      }
                    },

                    child: Container(
                      height: 36.h,
                      margin: EdgeInsets.only(
                        right: 12.w,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColor.buttonColor
                            : AppColor.buttonColor.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(
                          color: !isSelected ? AppColor.buttonColor.withValues(
                              alpha: .20) : Colors.transparent,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Center(
                          child: Text(
                            addProductsController.texts[index],
                            style: sansMedium.copyWith(
                                fontSize: 16.sp,
                                color: isSelected ? Colors.white : AppColor
                                    .buttonColor,
                                height: 1.4.h,
                                letterSpacing: -.1
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
          ),

          /// Stock, Price, and Discounted Price
          Obx(() => Visibility(
            visible: addProductsController.selectedIndex.value == -1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 32.h,),
                DottedLine(
                  dashColor: AppColor.coolGray19,
                  lineThickness: 1.h,
                ),
                SizedBox(height: 24.h,),
                CustomTextFieldWidget(
                  controller: addProductsController.mainStock,
                  focusNode: addProductsController.fMainStock,
                  nextFocus: addProductsController.fOriginalPrice,
                  titleText: AppText.stock,
                  showTitle: true,
                  hintText: '00',
                  inputType: TextInputType.number,
                ),
                SizedBox(height: 18.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextFieldWidget(
                        controller: addProductsController.originalPrice,
                        focusNode: addProductsController.fOriginalPrice,
                        nextFocus: addProductsController.fDiscountPrice,
                        titleText: AppText.originalPrice,
                        showTitle: true,
                        hintText: '00',
                        inputType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 16.h),
                    Expanded(
                      child: CustomTextFieldWidget(
                        controller: addProductsController.discountPrice,
                        focusNode: addProductsController.fDiscountPrice,
                        titleText: AppText.discountedPrice,
                        showTitle: true,
                        hintText: '00',
                        inputType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),


          /// Colors
          Obx(() => Visibility(
            visible: addProductsController.selectedIndex.value == 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h,),
                Obx(() {
                  final colorItems = addProductsController.colorItems;

                  if (colorItems.isEmpty) {
                    return SizedBox.shrink();
                  }

                  return ListView.builder(
                    itemCount: colorItems.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = colorItems[index];
                      return ColorItemTile(
                        index: index,
                        imageUrls: item.pickedImages.map((file) => file.path).toList(),
                        item: item,
                        addProductsController: addProductsController,
                      );
                    },
                  );
                }),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppText.selectColor, style: sansMedium.copyWith(
                            color: AppColor.coolGray4,
                            fontSize: 14.sp,
                            height: 1.6.h,
                            letterSpacing: -.2),),
                        SizedBox(height: 3.h,),
                        InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            _openColorPicker();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                                color: AppColor.transparent,
                                boxShadow: [
                                  BoxShadow(
                                      color: AppColor.coolGray7.withValues(
                                          alpha: .24),
                                      blurRadius: 2.3.r,
                                      offset: Offset(0, 1.15.h),
                                      spreadRadius: 0
                                  ),
                                ],
                                border: Border.all(
                                    color: AppColor.coolGray6, width: 1.15.sp),
                                borderRadius: BorderRadius.circular(4.r)
                            ),
                            child: Obx(() {
                              return Container(
                                width: 98.w,
                                height: 30.h,
                                decoration: BoxDecoration(
                                  color: addProductsController.selectedColor.value,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 16.w,),
                    Expanded(
                        child: CustomTextFieldWidget(
                          controller: addProductsController.colorName,
                          focusNode: addProductsController.fColorName,
                          titleText: AppText.colorName,
                          titleTextStyle: sansMedium.copyWith(
                              color: AppColor.coolGray4,
                              fontSize: 14.sp,
                              height: 1.6.h,
                              letterSpacing: -.2),
                          showTitle: true,
                          hintText: 'Enter color name',
                          inputType: TextInputType.text,
                        ))
                  ],
                ),
                SizedBox(height: 10.h,),
                Text(AppText.selectColor, style: sansMedium.copyWith(
                    color: AppColor.coolGray4,
                    fontSize: 14.sp,
                    height: 1.6.h,
                    letterSpacing: -.2),),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: 52.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: AppColor.white,
                            border: Border.all(
                                color: AppColor.coolGray6, width: 1.15.sp),
                            borderRadius: BorderRadius.circular(4.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.coolGray7.withValues(alpha: .24),
                                blurRadius: 2.3.r,
                                offset: Offset(0, 1.15.h),
                                spreadRadius: 0,
                              ),
                            ]
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                addProductsController.pickImage();
                              },
                              child: Container(
                                width: 120.w,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                    color: AppColor.coolGray24,
                                ),
                                child: Center(child: Text(AppText.chooseFiles1,
                                  style: sansMedium.copyWith(fontSize: 16.sp,
                                      color: AppColor.textColor,
                                      height: 1.4.h,
                                      letterSpacing: -.1),)),
                              ),
                            ),
                            SizedBox(width: 16.w,),
                            Obx(() {
                              int count = addProductsController.pickedImages.length;
                              return Text(
                                count == 0
                                    ? 'no photo selected'
                                    : '$count photo${count > 1
                                    ? 's'
                                    : ''} selected',
                                style: sansMedium.copyWith(
                                  fontSize: 16.sp,
                                  color: AppColor.textColor,
                                  height: 1.4.h,
                                  letterSpacing: -0.1,
                                ),
                              );
                            }),
                          ],
                        ),),
                    ),
                    SizedBox(width: 16.w,),
                    InkWell(
                        onTap: (){
                          bool isAddEnabled = addProductsController.colorName.text.trim().isNotEmpty;
                          isAddEnabled ? addProductsController.addColorItem() : showCustomSnackBar('Please enter color name');
                        },
                        child: SvgPicture.asset(AppImage.icAddOne, height: 52.h,)),
                  ],
                ),

              ],
            ),
          )),




          /// Sizes

          Obx(() => Visibility(
            visible: addProductsController.selectedIndex.value == 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                addProductsController.sizeItems.isNotEmpty? SizedBox(height: 24.h,) : SizedBox.shrink(),

                Obx(() {
                  final sizeItems = addProductsController.sizeItems;

                  if (sizeItems.isEmpty) {
                    return SizedBox.shrink();
                  }

                  return ListView.builder(
                    itemCount: sizeItems.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = sizeItems[index];
                      return Column(
                        children: [
                          SizeTileWidget(index:index ,item: item, addProductsController: addProductsController,),
                          index == sizeItems.length-1 ? SizedBox.shrink() :Padding(
                            padding:  EdgeInsets.symmetric(vertical: 12.h),
                            child: DottedLine(lineThickness: 1.h, dashColor: AppColor.coolGray25,),
                          )
                        ],
                      );
                    },
                  );
                }),
                SizedBox(height: 24.h,),

                addProductsController.sizeItems.isNotEmpty? DottedLine(
                  dashColor: AppColor.coolGray19,
                  lineThickness: 1.h,
                ) : SizedBox.shrink(),
                addProductsController.sizeItems.isNotEmpty? SizedBox(height: 12.h,) : SizedBox.shrink(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                        child: CustomTextFieldWidget(
                          titleText: AppText.addSize,
                          showTitle: true,
                          hintText:AppText.addSizeHint,
                          inputType: TextInputType.text,
                          controller: addProductsController.size,
                          focusNode: addProductsController.fSize,
                        )
                    ),
                    SizedBox(width: 16.w,),
                    InkWell(
                        onTap: (){
                          bool isAddEnables = addProductsController.size.text.trim().isNotEmpty;
                          isAddEnables ? addProductsController.addSizeItem(): showCustomSnackBar('Please enter size name');
                        },
                        child: SvgPicture.asset(AppImage.icAddOne, height: 49.h,)),
                  ],
                ),

              ],
            ),
          )),



          /// Specification

          Obx(() => Visibility(
            visible: addProductsController.selectedIndex.value == 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                addProductsController.specificationItems.isNotEmpty? SizedBox(height: 28.h,) : SizedBox.shrink(),
                Obx(() {
                  final specificationItems = addProductsController.specificationItems;

                  if (specificationItems.isEmpty) {
                    return SizedBox.shrink();
                  }

                  return ListView.builder(
                    itemCount: specificationItems.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = specificationItems[index];
                      return Column(
                        children: [
                          SizeTileWidget(index:index ,item: item, addProductsController: addProductsController,isSpecification: true,),
                          index == specificationItems.length-1 ? SizedBox.shrink() :Padding(
                            padding:  EdgeInsets.symmetric(vertical: 12.h),
                            child: DottedLine(lineThickness: 1.h, dashColor: AppColor.coolGray25,),
                          )
                        ],
                      );
                    },
                  );
                }),
                SizedBox(height: 24.h,),

                addProductsController.specificationItems.isNotEmpty? DottedLine(
                  dashColor: AppColor.coolGray19,
                  lineThickness: 1.h,
                ) : SizedBox.shrink(),
                addProductsController.specificationItems.isNotEmpty? SizedBox(height: 12.h,) : SizedBox.shrink(),

                CustomTextFieldWidget(
                  titleText: AppText.specification,
                  showTitle: true,
                  hintText:AppText.specificationHint1,
                  inputType: TextInputType.text,
                  controller: addProductsController.specificationOne,
                  focusNode: addProductsController.fSpecificationOne,
                  nextFocus: addProductsController.fSpecificationTwo,
                ),
                SizedBox(height: 10.h,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                        child: CustomTextFieldWidget(
                          hintText:AppText.specificationHint2,
                          inputType: TextInputType.text,
                          controller: addProductsController.specificationTwo,
                          focusNode: addProductsController.fSpecificationTwo,
                        )
                    ),
                    SizedBox(width: 16.w,),
                    InkWell(
                        onTap: (){
                          addProductsController.addSpecificationItem();
                        },
                        child: SvgPicture.asset(AppImage.icAddOne, height: 49.h,)),
                  ],
                ),

              ],
            ),
          )),



          /// Additional Info

          Obx(() => Visibility(
            visible: addProductsController.selectedIndex.value == 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                addProductsController.additionalInfoItems.isNotEmpty? SizedBox(height: 24.h,) : SizedBox.shrink(),
                Obx(() {
                  final item = addProductsController.additionalInfoItems;

                  if (item.isEmpty) {
                    return SizedBox.shrink();
                  }

                  return ListView.builder(
                    itemCount: item.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final items = item[index];
                      return Column(
                        children: [
                          SizeTileWidget(index:index ,item: items, addProductsController: addProductsController,isAdditional: true,),
                          index == item.length-1 ? SizedBox.shrink() :Padding(
                            padding:  EdgeInsets.symmetric(vertical: 12.h),
                            child: DottedLine(lineThickness: 1.h, dashColor: AppColor.coolGray25,),
                          )
                        ],
                      );
                    },
                  );
                }),
                SizedBox(height: 24.h,),

                addProductsController.additionalInfoItems.isNotEmpty? DottedLine(
                  dashColor: AppColor.coolGray19,
                  lineThickness: 1.h,
                ) : SizedBox.shrink(),
                addProductsController.additionalInfoItems.isNotEmpty? SizedBox(height: 12.h,) : SizedBox.shrink(),

                CustomTextFieldWidget(
                  titleText: AppText.additionalInfo,
                  showTitle: true,
                  hintText:AppText.specificationHint1,
                  inputType: TextInputType.text,
                  controller: addProductsController.additionalInfoOne,
                  focusNode: addProductsController.fAdditionalInfoOne,
                  nextFocus: addProductsController.fSpecificationTwo,
                ),
                SizedBox(height: 10.h,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                        child: CustomTextFieldWidget(
                          hintText:AppText.specificationHint2,
                          inputType: TextInputType.text,
                          controller: addProductsController.additionalInfoTwo,
                          focusNode: addProductsController.fAdditionalInfoTwo,
                        )
                    ),
                    SizedBox(width: 16.w,),
                    InkWell(
                        onTap: (){
                          addProductsController.addAdditionalInfoItem();
                        },
                        child: SvgPicture.asset(AppImage.icAddOne, height: 49.h,)),
                  ],
                ),

              ],
            ),
          )),



          /// Variant

          Obx(() => Visibility(
            visible: addProductsController.selectedIndex.value == 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                addProductsController.variantItems.isNotEmpty? SizedBox(height: 24.h,) : SizedBox.shrink(),
                Obx(() {
                  final item = addProductsController.variantItems;

                  if (item.isEmpty) {
                    return SizedBox.shrink();
                  }

                  return ListView.builder(
                    itemCount: item.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final items = item[index];
                      return Column(
                        children: [
                          VariantWidget(index:index ,item: items, addProductsController: addProductsController),
                          index == item.length-1 ? SizedBox.shrink() :Padding(
                            padding:  EdgeInsets.symmetric(vertical: 12.h),
                            child: DottedLine(lineThickness: 1.h, dashColor: AppColor.coolGray25,),
                          )
                        ],
                      );
                    },
                  );
                }),
                SizedBox(height: 24.h,),

                addProductsController.variantItems.isNotEmpty? DottedLine(
                  dashColor: AppColor.coolGray19,
                  lineThickness: 1.h,
                ) : SizedBox.shrink(),
                addProductsController.variantItems.isNotEmpty? SizedBox(height: 12.h,) : SizedBox.shrink(),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextFieldWidget(
                        titleText: AppText.originalPrice,
                        showTitle: true,
                        hintText: AppText.zeroZero,
                        inputType: TextInputType.number,
                        controller: addProductsController.variantOriginalPrice,
                        focusNode: addProductsController.fVariantOriginalPrice,
                        nextFocus: addProductsController.fVariantDiscountPrice,
                      ),
                    ),
                    SizedBox(width: 16.w,),
                    Expanded(
                      child: CustomTextFieldWidget(
                        titleText: AppText.discountedPrice,
                        showTitle: true,
                        hintText: AppText.zeroZero,
                        inputType: TextInputType.number,
                        controller: addProductsController.variantDiscountPrice,
                        focusNode: addProductsController.fVariantDiscountPrice,
                        nextFocus: addProductsController.fVariantInfo,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                        child: CustomTextFieldWidget(
                          titleText: AppText.variationInformation,
                          hintText:AppText.variationInfoHint,
                          showTitle: true,
                          inputType: TextInputType.text,
                          controller: addProductsController.variantInfo,
                          focusNode: addProductsController.fVariantInfo,
                        )
                    ),
                    SizedBox(width: 16.w,),
                    InkWell(
                        onTap: (){
                          addProductsController.addVariantItem();
                        },
                        child: SvgPicture.asset(AppImage.icAddOne, height: 49.h,)),
                  ],
                ),
                SizedBox(height: 300.h,),
              ],
            ),
          )),



        ],
      ),
    );
  }


  void _openColorPicker() {
    showDialog(
      context: context,
      builder: (_) {
        Color tempColor = addProductsController.selectedColor.value;
        return AlertDialog(
          title: const Text('Pick a color'),
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (Color color) {
                tempColor = color;
              },
              // showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    borderColor: AppColor.buttonColor,
                    color: AppColor.white,
                    textColor: AppColor.buttonColor,
                    marginLeft: 0,
                    marginRight: 0,
                    text: "Cancel",
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    marginLeft: 0,
                    marginRight: 0,
                    text: "Select",
                    onPressed: () {
                      addProductsController.selectedColor.value = tempColor;
                      Get.back();
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}




class VariantWidget extends StatelessWidget {
  final int index;
  final VariantModel item;
  final AddProductsController addProductsController;

  const VariantWidget({
    super.key,
    required this.index,
    required this.item,
    required this.addProductsController,
  });

  @override
  Widget build(BuildContext context) {


    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Index
        Text(
          "${index + 1}.",
          style: sansMedium.copyWith(
              fontSize: 16.sp,
              height: 1.4.h,
              color: AppColor.textColor
          ),
        ),
        SizedBox(width: 16.w),
        Text(item.variantInfo.toString(),style: sansMedium.copyWith(fontSize: 16.sp,color: AppColor.textColor,height: 1.4.h,letterSpacing: -.1),),
        Spacer(),
        Row(children: [
          Text(item.originalPrice.toString(),style: sansReg.copyWith(fontSize: 14.sp,color: AppColor.coolGray4,height: 1.4.h,letterSpacing: -.1),),
          SizedBox(width: 35.w,),
          Text(item.discountedPrice.toString(),style: sansReg.copyWith(fontSize: 14.sp,color: AppColor.coolGray4,height: 1.4.h,letterSpacing: -.1),),
        ],),
        SizedBox(width: 24.w,),
        // Delete Button
        InkWell(
          onTap: (){
            addProductsController.variantItems.removeAt(index);
            addProductsController.update();
          },
          child: Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(color: AppColor.coolGray6),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.coolGray7.withValues(alpha: .24),
                    blurRadius: 2.3.r,
                    offset: Offset(0, 1.15.h),
                    spreadRadius: 0,
                  ),
                ]
            ),
            child: Center(
                child: SvgPicture.asset(AppImage.icDeleteOne, height: 20.h,)),
          ),
        ),
      ],
    );
  }
}
