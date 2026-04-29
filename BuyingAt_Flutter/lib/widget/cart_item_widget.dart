import 'package:classified/controller/shopping_cart_controller.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import '../model/cart_product_model.dart';
import '../utils/_constant.dart';
import '../utils/app_color.dart';
import '../utils/app_fonts.dart';
import '../utils/app_image.dart';
import '../utils/image_loader.dart';

class CartItemCard extends StatelessWidget {
  final CartProduct item;
  final int totalItem;
  final ShoppingCartController shoppingCartController;

  const CartItemCard({
    super.key,
    required this.item,
    required this.shoppingCartController,
    required this.totalItem,

  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Row(
              children: [
                SizedBox(width: 16.w,),
                /// Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ImageLoader(
                    url: "${Constant.imageBaseUrl}${item.product
                        ?.getGalleryImages?.first.img}",
                    width: 72.h,
                    height: 72.h,
                    boxFit: BoxFit.cover,
                  ),
                ),

                SizedBox(width: 12.w),

                /// Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product?.productTitle ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: sansReg.copyWith(fontSize: 14.sp,
                            height: 1.42.h,
                            color: AppColor.primaryColor),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Text(
                            "\$${item.product?.price}",
                            style: sansBold.copyWith(
                                color: AppColor.buttonColor,
                                fontSize: 16.sp,
                                height: .9.h
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "\$${item.product?.discountedPrice}",
                            style: sansReg.copyWith(
                              fontSize: 14.sp,
                              height: 1.42.h,
                              color: AppColor.coolGray29,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: AppColor.coolGray29,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(width: 40.w,)


              ],
            ),
            SizedBox(height: 29.h,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: DottedLine(
                lineThickness: 1, dashColor: AppColor.coolGray19,),
            ),
          ],
        ),

        /// Qty Control
        Positioned(
          right: 16.w,
          bottom: 20.h,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColor.coolGray12, width: 1.sp,),
                borderRadius: BorderRadius.circular(3.r)
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    shoppingCartController.decreaseItem(productId: item.id);
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(11.w, 9.h, 18.w, 9.h),
                    child: SvgPicture.asset(AppImage.icMinus),
                  ),
                ),
                Obx(() {
                  return Text(
                      (shoppingCartController.cartQuantities[item.id] ?? 0).toString().padLeft(2, '0'));
                }),
                InkWell(
                  onTap: () {
                    shoppingCartController.increaseItem(productId: item.id);
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(18.w, 9.h, 11.w, 9.h),
                    child: SvgPicture.asset(AppImage.icAddThree),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 10.w,
          top: -5.h,
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              shoppingCartController.removeSingleCartItem(productId: item.id);
            },
            child: Padding(
              padding: EdgeInsets.all(12.sp),
              child: SvgPicture.asset(AppImage.icDeleteTwo,height: 20,),
            ),
          ),
        ),
      ],
    );
  }
}