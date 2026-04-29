import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:classified/model/shop_with_category_model.dart';
import 'package:classified/utils/app_color.dart';
import 'package:classified/utils/app_fonts.dart';
import 'package:classified/utils/app_text.dart';
import 'package:classified/widget/home_widgets/category_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../controller/home_controller.dart';
import '../model/banner_model.dart';
import '../model/product_model.dart';
import '../routes/app_routes.dart';
import '../transition/fade_transition.dart';
import '../utils/_constant.dart';
import '../utils/app_image.dart';
import '../utils/image_loader.dart';
import '../utils/session_manager.dart';
import '../widget/custom_app_bar.dart';
import '../widget/custom_title_bar.dart';
import '../widget/home_widgets/products_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeController homeController;
  late dynamic _isLoggedIn;

  @override
  void initState() {
    super.initState();
    homeController = Get.find<HomeController>();
    _isLoggedIn = SessionManager.getValue(kIsLOGIN, value: false);
  }

  @override
  Widget build(BuildContext context) {
    var currentBannerIndex = 0.obs;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, value) async {
          exit(0);

      },
      child: Scaffold(
        backgroundColor: AppColor.backGround,
        appBar: CustomAppBar(
          appHeight: 70.h,
          isBackButtonExist: false,
          leadingWidth: 40,
          leftPadding: 0.w,
          titleWidget: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(AppImage.icCarAndDream, height: 44.h),
              SizedBox(width: 12.w),
              Text(
                AppText.classified,
                style: sansExtraBold.copyWith(fontSize: 27.sp, height: 1.06.h),
              ),
              Spacer(),
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  if (_isLoggedIn) {
                    FadeScreenTransition(routeName: Routes.shoppingCartRoute).navigate();
                  } else {
                    FadeScreenTransition(routeName: Routes.authRoute).navigate();
                  }
                },
                child: Padding(
                  padding: EdgeInsets.only(top: 0.h, left: 10.w),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SvgPicture.asset(
                        AppImage.icCartHome,
                        height: 21.h,
                        width: 22.h,
                      ),
                      if (_isLoggedIn)
                        Obx(() {
                          return (homeController.totalProduct.value > 0)
                              ? Positioned(
                                  top: -12.h,
                                  right: -10.w,
                                  child: Container(
                                    padding: EdgeInsets.all(6.sp),
                                    decoration: BoxDecoration(
                                      color: AppColor.goldenYellow,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      homeController.totalProduct.value
                                          .toString(),
                                      style: sansSemiBold.copyWith(
                                        fontSize: 11.sp,
                                        height: 1.28,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink();
                        })
                    ],
                  ),
                ),
              ),
              SizedBox(width: 7.w),
            ],
          ),
        ),
        body: RefreshIndicator(
          displacement: 40.h,
          color: AppColor.ghostWhite,
          backgroundColor: AppColor.buttonColor,
          onRefresh: () async {
            await homeController.refreshData();
          },
          child: ListView(
            children: [

              /// Banner Slider
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Obx(() {
                  final isLoading = homeController.isBannerLoading.value;
                  if (!isLoading && homeController.listOfBanner.isEmpty) {
                    return SizedBox.shrink();
                  }
                  return Skeletonizer(
                    enabled: isLoading,
                    enableSwitchAnimation: true,
                    effect: PulseEffect(
                      from: Colors.grey[500]!,
                      to: Colors.grey[300]!,
                      duration: const Duration(seconds: 1),
                    ),
                    child: Stack(
                      children: [
                        CarouselSlider.builder(
                          itemCount: isLoading ? 5 : homeController.listOfBanner
                              .length,
                          itemBuilder: (BuildContext context, int itemIndex,
                              int pageViewIndex,) {
                            final bannerItem = isLoading
                                ? BannerItem()
                                : homeController.listOfBanner[itemIndex];

                            return InkWell(
                              borderRadius: BorderRadius.circular(10),

                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {
                                if (bannerItem.link != 'url') {
                                   // bannerItem.link?.launchUrlString();
                                }
                              },
                              child: ImageLoader(
                                height: 238.h,
                                width: double.infinity,
                                boxFit: BoxFit.cover,
                                radius: 6.r,
                                url: isLoading ? '' : '${Constant
                                    .imageBaseUrl}${bannerItem.img}',
                              ),
                            );
                          },
                          options: CarouselOptions(
                            height: 238.h,
                            viewportFraction: 1,
                            initialPage: 0,
                            enableInfiniteScroll: true,
                            autoPlay: isLoading ? false : true,
                            autoPlayInterval: const Duration(seconds: 5),
                            autoPlayAnimationDuration: const Duration(seconds: 1),
                            scrollDirection: Axis.horizontal,
                            onPageChanged: (index, reason) {
                              currentBannerIndex.value = index;
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 26.h,
                          left: 32.w,
                          child: AnimatedSmoothIndicator(
                            activeIndex: currentBannerIndex.value,
                            count: homeController.listOfBanner.isNotEmpty
                                ? homeController.listOfBanner.length
                                : 5,
                            effect: WormEffect(
                              dotHeight: 5.h,
                              dotWidth: 5.h,
                              spacing: 4.w,
                              activeDotColor: AppColor.primaryColor,
                              dotColor: AppColor.coolGray,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              /// Shop with categories
              Obx(() {
                final isLoading = homeController.isCategoryLoading.value;
                final isEmpty = homeController.categoryList.isEmpty;

                if (!isLoading && isEmpty) {
                  return SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    Skeletonizer(
                      enabled: isLoading,
                      enableSwitchAnimation: true,
                      effect: PulseEffect(
                        from: Colors.grey,
                        to: Colors.grey.withValues(alpha: 0.5),
                        duration: const Duration(seconds: 1),
                      ),
                      child: CustomTitleBar(
                        isSellAll: true,
                        titleStyle: sansSemiBold.copyWith(fontSize: 20.sp, height: 1.32.h,letterSpacing: .25 ),
                        title: AppText.shopWithCategories,
                        endTitle: AppText.seeAll,
                        onTap: () {
                          FadeScreenTransition(routeName: Routes.seeAllCategoriesRoute).navigate();
                        },
                        paddingWidget: EdgeInsets.only(left: 16.w),
                      ),
                    ),
                    SizedBox(height: 7.h),

                    Skeletonizer(
                      enabled: isLoading,
                      enableSwitchAnimation: true,
                      effect: PulseEffect(
                        from: Colors.grey,
                        to: Colors.grey.withValues(alpha: 0.5),
                        duration: const Duration(seconds: 1),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.only(left: 16.w),
                        child: Row(
                          crossAxisAlignment:CrossAxisAlignment.start,
                          children: List.generate(
                            isLoading ? 4 : homeController.categoryList.length,
                                (index) {
                              final item = isLoading
                                  ? ShopCategoryItem()
                                  : homeController.categoryList[index];
                              return CategoryItemCard(
                                item: item, isLoading: isLoading,);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              /// Best Deals
              Obx(() {
                final isLoading = homeController.isBestDealsLoading.value;
                final isEmpty = homeController.bestDealsList.isEmpty;

                if (!isLoading && isEmpty) {
                  return SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 28.h),
                    Skeletonizer(
                      enabled: isLoading,
                      enableSwitchAnimation: true,
                      effect: PulseEffect(
                        from: Colors.grey,
                        to: Colors.grey.withValues(alpha: 0.5),
                        duration: const Duration(seconds: 1),
                      ),
                      child: CustomTitleBar(
                        isSellAll: true,
                        title: AppText.bestDeals,
                        titleStyle: sansSemiBold.copyWith(fontSize: 20.sp, height: 1.32.h,letterSpacing: .25 ),
                        endTitle: AppText.seeAll,
                        onTap: () {
                          FadeScreenTransition(routeName: Routes.postListRoute,
                              arguments: {'type': 'bestDeal', 'categoryName': 'Best Deal'}).navigate();
                        },
                        paddingWidget: EdgeInsets.only(left: 16.w),
                      ),
                    ),
                    SizedBox(height: 7.h),

                    Skeletonizer(
                      enabled: isLoading,
                      enableSwitchAnimation: true,
                      effect: PulseEffect(
                        from: Colors.grey,
                        to: Colors.grey.withValues(alpha: 0.5),
                        duration: const Duration(seconds: 1),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.only(left: 16.w),
                        child: Row(
                          crossAxisAlignment:CrossAxisAlignment.start,
                          children: List.generate(
                            isLoading ? 5 : homeController.bestDealsList.length,
                                (index) {
                              final item = isLoading
                                  ? ProductsItem()
                                  : homeController.bestDealsList[index];
                              return ProductsCard(
                                item: item, isLoading: isLoading,);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              /// Advertises 1 add 2
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w,),
                child: Obx(() {
                  final isLoading = homeController.isAdvertisesLoading.value;

                  if (!isLoading &&
                      homeController.advertisesItem.value.img2 == null) {
                    return SizedBox.shrink();
                  }

                  return Skeletonizer(
                    enabled: isLoading,
                    enableSwitchAnimation: true,
                    ignorePointers: true,
                    effect: PulseEffect(
                      from: Colors.grey[500]!,
                      to: Colors.grey[200]!,
                      duration: const Duration(seconds: 1),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 40.h),
                        ImageLoader(
                          height: 235.h,
                          width: double.infinity,
                          boxFit: BoxFit.cover,
                          radius: 6.r,
                          url: isLoading ? '' : '${Constant
                              .imageBaseUrl}${homeController.advertisesItem.value
                              .img2}',
                        ),
                      ],
                    ),
                  );
                }),
              ),

              /// Featured Products
              Obx(() {
                final isLoading = homeController.isBestDealsLoading.value;
                final isEmpty = homeController.bestDealsList.isEmpty;

                if (!isLoading && isEmpty) {
                  return SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 35.h),
                    Skeletonizer(
                      enabled: isLoading,
                      enableSwitchAnimation: true,
                      effect: PulseEffect(
                        from: Colors.grey,
                        to: Colors.grey.withValues(alpha: 0.5),
                        duration: const Duration(seconds: 1),
                      ),
                      child: CustomTitleBar(
                        isSellAll: true,
                        titleStyle: sansSemiBold.copyWith(fontSize: 20.sp, height: 1.32.h,letterSpacing: .25 ),
                        title: AppText.featuredProducts,
                        endTitle: AppText.seeAll,
                        onTap: () {
                          FadeScreenTransition(routeName: Routes.postListRoute,
                              arguments: {'type': 'Featured','categoryName': 'Featured Products'}).navigate();
                        },
                        paddingWidget: EdgeInsets.only(left: 16.w),
                      ),
                    ),
                    SizedBox(height: 7.h),

                    Skeletonizer(
                      enabled: isLoading,
                      enableSwitchAnimation: true,
                      effect: PulseEffect(
                        from: Colors.grey,
                        to: Colors.grey.withValues(alpha: 0.5),
                        duration: const Duration(seconds: 1),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.only(left: 16.w),
                        child: Row(
                          crossAxisAlignment:CrossAxisAlignment.start,
                          children: List.generate(
                            isLoading ? 5 : homeController.featuredProductList
                                .length,
                                (index) {
                              final item = isLoading
                                  ? ProductsItem()
                                  : homeController.featuredProductList[index];
                              return ProductsCard(item: item,
                                isRating: true,
                                isLoading: isLoading,);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              /// Computer Accessories
              Obx(() {
                final isLoading = homeController.isElectronicsAccessoriesLoading
                    .value;
                final isEmpty = homeController.electronicsAccessoriesList.isEmpty;


                if (!isLoading && isEmpty) {
                  return SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 28.h),
                    CustomTitleBar(
                      isSellAll: true,
                      title: AppText.computerAccessories,
                      titleStyle: sansSemiBold.copyWith(fontSize: 20.sp, height: 1.32.h,letterSpacing: .25 ),
                      endTitle: AppText.seeAll,
                      onTap: () {
                        FadeScreenTransition(routeName: Routes.postListRoute,
                            arguments: {
                              'type': 'Computer',
                              'categoryName': 'Computer Accessories',
                              'categoryId': homeController
                                  .electronicsAccessoriesList.isNotEmpty
                                  ? homeController.electronicsAccessoriesList
                                  .first.categoryId?.toInt() ?? 0
                                  : 0
                            }).navigate();
                      },
                      paddingWidget: EdgeInsets.only(left: 16.w),
                    ),
                    SizedBox(height: 7.h),

                    Skeletonizer(
                      enabled: isLoading,
                      enableSwitchAnimation: true,
                      effect: PulseEffect(
                        from: Colors.grey,
                        to: Colors.grey.withValues(alpha: 0.5),
                        duration: const Duration(seconds: 1),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.only(left: 16.w),
                        child: Row(
                          crossAxisAlignment:CrossAxisAlignment.start,
                          children: List.generate(
                            isLoading ? 5 : homeController
                                .electronicsAccessoriesList.length,
                                (index) {
                              final item = isLoading
                                  ? ProductsItem()
                                  : homeController
                                  .electronicsAccessoriesList[index];
                              return ProductsCard(item: item,
                                isRating: true,
                                isLoading: isLoading,);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              /// Advertises 2  add 3
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w,),
                child: Obx(() {
                  final isLoading = homeController.isAdvertisesLoading.value;

                  if (!isLoading &&
                      homeController.advertisesItem.value.img3 == null) {
                    return SizedBox.shrink();
                  }
                  return Skeletonizer(
                    enabled: isLoading,
                    enableSwitchAnimation: true,
                    ignorePointers: true,
                    effect: PulseEffect(
                      from: Colors.grey[500]!,
                      to: Colors.grey[200]!,
                      duration: const Duration(seconds: 1),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: homeController.advertisesItem.value
                            .img3 == null ? 0.h : 40.h,),
                        ImageLoader(
                          height: 233.h,
                          width: double.infinity,
                          boxFit: BoxFit.cover,
                          radius: 6.r,
                          url: isLoading ? '' : '${Constant
                              .imageBaseUrl}${homeController.advertisesItem.value
                              .img3}',
                        ),
                      ],
                    ),
                  );
                }),
              ),

              /// Advertises 3 add 6
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w,),
                child: Obx(() {
                  final isLoading = homeController.isAdvertisesLoading.value;

                  if (!isLoading &&
                      homeController.advertisesItem.value.img6 == null) {
                    return SizedBox.shrink();
                  }

                  return Skeletonizer(
                    enabled: homeController.advertisesItem.value.img6 == null,
                    enableSwitchAnimation: true,
                    ignorePointers: true,
                    effect: PulseEffect(
                      from: Colors.grey[500]!,
                      to: Colors.grey[200]!,
                      duration: const Duration(seconds: 1),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: homeController.advertisesItem.value
                            .img6 == null ? 35.h : 32.h,),
                        ImageLoader(
                          height: 233.h,
                          width: double.infinity,
                          boxFit: BoxFit.fill,
                          radius: 6.r,
                          url: isLoading ? '' : '${Constant
                              .imageBaseUrl}${homeController.advertisesItem.value
                              .img6}',
                        ),
                      ],
                    ),
                  );
                }),
              ),

              /// Top Rated
              Obx(() {
                final isLoading = homeController.isTopRatedLoading.value;
                final isEmpty = homeController.topRatedList.isEmpty;

                if (!isLoading && isEmpty) {
                  return SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 28.h),
                    Skeletonizer(
                      enabled: isLoading,
                      enableSwitchAnimation: true,
                      effect: PulseEffect(
                        from: Colors.grey,
                        to: Colors.grey.withValues(alpha: 0.5),
                        duration: const Duration(seconds: 1),
                      ),
                      child: CustomTitleBar(
                        isSellAll: true,
                        titleStyle: sansSemiBold.copyWith(fontSize: 20.sp, height: 1.32.h,letterSpacing: .25 ),
                        title: AppText.topRated,
                        endTitle: AppText.seeAll,
                        onTap: () {
                          FadeScreenTransition(routeName: Routes.postListRoute,
                              arguments: {'type': 'TopRated','categoryName': 'Top Rated',}).navigate();
                        },
                        paddingWidget: EdgeInsets.only(left: 16.w),
                      ),
                    ),
                    SizedBox(height: 7.h),

                    Skeletonizer(
                      enabled: isLoading,
                      enableSwitchAnimation: true,
                      effect: PulseEffect(
                        from: Colors.grey,
                        to: Colors.grey.withValues(alpha: 0.5),
                        duration: const Duration(seconds: 1),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.only(left: 16.w),
                        child: Row(
                          crossAxisAlignment:CrossAxisAlignment.start,
                          children: List.generate(
                            isLoading ? 5 : homeController.topRatedList.length,
                                (index) {
                              final item = isLoading
                                  ? ProductsItem()
                                  : homeController.topRatedList[index];
                              return ProductsCard(
                                item: item, isLoading: isLoading,);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              /// New Arrivals
              Obx(() {
                final isLoading = homeController.isNewArrivalsLoading.value;
                final isEmpty = homeController.newArrivalsList.isEmpty;

                if (!isLoading && isEmpty) {
                  return SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 28.h),
                    Skeletonizer(
                      enabled: isLoading,
                      enableSwitchAnimation: true,
                      effect: PulseEffect(
                        from: Colors.grey,
                        to: Colors.grey.withValues(alpha: 0.5),
                        duration: const Duration(seconds: 1),
                      ),
                      child: CustomTitleBar(
                        isSellAll: true,
                        title: AppText.newArrivals,
                        titleStyle: sansSemiBold.copyWith(fontSize: 20.sp, height: 1.32.h,letterSpacing: .25 ),
                        endTitle: AppText.seeAll,
                        onTap: () {
                          FadeScreenTransition(routeName: Routes.postListRoute,
                              arguments: {'type': 'New','categoryName': 'New Arrivals'}).navigate();
                        },
                        paddingWidget: EdgeInsets.only(left: 16.w),
                      ),
                    ),
                    SizedBox(height: 7.h),

                    Skeletonizer(
                      enabled: isLoading,
                      enableSwitchAnimation: true,
                      effect: PulseEffect(
                        from: Colors.grey,
                        to: Colors.grey.withValues(alpha: 0.5),
                        duration: const Duration(seconds: 1),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,

                        padding: EdgeInsets.only(left: 16.w),
                        child: Row(
                          crossAxisAlignment:CrossAxisAlignment.start,
                          children: List.generate(
                            isLoading ? 5 : homeController.newArrivalsList.length,
                                (index) {
                              final item = isLoading
                                  ? ProductsItem()
                                  : homeController.newArrivalsList[index];
                              return ProductsCard(
                                item: item, isLoading: isLoading,);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              /// Advertises 4  add 5
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w,),
                child: Obx(() {
                  final isLoading = homeController.isAdvertisesLoading.value;

                  if (!isLoading &&
                      homeController.advertisesItem.value.img5 == null) {
                    return SizedBox.shrink();
                  }

                  return Skeletonizer(
                    enabled: homeController.advertisesItem.value.img5 == null,
                    enableSwitchAnimation: true,
                    ignorePointers: true,
                    effect: PulseEffect(
                      from: Colors.grey[500]!,
                      to: Colors.grey[200]!,
                      duration: const Duration(seconds: 1),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: homeController.advertisesItem.value
                            .img5 == null ? 0.h : 40.h,),
                        ImageLoader(
                          height: 206.h,
                          width: double.infinity,
                          boxFit: BoxFit.cover,
                          radius: 6.r,
                          url: isLoading ? '' : '${Constant
                              .imageBaseUrl}${homeController.advertisesItem.value
                              .img5}',
                        ),
                      ],
                    ),
                  );
                }),
              ),

              /// Advertises 3 add 8
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w,),
                child: Obx(() {
                  final isLoading = homeController.isAdvertisesLoading.value;

                  if (!isLoading &&
                      homeController.advertisesItem.value.img8 == null) {
                    return SizedBox.shrink();
                  }

                  return Skeletonizer(
                    enabled: homeController.advertisesItem.value.img8 == null,
                    enableSwitchAnimation: true,
                    ignorePointers: true,
                    effect: PulseEffect(
                      from: Colors.grey[500]!,
                      to: Colors.grey[200]!,
                      duration: const Duration(seconds: 1),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: homeController.advertisesItem.value
                            .img8 == null ? 35.h : 32.h,),
                        ImageLoader(
                          height: 176.h,
                          width: double.infinity,
                          boxFit: BoxFit.fill,
                          radius: 6.r,
                          url: isLoading ? '' : '${Constant
                              .imageBaseUrl}${homeController.advertisesItem.value
                              .img8}',
                        ),
                      ],
                    ),
                  );
                }),
              ),

              SizedBox(height: 26.h,),
            ],
          ),
        ),
      ),
    );
  }
}
