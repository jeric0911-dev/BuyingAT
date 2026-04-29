import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controller/see_all_controller.dart';
import '../model/shop_with_category_model.dart';
import '../utils/app_color.dart';
import '../utils/app_text.dart';
import '../widget/custom_app_bar.dart';
import '../widget/home_widgets/category_item_card.dart';

class SeeAllCategories extends StatefulWidget {
  const SeeAllCategories({super.key});

  @override
  State<SeeAllCategories> createState() => _SeeAllCategoriesState();
}


class _SeeAllCategoriesState extends State<SeeAllCategories> {
  late  SeeAllController seeAllController;
  @override
  void initState() {
    super.initState();
    seeAllController = Get.find<SeeAllController>();
    seeAllController.fetchCategory(isReload: true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        Get.back();
      },
      child: Scaffold(
        backgroundColor: AppColor.backGround,
        appBar: CustomAppBar(title: AppText.category, onTapBack: (){
          Get.back();
        },),
        body:  Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Obx(() {
        final isLoading = seeAllController.isCategoryLoading.value;
        return Skeletonizer(
          enabled: isLoading,
          enableSwitchAnimation: true,
          effect: PulseEffect(
            from: Colors.grey,
            to: Colors.grey.withValues(alpha: 0.5),
            duration: const Duration(seconds: 1),
          ),
          child: AlignedGridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(), // disable internal scroll
            crossAxisCount: 2,
            itemCount: isLoading ? 5 : seeAllController.categoryList.length,
            crossAxisSpacing: 17.w,
            mainAxisSpacing: 4.h,
            itemBuilder: (context, index) {
              final item = isLoading ? ShopCategoryItem() : seeAllController.categoryList[index];
              return InkWell(
                onTap: () {

                },
                child: CategoryItemCard(item: item,isLoading: isLoading,isSeeAll: true,),

              );
            },
          ),
        );
      }),
    ),

      ),
    );
  }
}
