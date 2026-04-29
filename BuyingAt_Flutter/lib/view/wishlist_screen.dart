import 'dart:convert';
import 'package:classified/controller/product_details_controller.dart';
import 'package:classified/model/wish_list_model.dart';
import 'package:classified/model/card_model.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controller/shopping_cart_controller.dart';
import '../routes/app_routes.dart';
import '../transition/fade_transition.dart';
import '../utils/_constant.dart';
import '../utils/app_color.dart';
import '../utils/app_fonts.dart';
import '../utils/app_image.dart';
import '../utils/image_loader.dart';
import '../widget/custom_app_bar.dart';
import '../widget/no_data_widget.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late ShoppingCartController shoppingCartController;


  @override
  void initState() {
    super.initState();
    shoppingCartController = Get.find<ShoppingCartController>();
    shoppingCartController.fetchWishList(isReload: true);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(
        title: 'Wishlist',
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          Obx(() {
            final hasProducts = shoppingCartController.wishList.isNotEmpty;
            final hasCards = shoppingCartController.cardWishList.isNotEmpty;
            final isLoading = shoppingCartController.isWishListLoading.value || shoppingCartController.isCardWishListLoading.value;
            
            if (!hasProducts && !hasCards && !isLoading) {
              return Center(
                child: NoDataWidget(text: 'Item Not found'),
              );
            }
            return SizedBox.shrink();
          }),

          Obx(() {
            final hasProducts = shoppingCartController.wishList.isNotEmpty;
            final hasCards = shoppingCartController.cardWishList.isNotEmpty;
            return (hasProducts || hasCards) ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: DottedLine(
                lineThickness: 1, dashColor: AppColor.coolGray19,),
            ) : SizedBox.shrink();
          }),

          /// Wishlist List (Products + Cards)
          Expanded(
            child: Obx(() {
              final productItems = shoppingCartController.wishList;
              final cardItems = shoppingCartController.cardWishList;
              final isLoading = shoppingCartController.isWishListLoading.value || shoppingCartController.isCardWishListLoading.value;
              
              final totalItems = productItems.length + cardItems.length;
              
              return Skeletonizer(
                enabled: isLoading,
                child: ListView.builder(
                  itemCount: isLoading ? 6 : totalItems,
                  itemBuilder: (context, index) {
                    if (isLoading) {
                      return Padding(
                        padding: EdgeInsets.only(top: 20.h),
                        child: WishCartItemCard(
                          item: WishlistData(),
                          totalItem: 0,
                        ),
                      );
                    }
                    
                    // Show products first, then cards
                    if (index < productItems.length) {
                      final item = productItems[index];
                    return Padding(
                      padding: EdgeInsets.only(top: 20.h),
                      child: WishCartItemCard(
                        item: item,
                          totalItem: totalItems,
                        ),
                      );
                    } else {
                      final cardIndex = index - productItems.length;
                      final card = cardItems[cardIndex];
                      return Padding(
                        padding: EdgeInsets.only(top: 20.h),
                        child: WishCardItemCard(
                          card: card,
                          totalItem: totalItems,
                      ),
                    );
                    }
                  },
                ),
              );
            }),
          ),


        ],
      ),
    );
  }
}

class WishCartItemCard extends StatelessWidget {
  final WishlistData item;
  final int totalItem;

