import 'package:classified/utils/app_color.dart';
import 'package:classified/utils/app_fonts.dart';
import 'package:classified/utils/app_image.dart';
import 'package:classified/utils/app_text.dart';
import 'package:classified/widget/custom_app_bar.dart';
import 'package:classified/widget/custom_button.dart';
import 'package:classified/widget/custom_snackbar_widget.dart';
import 'package:classified/widget/custom_text_field_widget.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controller/shopping_cart_controller.dart';
import '../model/cart_product_model.dart';
import '../model/cart_card_model.dart';
import '../widget/cart_item_widget.dart';
import '../widget/card_cart_item_widget.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  late ShoppingCartController shoppingCartController;
  double? acceptedOfferAmount;


  @override
  void initState() {
    super.initState();
    shoppingCartController = Get.find<ShoppingCartController>();
    // Read accepted offer amount (if any) passed from Add to Deal screen
    try {
      final args = Get.arguments;
      if (args is Map && args['acceptedOfferAmount'] != null) {
        final value = args['acceptedOfferAmount'];
        if (value is num) {
          acceptedOfferAmount = value.toDouble();
        } else {
          acceptedOfferAmount = double.tryParse(value.toString());
        }
      }
    } catch (_) {}
    shoppingCartController.fetchCartItem(isReload: true);
    shoppingCartController.cartDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(
        title: 'Shopping Cart',
        action: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Obx(() {
            return shoppingCartController.totalCartItems > 0 ? InkWell(
              onTap: (){
                shoppingCartController.clearAllCartItem();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: SvgPicture.asset(AppImage.icDeleteTwo, height: 24.h,),
              ),
            ) : SizedBox.shrink();
          }),
        ),),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          Obx(() {
            return (shoppingCartController.totalCartItems == 0 &&
                shoppingCartController.isCartListLoading.isFalse)
                ? Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 80.w,
                            color: AppColor.coolGray21,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No cart item found',
                            style: sansMedium.copyWith(
                              color: AppColor.coolGray11,
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox.shrink();
          }),

          Obx(() {
            return shoppingCartController.totalCartItems > 0 ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: DottedLine(
                lineThickness: 1, dashColor: AppColor.coolGray19,),
            ) : SizedBox.shrink();
          }),

          /// Cart List
          Expanded(
            child: Obx(() {
              final productItems = shoppingCartController.cartList;
              final cardItems = shoppingCartController.cardCartList;
              final totalItems = shoppingCartController.isCartListLoading.value
                  ? 6
                  : shoppingCartController.totalCartItems;
              final isLoading = shoppingCartController.isCartListLoading.value;
              return Skeletonizer(
                enabled: isLoading,
                child: ListView.builder(
                  itemCount: isLoading ? totalItems : totalItems,
                  itemBuilder: (context, index) {
                    if (isLoading) {
                      return Padding(
                        padding: EdgeInsets.only(top: 20.h),
                        child: CartItemCard(
                          item: CartProduct(),
                          totalItem: shoppingCartController.totalCartItems,
                          shoppingCartController: shoppingCartController,
                        ),
                      );
                    }

                    final productCount = productItems.length;
                    if (index < productCount) {
                      final product = productItems[index];
                      return Padding(
                        padding: EdgeInsets.only(top: 20.h),
                        child: CartItemCard(
                          item: product,
                          totalItem: shoppingCartController.totalCartItems,
                          shoppingCartController: shoppingCartController,
                        ),
                      );
                    }

                    final cardIndex = index - productCount;
                    final CartCardItem cardItem = cardItems[cardIndex];
                    return Padding(
                      padding: EdgeInsets.only(top: 20.h),
                      child: CardCartItemCard(
                        item: cardItem,
                        shoppingCartController: shoppingCartController,
                      ),
                    );
                  },
                ),
              );
            }),
          ),

          /// Bottom Bar
          Obx(() {
            return shoppingCartController.totalCartItems > 0 ? InkWell(
              onTap: () {
                // shoppingCartController.cartList.isNotEmpty ? Get.bottomSheet(
                //     DetailsBottomSheet()
                // ) : null;
              },
              child: Container(
                padding: EdgeInsets.only(left: 24.w, top: 10.h, bottom: 10.h),
                decoration: BoxDecoration(
                  color: AppColor.ghostWhite,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border(top: BorderSide(color: AppColor.bottomNavBorder, width: 1.sp)),
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 0,
                      blurRadius: 12.48,
                      color: AppColor.dark.withValues(alpha: .04),
                      offset: Offset(0, -4.16)
                    )
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// Subtotal + Checkout
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Obx(() {
                              final cartDtl = shoppingCartController.cartDtl.value;
                              double subtotal = cartDtl.subTotal ?? 0.0;
                              double platformFee = cartDtl.platformFee ?? 0.0;
                              double tax = cartDtl.tax ?? 0.0;
                              double totalPrice = cartDtl.totalPrice ?? 0.0;

                              // If an accepted offer exists, override the visible subtotal
                              if (acceptedOfferAmount != null &&
                                  acceptedOfferAmount! > 0) {
                                subtotal = acceptedOfferAmount!;
                                // Keep platformFee and tax as provided by backend,
                                // but recompute visible total from the overridden subtotal.
                                totalPrice = subtotal + platformFee + tax;
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Subtotal
                                  Row(
                                    children: [
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Subtotal: ",
                                              style: sansReg.copyWith(
                                                  fontSize: 14.sp, height: 1.4.h),
                                            ),
                                            TextSpan(
                                              text: "\$${subtotal.toStringAsFixed(2)}",
                                              style: sansBold.copyWith(
                                                color: AppColor.buttonColor,
                                                height: 1.25.h,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8.w,),
                                      SvgPicture.asset(AppImage.icUp)
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  // Platform Fee (4%)
                                  Text(
                                    "Platform Fee (4%): \$${platformFee.toStringAsFixed(2)}",
                                    style: sansReg.copyWith(
                                        fontSize: 12.sp,
                                        color: AppColor.coolGray21,
                                        height: 1.42.h),
                                  ),
                                  SizedBox(height: 4.h),
                                  // Tax
                                  Text(
                                    "Tax: \$${tax.toStringAsFixed(2)}",
                                    style: sansReg.copyWith(
                                        fontSize: 12.sp,
                                        color: AppColor.coolGray21,
                                        height: 1.42.h),
                                  ),
                                  SizedBox(height: 8.h),
                                  // Total Price
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Total: ",
                                          style: sansSemiBold.copyWith(
                                              fontSize: 16.sp,
                                              height: 1.4.h,
                                              color: AppColor.primaryColor),
                                        ),
                                        TextSpan(
                                          text: "\$${totalPrice.toStringAsFixed(2)}",
                                          style: sansBold.copyWith(
                                            fontSize: 18.sp,
                                            color: AppColor.buttonColor,
                                            height: 1.25.h,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                        Spacer(),
                        Obx(() {
                          return InkWell(
                            onTap: () {
                              shoppingCartController.totalCartItems > 0
                                  ? Get.bottomSheet(
                                      PlaceOrderBottomSheet(
                                        shoppingCartController:
                                            shoppingCartController,
                                        acceptedOfferAmount: acceptedOfferAmount,
                                      ),
                                    )
                                  : null;
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(height: 60.h, width: 180.w,),
                                CustomButton(
                                  marginRight: 0,
                                  marginLeft: 0,
                                  height: 40.h,
                                  width: 132.w,
                                  fontSize: 16.sp,
                                  text: 'Checkout(${shoppingCartController
                                      .totalCartItems})',
                                ),
                              ],
                            ),
                          );
                        })
                      ],
                    ),
                  ],
                ),
              ),
            ) : SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}







