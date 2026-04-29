import 'package:classified/controller/product_details_controller.dart';
import 'package:classified/utils/_constant.dart';
import 'package:classified/utils/image_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../model/product_model.dart';
import '../../utils/app_color.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_text.dart';
import '../../widget/custom_button.dart';
import '../../widget/custom_snackbar_widget.dart';
import '../../widget/custom_text_field_widget.dart';

class BuyNowBottomSheet extends StatefulWidget {
  final ProductsItem item;
  final  dynamic selectedQuantity;
  final  dynamic sku;

  const BuyNowBottomSheet({super.key, required this.item, required this.selectedQuantity, this.sku});

  @override
  State<BuyNowBottomSheet> createState() => _BuyNowBottomSheetState();
}

class _BuyNowBottomSheetState extends State<BuyNowBottomSheet> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final FocusNode addressFocus = FocusNode();
  final FocusNode notesFocus = FocusNode();

  late ProductDetailsController productDetailsController;

  @override
  void initState() {
    super.initState();
    productDetailsController = Get.find<ProductDetailsController>();
  }

  @override
  Widget build(BuildContext context) {
    final price = (widget.selectedQuantity * int.parse(widget.item.discountedPrice.toString()));
    final mainPrice = (widget.selectedQuantity * int.parse(widget.item.price.toString()));
    final totalDiscount = (mainPrice - price);
    print('________${widget.selectedQuantity}');
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        decoration: BoxDecoration(
          color: AppColor.ghostWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.dark.withValues(alpha: 0.04),
              offset: const Offset(0, -4.16),
              blurRadius: 12.48,
              spreadRadius: 0,
            ),
          ],
          border: Border.all(color: AppColor.bottomNavBorder, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16.h),
            Container(
              height: 3.h,
              width: 35.w,
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withValues(alpha: .20),
                borderRadius: BorderRadius.circular(.3),
              ),
            ),

            SizedBox(height: 16.h),
            Text(
              AppText.orderSummary,
              style: sansBold.copyWith(
                fontSize: 20.sp,
                height: 1.25.h,
                color: AppColor.primaryColor,
              ),
            ),

            SizedBox(height: 21.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ImageLoader(
                  url:
                  "${Constant.imageBaseUrl}${widget.item.getGalleryImages!.first
                      .img}",
                  height: 60.h,
                  width: 60.h,
                  boxFit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                SizedBox(width: 16.h),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.productTitle.toString(),
                        style: sansReg.copyWith(
                          fontSize: 14.sp,
                          height: 1.42.h,
                          color: AppColor.primaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 8.h,),
                      Row(
                        children: [
                          Text(
                            '${widget.selectedQuantity} x ',
                            style: sansSemiBold.copyWith(
                              fontSize: 16.sp,
                              height: .85.h,
                              color: AppColor.coolGray29,
                            ),
                          ),
                          Text(
                            '\$${widget.item.discountedPrice}',
                            style: sansBold.copyWith(
                              fontSize: 16.sp,
                              height: .85.h,
                              color: AppColor.buttonColor,
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 34.h,),
            RowTextWidget(leftText: 'Sub-total', rightText: "\$${widget.item.discountedPrice}",),

            SizedBox(height: 12.h,),
            RowTextWidget(leftText: 'Shipping', rightText: "Free",),

            SizedBox(height: 12.h,),
            RowTextWidget(leftText: 'Discount', rightText: "\$$totalDiscount",),

            SizedBox(height: 12.h,),
            RowTextWidget(leftText: 'Discount', rightText: "\$0",),

            SizedBox(height: 20.h,),
            Divider(height: 1.h, color: AppColor.coolGray12,),

            SizedBox(height: 16.h,),
            RowTextWidget(
              leftText: 'Total', rightText: "\$$price",
              styleLeft: sansReg.copyWith(
                  fontSize: 16.sp, height: 1.5.h, color: AppColor.primaryColor),
              styleRight: sansReg.copyWith(
                  fontSize: 16.sp, height: 1.5.h, color: AppColor.primaryColor),
            ),


            SizedBox(height: 40.h,),
            Text(
              AppText.shippingAdditionalInformation,
              style: sansBold.copyWith(
                fontSize: 20.sp,
                height: 1.25.h,
                color: AppColor.primaryColor,
              ),
            ),

            SizedBox(height: 24.h),
            CustomTextFieldWidget(
              titleText: AppText.address,
              controller: addressController,
              focusNode: addressFocus,
              nextFocus: notesFocus,
              hintText: AppText.addressTxt,
              showTitle: true,
              inputType: TextInputType.text,
            ),

            SizedBox(height: 18.h),
            CustomTextFieldWidget(
              titleText: AppText.orderNotes,
              hintText: AppText.orderNotesMsg,
              controller: notesController,
              focusNode: notesFocus,
              showTitle: true,
              maxLines: 6,
              inputType: TextInputType.text,
            ),

            SizedBox(height: 24.h),

            Obx(() {
              return CustomButton(
                text: AppText.placeOrder,
                marginLeft: 0,
                marginRight: 0,
                isLoading: productDetailsController.isBuyLoading.value,
                onPressed: () {
                  if (addressController.value.text.isEmpty) {
                    showCustomSnackBar('Please enter your address');
                  } else {
                    final sku = widget.sku.toString();
                    final quantity = widget.selectedQuantity;
                    print('___...._$quantity');
                    productDetailsController.buyProduct(
                        productId: widget.item.id,
                        vendorId: widget.item.userId,
                        deliveryAddress: addressController.text.trim(),
                        orderNote: notesController.text.trim(),
                        productAmount: price,
                        sku: sku,
                        quantity: quantity

                    );
                  }
                },
              );
            }),
            SizedBox(height: 34.h),
          ],
        ),
      ),
    );
  }
}


class RowTextWidget extends StatelessWidget {
  final String? leftText;
  final String? rightText;
  final TextStyle? styleLeft;
  final TextStyle? styleRight;

  const RowTextWidget({
    super.key,
    this.leftText,
    this.rightText,
    this.styleLeft,
    this.styleRight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          leftText ?? '',
          style: styleLeft ?? sansReg.copyWith(
              fontSize: 14.sp, height: 1.42.h, color: AppColor.primaryColor),
        ),
        Text(
          rightText ?? '',
          style: styleLeft ?? sansBold.copyWith(
              fontSize: 14.sp, height: 1.42.h, color: AppColor.primaryColor),
        ),
      ],
    );
  }
}
