import 'package:classified/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../helper/number_helper.dart';
import '../../model/product_model.dart';
import '../../routes/app_routes.dart';
import '../../transition/fade_transition.dart';
import '../../utils/_constant.dart';
import '../../utils/app_fonts.dart';
import '../../utils/image_loader.dart';
import '../rating_bar.dart';

class ProductsCard extends StatelessWidget {
  final ProductsItem item;
  final bool isRating;
  final bool isFilter;
  final bool isLoading;

  const ProductsCard({
    super.key,
    required this.item,
    this.isRating = false,
    this.isFilter = false,
    this.isLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        if (!isLoading) {
          FadeScreenTransition(
            routeName: Routes.productDtlRoute,
            params: {'product': item.id.toString()},
            arguments: {'PId': item.id, 'productUserId': item.userId},
          ).navigate();
        }
      },
      child: Padding(
        padding: EdgeInsets.only(right: isFilter ? 0 : 24.w),
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.white,
            border: isFilter
                ? Border.all(color: AppColor.coolGray7, width: 1.sp)
                : null,
            borderRadius: BorderRadius.circular(isFilter ? 4.r : 0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ImageLoader(
                borderRadius: isFilter
                    ? BorderRadius.only(
                        topLeft: Radius.circular(4.r),
                        topRight: Radius.circular(4.r),
                      )
                    : null,
                url: isLoading
                    ? ''
                    : "${Constant.imageBaseUrl}${item.getGalleryImages?.first.img}",
                height: isFilter ? 160.h : 110.h,
                width: isFilter ? double.infinity : 118.w,
                boxFit: BoxFit.cover,
              ),
              SizedBox(height: 10.h),

              Padding(
                padding: EdgeInsets.only(
                  left: isFilter ? 10.w : 0,
                  right: isFilter ? 10.w : 0,
                  bottom: isFilter ? 14.h : 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (isRating)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RatingBar(
                            rating: double.parse(item.ratingsAvgRating ?? '0'),
                            size: 16.sp,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "(${item.ratingsCount})",
                            style: sansReg.copyWith(
                              fontSize: 12.sp,
                              height: 1.33.h,
                              color: AppColor.coolGray1,
                            ),
                          ),
                        ],
                      ),
                    if (isRating) SizedBox(height: 8.h),
                    SizedBox(
                      width: isFilter ? 171.w : 118.w,
                      child: Text(
                        item.productTitle.toString(),
                        style: sansMedium.copyWith(
                          fontSize: 14.sp,
                          height: 1.42.h,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '\$',
                            style: sansBold.copyWith(
                              fontSize: 16.sp,
                              height: 1.17.h,
                              color: AppColor.buttonColor,
                            ),
                          ),
                          TextSpan(
                            text: formatNumber(int.parse(item.price ?? '0')),
                            style: sansBold.copyWith(
                              fontSize: 16.sp,
                              height: 1.17.h,
                              color: AppColor.buttonColor,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
