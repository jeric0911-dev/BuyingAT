import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../controller/add_products_controller.dart';
import '../../utils/app_color.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_image.dart';
import '../../utils/image_loader.dart';

class ColorItemTile extends StatelessWidget {
  final int index;
  final List<String> imageUrls;
  final ColorItemModel item;
  final AddProductsController addProductsController;

  const ColorItemTile({
    super.key,
    required this.index,
    required this.imageUrls, required this.item,
    required this.addProductsController,
  });

  @override
  Widget build(BuildContext context) {
    final int extraCount = imageUrls.length > 3 ? imageUrls.length - 2 : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
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

          // Color Box
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: item.selectedColor,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(width: 12.w),

          // Color Name
          Expanded(
            child: Text(
              item.colorName,
              style: sansMedium.copyWith(
                fontSize: 16.sp,
                height: 1.4.h,
                letterSpacing: -.1,
                color: AppColor.textColor,
              ),
            ),
          ),


         /* SizedBox(
            width: imageUrls.length >= 3 ? 70.w : imageUrls.length == 2
                ? 50.w
                : 30.w,
            height: 32.h,
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                for (int i = 0; i < min(2, imageUrls.length); i++)
                  Positioned(
                    left: i * 20.w,
                    child: CircleAvatar(
                      radius: 16.sp,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 14.sp,
                        backgroundImage: FileImage(File(imageUrls[i])),
                      ),
                    ),
                  ),
                if (extraCount > 0)
                  Positioned(
                    left: 2 * 20.w,
                    child: CircleAvatar(
                      radius: 15.sp,
                      backgroundColor: Colors.white,
                      child: Text(
                        '+$extraCount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                if (imageUrls.length == 3)
                  Positioned(
                    left: 2 * 20.sp,
                    child: CircleAvatar(
                      radius: 16.sp,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 14.sp,
                        backgroundImage: FileImage(File(imageUrls[2])),
                      ),
                    ),
                  ),
              ],
            ),
          ),*/

        SizedBox(
          width: imageUrls.length >= 3 ? 70.w : imageUrls.length == 2
              ? 50.w
              : 30.w,
          height: 32.h,
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              for (int i = 0; i < min(2, imageUrls.length); i++)
                Positioned(
                  left: i * 20.w,
                  child: CircleAvatar(
                    radius: 16.sp,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 14.sp,
                      backgroundColor: Colors.grey.shade200,
                      child: ClipOval(
                        child: imageUrls[i].startsWith('http')
                            ? ImageLoader(
                          url: imageUrls[i],
                          width: 28.sp,
                          height: 28.sp,
                          boxFit: BoxFit.cover,
                        )
                            : Image.file(
                          File(imageUrls[i]),
                          width: 28.sp,
                          height: 28.sp,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),


              if (extraCount > 0)
                Positioned(
                  left: 2 * 20.w,
                  child: CircleAvatar(
                    radius: 15.sp,
                    backgroundColor: Colors.white,
                    child: Text(
                      '+$extraCount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),


              if (imageUrls.length == 3)
                Positioned(
                  left: 2 * 20.w,
                  child: CircleAvatar(
                    radius: 16.sp,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 14.sp,
                      backgroundColor: Colors.grey.shade200,
                      child: ClipOval(
                        child: imageUrls[2].startsWith('http')
                            ? ImageLoader(
                          url: imageUrls[2],
                          width: 28.sp,
                          height: 28.sp,
                          boxFit: BoxFit.cover,
                        )
                            : Image.file(
                          File(imageUrls[2]),
                          width: 28.sp,
                          height: 28.sp,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),


        SizedBox(width: 14.w),

          // Delete Button
          InkWell(
            onTap: (){
              addProductsController.colorItems.removeAt(index);
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
      ),
    );
  }
}