import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../controller/shopping_cart_controller.dart';
import '../model/cart_card_model.dart';
import '../utils/_constant.dart';
import '../utils/app_color.dart';
import '../utils/app_fonts.dart';
import '../utils/app_image.dart';
import '../utils/image_loader.dart';

class CardCartItemCard extends StatelessWidget {
  final CartCardItem item;
  final ShoppingCartController shoppingCartController;

  const CardCartItemCard({
    super.key,
    required this.item,
    required this.shoppingCartController,
  });

  String? _resolveImage(dynamic images) {
    if (images == null) return null;
    if (images is String) {
      final trimmed = images.trim();
      if (trimmed.isEmpty) return null;
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return trimmed;
      }
      if (trimmed.startsWith('[')) {
        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is List && decoded.isNotEmpty) {
            final first = decoded.first.toString();
            if (first.startsWith('http://') || first.startsWith('https://')) {
              return first;
            }
            return '${Constant.imageBaseUrl}$first';
          }
        } catch (_) {
          // ignore parsing error
        }
      }
      return '${Constant.imageBaseUrl}$trimmed';
    }
    if (images is List && images.isNotEmpty) {
      final first = images.first.toString();
      if (first.startsWith('http://') || first.startsWith('https://')) {
        return first;
      }
      return '${Constant.imageBaseUrl}$first';
    }
    if (images is Map && images.isNotEmpty) {
      final firstValue = images.values.first;
      if (firstValue != null) {
        final value = firstValue.toString();
        if (value.startsWith('http://') || value.startsWith('https://')) {
          return value;
        }
        return '${Constant.imageBaseUrl}$value';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final card = item.card;
    final imageUrl = card != null ? _resolveImage(card.images) : null;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 16.w),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl != null
                      ? ImageLoader(
                          url: imageUrl,
                          width: 72.h,
                          height: 72.h,
                          boxFit: BoxFit.cover,
                        )
                      : Container(
                          width: 72.h,
                          height: 72.h,
                          color: AppColor.coolGray17,
                          child: Icon(
                            Icons.image,
                            color: AppColor.coolGray21,
                          ),
                        ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card?.title ?? 'Card',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: sansReg.copyWith(
                          fontSize: 14.sp,
                          height: 1.42.h,
                          color: AppColor.primaryColor,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      if (card?.grade != null && card!.grade!.isNotEmpty)
                        Text(
                          'Grade: ${card.grade}',
                          style: sansReg.copyWith(
                            fontSize: 12.sp,
                            color: AppColor.coolGray21,
                          ),
                        ),
                      if (card?.condition != null && card!.condition!.isNotEmpty)
                        Text(
                          'Condition: ${card.condition}',
                          style: sansReg.copyWith(
                            fontSize: 12.sp,
                            color: AppColor.coolGray21,
                          ),
                        ),
                      if (card?.sportType != null && card!.sportType!.isNotEmpty)
                        Text(
                          card.sportType!,
                          style: sansReg.copyWith(
                            fontSize: 12.sp,
                            color: AppColor.coolGray21,
                          ),
                        ),
                      SizedBox(height: 10.h),
                      Text(
                        '\$${card?.price ?? '0'}',
                        style: sansBold.copyWith(
                          color: AppColor.buttonColor,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 40.w),
              ],
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                height: 1,
                color: AppColor.coolGray19,
              ),
            ),
          ],
        ),
        Positioned(
          right: 10.w,
          top: -5.h,
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              if (item.id != null) {
                shoppingCartController.removeSingleCartItem(
                  productId: item.id,
                  isCard: true,
                );
              }
            },
            child: Padding(
              padding: EdgeInsets.all(12.sp),
              child: SvgPicture.asset(
                AppImage.icDeleteTwo,
                height: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
