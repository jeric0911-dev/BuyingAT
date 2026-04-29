import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../controller/add_products_controller.dart';
import '../../utils/app_color.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_image.dart';

class SizeTileWidget extends StatelessWidget {
  final int index;
  final SizeModel item;
  final bool isSpecification;
  final bool isAdditional;
  final AddProductsController addProductsController;

  const SizeTileWidget({
    super.key,
    required this.index,
    required this.item,
    this.isSpecification = false,
    this.isAdditional = false,
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




       ( isSpecification || isAdditional) ?Row(
          children: [
            Text(item.specificationKey.toString(), style: sansMedium.copyWith(fontSize: 16.sp, height: 1.4.h,color: AppColor.textColor,letterSpacing: -.1),),
            Text(" -(${item.specificationValue.toString()})",style: sansMedium.copyWith(fontSize: 16.sp, height: 1.4.h,color: AppColor.coolGray4,letterSpacing: -.1),)
          ],
        ) :Container(
          padding: EdgeInsets.symmetric(vertical: 5.h,horizontal: 16.w),
          decoration: BoxDecoration(color: AppColor.babyBlue3, borderRadius: BorderRadius.circular(4.r),
            boxShadow: [
              BoxShadow(
                color: AppColor.coolGray7.withValues(alpha: .24),
                blurRadius: 2.3.r,
                offset: Offset(0, 1.15.h),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Text(
            item.sizeName.toString(),
            style: sansMedium.copyWith(
              fontSize: 16.sp,
              height: 1.4.h,
              letterSpacing: -.1,
              color: AppColor.buttonColor,
            ),
          ),
        ) ,

        Spacer(),

        // Delete Button
        InkWell(
          onTap: (){
            isSpecification? addProductsController.specificationItems.removeAt(index) : isAdditional ? addProductsController.additionalInfoItems.removeAt(index) : addProductsController.sizeItems.removeAt(index);
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