class PlaceOrderBottomSheet extends StatelessWidget {
  final ShoppingCartController shoppingCartController;
  final double? acceptedOfferAmount;
  PlaceOrderBottomSheet({
    super.key,
    required this.shoppingCartController,
    this.acceptedOfferAmount,
  });

  final TextEditingController addressController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final FocusNode addressFocus = FocusNode();
  final FocusNode notesFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
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
            border: Border.all(color: AppColor.bottomNavBorder, width: 1)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16.h),
            Container(height: 3.h, width: 35.w,
              decoration: BoxDecoration(
                  color: AppColor.primaryColor.withValues(alpha: .20),
                  borderRadius: BorderRadius.circular(.3)
              ),
            ),

            SizedBox(height: 16.h,),
            Text(
              AppText.shippingAdditionalInformation,
              style: sansBold.copyWith(fontSize: 20.sp,
                  height: 1.25.h,
                  color: AppColor.primaryColor),
            ),

            SizedBox(height: 24.h),
            CustomTextFieldWidget(
              titleText: AppText.address,
              controller: addressController,
              hintText: AppText.addressTxt,
              showTitle: true,
              inputType: TextInputType.text,
            ),

            SizedBox(height: 18.h),
            CustomTextFieldWidget(
              titleText: AppText.orderNotes,
              hintText: AppText.orderNotesMsg,
              controller: notesController,
              showTitle: true,
              maxLines: 6,
              inputType: TextInputType.text,
            ),

            SizedBox(height: 24.h,),
            Obx(() {
              return CustomButton(
                text: AppText.placeOrder,
                marginLeft: 0,
                marginRight: 0,
                isLoading: shoppingCartController.isOrder.value,
                onPressed: () {
                  if (addressController.value.text.isEmpty) {
                    showCustomSnackBar('Please enter your address');
                  } else {
                    double? overrideTotal;
                    if (acceptedOfferAmount != null && acceptedOfferAmount! > 0) {
                      final cartDtl = shoppingCartController.cartDtl.value;
                      final platformFee = cartDtl.platformFee ?? 0.0;
                      final tax = cartDtl.tax ?? 0.0;
                      overrideTotal = acceptedOfferAmount! + platformFee + tax;
                    }

                    shoppingCartController.orderFromCart(
                      address: addressController.text.trim(),
                      note: notesController.text.trim(),
                      overrideTotalPrice: overrideTotal,
                    );
                  }
                },
              );
            }),

            SizedBox(height: 24.h,),
          ],
        ),
      ),
    );
  }
}


class DetailsBottomSheet extends StatelessWidget {
  const DetailsBottomSheet({super.key,});


  @override
  Widget build(BuildContext context) {
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
            border: Border.all(color: AppColor.bottomNavBorder, width: 1)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16.h,width: 1.sw,),
            Container(height: 3.h, width: 35.w,
              decoration: BoxDecoration(
                  color: AppColor.primaryColor.withValues(alpha: .20),
                  borderRadius: BorderRadius.circular(.3)
              ),
            ),

            SizedBox(height: 16.h,),
            Text(
              AppText.details,
              style: sansBold.copyWith(fontSize: 20.sp,
                  height: 1.25.h,
                  color: AppColor.primaryColor),
            ),



            SizedBox(height: 24.h,),
          ],
        ),
      ),
    );
  }
}
