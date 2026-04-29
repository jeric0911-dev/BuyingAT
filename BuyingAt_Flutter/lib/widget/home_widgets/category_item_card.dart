import 'package:classified/model/shop_with_category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../routes/app_routes.dart';
import '../../transition/fade_transition.dart';
import '../../utils/_constant.dart';
import '../../utils/app_fonts.dart';
import '../../utils/image_loader.dart';

class CategoryItemCard extends StatelessWidget {
  final ShopCategoryItem item;
  final bool isLoading;
  final bool isSeeAll;
  const CategoryItemCard({super.key, required this.item,  this.isLoading = true,  this.isSeeAll = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        FadeScreenTransition(routeName: Routes.postListRoute,
            arguments: {'categoryId': item.id,'categoryName':item.categoryName}).navigate();
      },
      child: Padding(
        padding:   EdgeInsets.only(right:isSeeAll? 0 :  23.w),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 9.w),
              child: ImageLoader(
                url: isLoading ? '' : "${Constant.imageBaseUrl}${item.icon}",
                height: isSeeAll? 160.h :80.h,
                width: isSeeAll? double.infinity : 80.w,
                boxFit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 13.h),
            Text(
              item.categoryName.toString(),
              style: sansMedium.copyWith(
                fontSize: 14.sp,
                height: 1.07.h,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h,),
          ],
        ),
      ),
    );
  }
}