  const WishCartItemCard({
    super.key,
    required this.item,
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
                    url: "${Constant.imageBaseUrl}${item.product?.getGalleryImages?.first.img}",
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        item.product?.productTitle ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: sansReg.copyWith(fontSize: 14.sp,
                            height: 1.42.h,
                            color: AppColor.primaryColor),
                      ),

                      SizedBox(height: 8.h),
                      Text(
                        item.product?.stock == null? 'Stock Out' : 'In Stock',
                        style: sansSemiBold.copyWith(
                            color: item.product?.stock != null ? AppColor.amberOrange : AppColor.deepGreen1,
                            fontSize: 14.sp,
                            height: 1.42.h
                        ),
                      ),

                      SizedBox(height: 11.h,),
                      Text(
                        "\$${item.product?.discountedPrice}",
                        style: sansBold.copyWith(
                            color: AppColor.buttonColor,
                            fontSize: 16.sp,
                            height: .9.h
                        ),
                      ),
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


        Positioned(
          right: 16.w,
          bottom: 20.h,
          child: Row(
            children: [
              InkWell(
                onTap: (){
                  FadeScreenTransition(routeName: Routes.productDtlRoute, arguments: {'PId':item.productId,'productUserId':item.userId}).navigate();
                },
                  child: SvgPicture.asset(AppImage.icCartTwo,height: 44.h,)),
              InkWell(
                onTap: (){
                Get.find<ProductDetailsController>().deleteWishList(productId: item.productId.toString());
                Get.find<ShoppingCartController>().deleteToWishCard(productId: item.productId);
                },
                child: Padding(
                  padding:  EdgeInsets.only(left: 16.w,right: 5.w,top: 5.h,bottom: 5.h),
                  child: SvgPicture.asset(AppImage.icDeleteTwo,height: 24.h,),
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }
}

class WishCardItemCard extends StatelessWidget {
  final CardItem card;
  final int totalItem;

  const WishCardItemCard({
    super.key,
    required this.card,
    required this.totalItem,
  });

  @override
  Widget build(BuildContext context) {
    // Parse images
    List<String> imageList = [];
    if (card.images != null) {
      try {
        if (card.images is String) {
          try {
            final decoded = jsonDecode(card.images!);
            if (decoded is List) {
              imageList = decoded.map((e) => e.toString()).toList();
            } else if (decoded is String) {
              imageList = [decoded];
            }
          } catch (e) {
            imageList = [card.images!];
          }
        } else if (card.images is List) {
          imageList = (card.images as List).map((e) => e.toString()).toList();
        } else {
          imageList = [card.images.toString()];
        }
      } catch (e) {
        if (card.images != null) {
          imageList = [card.images.toString()];
        }
      }
    }

    final firstImage = imageList.isNotEmpty ? imageList.first : '';

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
                  child: firstImage.isNotEmpty
                      ? ImageLoader(
                          url: '${Constant.imageBaseUrl}$firstImage',
                          width: 72.h,
                          height: 72.h,
                          boxFit: BoxFit.cover,
                        )
                      : Container(
                          width: 72.h,
                          height: 72.h,
                          color: AppColor.ghostWhite,
                          child: Icon(Icons.image, size: 24.w, color: AppColor.coolGray21),
                        ),
                ),

                SizedBox(width: 12.w),

                /// Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        card.cardTitle ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: sansReg.copyWith(fontSize: 14.sp,
                            height: 1.42.h,
                            color: AppColor.primaryColor),
                      ),

                      SizedBox(height: 8.h),
                      if (card.sportType != null && card.sportType!.isNotEmpty)
                        Text(
                          card.sportType!,
                          style: sansSemiBold.copyWith(
                              color: AppColor.buttonColor,
                              fontSize: 12.sp,
                              height: 1.42.h
                          ),
                        ),

                      SizedBox(height: 11.h,),
                      Text(
                        "\$${card.price ?? '0.00'}",
                        style: sansBold.copyWith(
                            color: AppColor.buttonColor,
                            fontSize: 16.sp,
                            height: .9.h
                        ),
                      ),
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

        Positioned(
          right: 16.w,
          bottom: 20.h,
          child: Row(
            children: [
              InkWell(
                onTap: (){
                  // Navigate to browse cards screen (you may want to create a card details route)
                  // For now, just navigate to browse cards
                  FadeScreenTransition(routeName: Routes.browseCardsRoute).navigate();
                },
                child: SvgPicture.asset(AppImage.icCartTwo,height: 44.h,)),
              InkWell(
                onTap: (){
                  Get.find<ShoppingCartController>().deleteCardFromWishlist(cardId: card.id);
                },
                child: Padding(
                  padding:  EdgeInsets.only(left: 16.w,right: 5.w,top: 5.h,bottom: 5.h),
                  child: SvgPicture.asset(AppImage.icDeleteTwo,height: 24.h,),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}