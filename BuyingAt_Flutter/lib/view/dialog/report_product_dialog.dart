import 'package:classified/controller/product_details_controller.dart';
import 'package:classified/utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../utils/app_color.dart';
import '../../utils/app_image.dart';
import '../../utils/app_text.dart';
import '../../widget/custom_button.dart';
import '../../widget/custom_drop_dawn_btn.dart';
import '../../widget/custom_dropdown_widget.dart';
import '../../widget/custom_text_field_widget.dart';
import '../../widget/custom_title_bar.dart';

class ReportPropertyDialog extends StatefulWidget {
  final dynamic propertyId;

  const ReportPropertyDialog({super.key, required this.propertyId});

  @override
  State<ReportPropertyDialog> createState() => _ReportPropertyDialogState();
}


class _ReportPropertyDialogState extends State<ReportPropertyDialog> {
  late ProductDetailsController productDetailsController;

  @override
  void initState() {
    super.initState();
    productDetailsController = Get.find<ProductDetailsController>();
    productDetailsController.subjectSelectedList.clear();
    productDetailsController.title.value = '';
    productDetailsController.description.text = '';
  }

  @override
  Widget build(BuildContext context) {
    productDetailsController.subjectSelectedList.clear();
    for (
    int index = 0;
    index < productDetailsController.subjectTypeList.length;
    index++
    ) {
      productDetailsController.subjectSelectedList.add(
        DropdownItem<int>(
          value: index,
          child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(productDetailsController.subjectTypeList[index]),
            ),
          ),
        ),
      );
    }
    return Dialog(
      backgroundColor: AppColor.white,
      insetPadding: EdgeInsets.only(left: 16.w, right: 16.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: Text(
                    'Report Property',
                    textAlign: TextAlign.center,
                    style: sansSemiBold.copyWith(
                      fontSize: 28.sp,
                      color: AppColor.primaryColor,
                      letterSpacing: .25,
                      height: 1.42.h,
                    ),
                  ),
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
                      padding: EdgeInsets.symmetric(horizontal: 10.w,
                          vertical: 10.h),
                      child: SvgPicture.asset(
                        AppImage.icCrossDialog,
                        height: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40.h),

            CustomTitleBar(title: AppText.priority),
            SizedBox(height: 3.h),
            CustomDropDawnBtn(
              items: productDetailsController.subjectSelectedList,
              onChange: (int? value, int index) {
                productDetailsController.title.value =
                productDetailsController.subjectTypeList[index];
              },
              title: 'Select Subject',
              btnHeight: 48.h,
              isIndexValue: true,
            ),


            SizedBox(height: 24.h,),
            CustomTextFieldWidget(
              contentPadding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 20.w),
              titleText: AppText.description,
              hintText: AppText.description,
              controller: productDetailsController.description,
              focusNode: productDetailsController.fDescriptionNode,
              maxLines: 6,
              inputType: TextInputType.text,
              showTitle: true,

            ),


            SizedBox(height: 38.h),
            Obx(() {
              return CustomButton(
                text: AppText.submit,
                isLoading: productDetailsController.isReportLoading.value,
                onPressed: () {
                  productDetailsController.submitReport(
                    widget.propertyId,
                  );
                },
                marginRight: 0,
                marginLeft: 0,
                borderColor: AppColor.buttonColor,
              );
            }),


          ],
        ),
      ),
    );
  }
}
