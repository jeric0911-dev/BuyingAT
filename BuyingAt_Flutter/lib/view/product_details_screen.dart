import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:classified/controller/message_controller.dart';
import 'package:classified/utils/app_fonts.dart';
import 'package:classified/utils/app_text.dart';
import 'package:classified/utils/image_loader.dart';
import 'package:classified/utils/session_manager.dart';
import 'package:classified/widget/custom_button.dart';
import 'package:classified/widget/custom_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controller/product_details_controller.dart';
import '../helper/drop_down_helper.dart';
import '../helper/format_price_helper.dart';
import '../model/product_model.dart';
import '../routes/app_routes.dart';
import '../service/dynamic_link_service.dart';
import '../transition/fade_transition.dart';
import '../utils/_constant.dart';
import '../utils/app_color.dart';
import '../utils/app_image.dart';
import '../widget/custom_drop_dawn_btn.dart';
import '../widget/custom_dropdown_widget.dart';
import '../widget/custom_snackbar_widget.dart';
import '../widget/home_widgets/products_card.dart';
import '../widget/rating_bar.dart';
import '../widget/round_back_btn.dart';
import '../widget/round_btn.dart';
import 'bottom_sheet/buy_now_bottom_sheet.dart';
import 'dialog/preview_image_dialog.dart';
import 'dialog/report_product_dialog.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final CarouselSliderController _carouselController =
  CarouselSliderController();
  var currentImageIndex = 0.obs;

  late ProductDetailsController productDetailsController;
  late dynamic productId;
  late dynamic _isLoggedIn;
  late int _productUserId;
  late int _userId;
  var product = ProductsItem().obs;
  var sizeSelectedList = <DropdownItem<int>>[].obs;
  var variantSelectedList = <DropdownItem<int>>[].obs;
  var colorsSelectedList = <ProductColor>[].obs;
  var productStockList = <ProductStock>[].obs;


  var selectedSizeId = 0.obs;
  var selectedVariantId = 0.obs;
  var selectedColorId = 0.obs;
  var skuStock = ''.obs;
  var amount = 0.obs;
  var selectedQuantity = 0.obs;


  @override
  void initState() {
    super.initState();
    productId = Get.arguments['PId'];
    _productUserId = Get.arguments['productUserId'];
    _userId = SessionManager.getValue(kUserId, value: 0);
    _isLoggedIn = SessionManager.getValue(kIsLOGIN, value: false);
    productDetailsController = Get.find<ProductDetailsController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      product.value = await productDetailsController.getSingleProduct(
        productId: productId,
      );
      productData(product.value);
      if (_isLoggedIn) productDetailsController.fetchWishList(isReload: true);
    });
  }

  void productData(ProductsItem product) {
    /// added sizes
    if (product.sizes?.isNotEmpty ?? false) {
      sizeSelectedList.value = generateDropdownItems<ProductSize>(
        product.sizes!,
            (sizeItem) => sizeItem.size,
            (sizeItem) => sizeItem.id,
      );
    }

    /// added variants
    if (product.variants?.isNotEmpty ?? false) {
      variantSelectedList.value = generateDropdownItems<ProductVariant>(
        product.variants!,
            (variantItem) => variantItem.variantName,
            (variantItem) => variantItem.id,
      );
    }

    /// added colors
    if (product.colors?.isNotEmpty ?? false) {
      colorsSelectedList.addAll(product.colors!);
    }

    /// added product Stock
    if (product.stocks?.isNotEmpty ?? false) {
      productStockList.addAll(product.stocks!);
    }
  }

  void onButtonClick({dynamic type}) {
    if (colorsSelectedList.isNotEmpty && selectedColorId.value == 0) {
      showCustomSnackBar("Please select a color");
      return;
    }

    if (sizeSelectedList.isNotEmpty && selectedSizeId.value == 0) {
      showCustomSnackBar("Please select a size");
      return;
    }

    if (variantSelectedList.isNotEmpty && selectedVariantId.value == 0) {
      showCustomSnackBar("Please select a variant");
      return;
    }

    if (selectedQuantity.value == 0) {
      showCustomSnackBar("Please select a Quantity");
      return;
    }
    final stock = findMatchingStock();
    final bool isQuantityAvailable = selectedQuantity.value <=
        stock!.stock!.toInt();
    if (stock.id != null && isQuantityAvailable &&
        selectedQuantity.value != 0) {
      skuStock.value = stock.sku.toString();

      type == 'cart' ? productDetailsController.addToCart(
          product.value.id!.toInt(),
          product.value.getProductUser!.id!.toInt(),
          skuStock.value,
          selectedQuantity.value
      ) :
      Get.bottomSheet(
        BuyNowBottomSheet(
          item: product.value,
          selectedQuantity: selectedQuantity.value,
          sku: skuStock.value,
        ),
        isScrollControlled: true,
        isDismissible: false,
      );
    } else {
      showCustomSnackBar("Available stock: ${stock.stock}", duration: 3);
    }
  }

  ProductStock? findMatchingStock() {
    return productStockList.firstWhere(
          (stock) =>
      (selectedColorId.value == 0 || stock.colorId == selectedColorId.value) &&
          (selectedSizeId.value == 0 || stock.sizeId == selectedSizeId.value) &&
          (selectedVariantId.value == 0 ||
              stock.variantId == selectedVariantId.value),
      orElse: () => ProductStock(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var selectedColorIndex = (-1).obs;
    productDetailsController.quantity();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: CustomScrollView(
            slivers: [
              Obx(() {
                final productItem =
                product
                    .value
                    .getGalleryImages
                    ?.isNotEmpty ==
                    true
                    ? product.value.getGalleryImages
                    : null;
                return SliverAppBar(
                  backgroundColor: AppColor.white,
                  surfaceTintColor: Colors.transparent,
                  expandedHeight: 325.h,
                  collapsedHeight: 185.h,
                  floating: true,
                  pinned: true,
                  leadingWidth: 0,
                  automaticallyImplyLeading: false,
                  actions: [],
                  flexibleSpace: Skeletonizer(
                    enabled: productDetailsController.isProductLoading.value,
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 8.0.h, bottom: 10.h),
                          child: InkWell(
                            onTap: () {
                              Get.dialog(
                                PreviewImage(
                                  images: productItem,
                                  activeIndex: 0,
                                ),
                                barrierDismissible: false,
                                useSafeArea: false,
                              );
                            },

                            child: CarouselSlider.builder(
                              carouselController: _carouselController,
                              itemCount:
                              product
                                  .value
                                  .getGalleryImages
                                  ?.length ??
                                  0,
                              itemBuilder:
                                  (BuildContext context,
                                  int itemIndex,
                                  int pageViewIndex,) {
                                return ImageLoader(
                                  borderRadius: BorderRadius.circular(6.r),
                                  boxFit: BoxFit.cover,
                                  height: 300.h,
                                  width: double.infinity,
                                  url: productItem?.first.img != null
                                      ? '${Constant
                                      .imageBaseUrl}${productItem?[currentImageIndex
                                      .value].img}'
                                      : '',
                                );
                              },
                              options: CarouselOptions(
                                height: double.infinity,
                                viewportFraction: 1,
                                initialPage: 0,
                                enableInfiniteScroll: true,
                                autoPlay: false,
                                autoPlayInterval: const Duration(seconds: 6),
                                autoPlayAnimationDuration: const Duration(
                                  seconds: 1,
                                ),
                                scrollDirection: Axis.horizontal,
                                onPageChanged: (index, reason) {
                                  currentImageIndex.value = index;
                                },
                              ),
                            ),
                          ),
                        ),

                        /// — Share Icon
                        Positioned(
                          top: 18.w,
                          right: 10.w,
                          child: Center(
                            child: RoundBtn(
                              bgColor: AppColor.dark.withValues(alpha: .14),
                              isBorder: true,
                              onTap: () async {
                                await DynamicLinkService.createDeepLink(
                                  ads: product.value,
                                  context: context,
                                );
                              },
                              icon: AppImage.icShare,
                            ),
                          ),
                        ),

                        /// — Fav Icon
                        if (_productUserId != _userId)
                          Obx(() {
                            var isFav = productDetailsController.wishListId
                                .contains(productId.toString());
                            return Positioned(
                              top: 18.w,
                              right: 56.w,
                              child: Center(
                                child: RoundBtn(
                                  bgColor: AppColor.dark.withValues(alpha: .14),
                                  isBorder: true,
                                  icon: isFav
                                      ? AppImage.icHeartFill
                                      : AppImage.icHeart,
                                  onTap: () {
                                    if (!_isLoggedIn) {
                                      FadeScreenTransition(
                                        routeName: Routes.authRoute,
                                      ).navigate();
                                      return;
                                    } else if (isFav) {
                                      productDetailsController.deleteWishList(
                                        productId: productId,
                                      );
                                    } else {
                                      productDetailsController.addToWishList(
                                        productId: productId,
                                      );
                                    }
                                    isFav = productDetailsController.wishListId
                                        .contains(productId.toString());
                                  },
                                ),
                              ),
                            );
                          }),

                        /// — Back Icon
                        Positioned(
                          top: 18.w,
                          left: 10.w,
                          child: Center(
                            child: RoundBtn(
                              bgColor: AppColor.dark.withValues(alpha: .14),
                              isBorder: true,
                              onTap: () {
                                Get.back();
                                // Get.find<NavigationController>().setIndex(0);
                              },
                              icon: AppImage.icBack,
                              icHeight: 14.h,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              SliverToBoxAdapter(
                child: Obx(() {
                  return Skeletonizer(
                    enabled: productDetailsController.isProductLoading.value,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 7.h),

                        Stack(
                          children: [
                            SizedBox(width: 1.sw),
                            Obx(() {
                              final isLoading = productDetailsController
                                  .isProductLoading.value;
                              final galleryImages =
                                  product
                                      .value
                                      .getGalleryImages ??
                                      [];
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.only(left: 16.w),
                                child: Row(
                                  children: List.generate(
                                    isLoading ? 5 : galleryImages.length,
                                        (index) {
                                      final item = isLoading
                                          ? GetGalleryImage()
                                          : galleryImages[index];
                                      return Padding(
                                        padding: EdgeInsets.only(right: 4.w),
                                        child: InkWell(
                                          highlightColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          onTap: () {
                                            _carouselController.jumpToPage(
                                              currentImageIndex.value = index,
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color:
                                                currentImageIndex.value ==
                                                    index
                                                    ? AppColor.buttonColor
                                                    : AppColor.coolGray12,
                                                width: .6,
                                              ),
                                              borderRadius:
                                              BorderRadius.circular(1.2.r),
                                            ),
                                            child: ImageLoader(
                                              url:
                                              "${Constant.imageBaseUrl}${item
                                                  .img}",
                                              height: 57.w,
                                              width: 57.w,
                                              boxFit: BoxFit.cover,
                                              borderRadius:
                                              BorderRadius.circular(1.2.r),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: RoundBackBtn(
                                  onTap: () {
                                    _carouselController.animateToPage(
                                      currentImageIndex.value - 1,
                                    );
                                  },
                                  icon: AppImage.arrowLeft,
                                ),
                              ),
                            ),

                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: RoundBackBtn(
                                  onTap: () {
                                    _carouselController.animateToPage(
                                      currentImageIndex.value + 1,
                                    );
                                  },
                                  icon: AppImage.arrowRight,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 24.h),
                        Obx(() {
                          return Text(
                            product.value.productTitle.toString(),
                            style: sansReg.copyWith(
                              fontSize: 20.sp,
                              color: AppColor.primaryColor,
                              height: 1.4.h,
                            ),
                          );
                        }),

                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            RatingBar(
                              rating: double.parse(
                                product.value.ratingsAvgRating ?? '0',
                              ),
                              size: 20.sp,
                              color: AppColor.goldenYellow2,
                            ),
                            SizedBox(width: 8.w),
                            Obx(() {
                              return Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: (product.value.ratingsAvgRating ??
                                          0).toString(),
                                      style: sansSemiBold.copyWith(
                                        fontSize: 14.sp,
                                        color: AppColor.primaryColor,
                                        height: 1.42.h,
                                      ),
                                    ),
                                    TextSpan(
                                      text: AppText.starRating,
                                      style: sansSemiBold.copyWith(
                                        fontSize: 14.sp,
                                        color: AppColor.primaryColor,
                                        height: 1.42.h,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            SizedBox(width: 6.w),
                            Obx(() {
                              return Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '(${product.value.ratingsCount})',
                                      style: sansReg.copyWith(
                                        fontSize: 14.sp,
                                        color: AppColor.coolGray14,
                                        height: 1.42.h,
                                      ),
                                    ),
                                    TextSpan(
                                      text: AppText.userFeedback,
                                      style: sansReg.copyWith(
                                        fontSize: 14.sp,
                                        color: AppColor.coolGray14,
                                        height: 1.42.h,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),

                        SizedBox(height: 24.h),
                        Obx(() {
                          var discountedPrice = product
                              .value
                              .discountedPrice
                              .toString();
                          var price = product
                              .value
                              .price
                              .toString();
                          int discountPercent = calculateDiscountPercent(
                            discountedPrice: discountedPrice,
                            originalPrice: price,
                          );

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "\$${formatPriceHelper(discountedPrice)}",
                                style: sansSemiBold.copyWith(
                                  fontSize: 24.sp,
                                  color: AppColor.buttonColor,
                                  height: 1.33.h,
                                ),
                              ),

                              SizedBox(width: 4.w),
                              Text(
                                "\$${formatPriceHelper(price)}",
                                style: sansReg.copyWith(
                                  fontSize: 18.sp,
                                  color: AppColor.coolGray1,
                                  height: 1.33.h,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: AppColor.coolGray1,
                                ),
                              ),

                              SizedBox(width: 12.w),
                              if (discountPercent > 0)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 5.h,
                                  ),
                                  color: AppColor.goldenYellow3,
                                  child: Text(
                                    "$discountPercent% OFF",
                                    style: sansSemiBold.copyWith(
                                      fontSize: 14.sp,
                                      height: 1.42.h,
                                      color: AppColor.primaryColor,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }),

                        SizedBox(height: 32.h),
                        Obx(() {
                          final sku = product.value.sku ?? '';
                          return DetailRow(
                            label: "Sku",
                            value: sku.isEmpty ? '0' : sku.toString(),
                            textStyle: sansReg.copyWith(
                              fontSize: 14.sp,
                              height: 1.42.h,
                              color: AppColor.coolGray14,
                            ),
                          );
                        }),

                        Obx(() {
                          final stock = product.value.stock ?? '';
                          final stockList = product.value.stocks ?? [];
                          return DetailRow(
                            label: "Status",
                            value: (stock.isEmpty && stockList.isEmpty)
                                ? 'Stock Out'
                                : 'In Stock',
                            txtColor: AppColor.deepGreen1,
                          );
                        }),

                        Obx(() {
                          return DetailRow(
                            label: "Brand",
                            value: product.value.getBrand?.brandName
                                .toString() ?? 'N/A',
                          );
                        }),

                        Obx(() {
                          return DetailRow(
                            label: "Category",
                            value: product.value.getCategory?.categoryName
                                .toString() ?? '',
                          );
                        }),

                        /// multiple color available
                        Obx(() {
                          final isEmpty = colorsSelectedList;
                          return (isEmpty.isEmpty)
                              ? SizedBox.shrink()
                              : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 32.h),
                              TitleText(text: AppText.color),
                              SizedBox(height: 8.h),
                              SizedBox(
                                height: 44.h,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: colorsSelectedList
                                      .length,
                                  itemBuilder: (context, index) {
                                    final item = colorsSelectedList[index];
                                    final rawHex = item.color ?? "";
                                    final cleanHex = rawHex
                                        .replaceAll("#", "")
                                        .trim();

                                    return InkWell(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () {
                                        selectedColorIndex.value =
                                            index;
                                        selectedColorId
                                            .value =
                                            colorsSelectedList[index]
                                                .id ??
                                                0;
                                      },
                                      child: Obx(() {
                                        return Container(
                                          margin: EdgeInsets.only(
                                            right: 12.w,
                                          ),
                                          height: 44.h,
                                          width: 44.h,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: selectedColorIndex.value ==
                                                  index
                                                  ? AppColor.coolGray12
                                                  : Colors.transparent,
                                              width: 2.sp,
                                            ),
                                          ),
                                          child: Container(
                                            margin: EdgeInsets.all(6.sp),
                                            decoration: BoxDecoration(
                                              color: Color(
                                                int.parse(
                                                  "0xFF$cleanHex",
                                                ),
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        );
                                      }),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }),

                        /// Size
                        Obx(() {
                          final isEmpty = product.value.sizes;
                          return (isEmpty == null || isEmpty.isEmpty)
                              ? SizedBox.shrink()
                              : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 16.h),
                              TitleText(text: AppText.sizeText),
                              SizedBox(height: 8.h),
                              CustomDropDawnBtn(
                                items: sizeSelectedList.value,
                                onChange: (int? value, int index) {
                                  selectedSizeId
                                      .value =
                                      productDetailsController
                                          .product
                                          .value
                                          .sizes?[index]
                                          .id ??
                                          0;
                                },
                                title: 'Select Size',
                                btnHeight: 48.h,
                                isIndexValue: true,
                              ),
                            ],
                          );
                        }),

                        /// variant
                        Obx(() {
                          final isEmpty = product.value.variants;
                          return (isEmpty == null || isEmpty.isEmpty)
                              ? SizedBox.shrink()
                              : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 16.h),
                              TitleText(text: AppText.variant),
                              SizedBox(height: 8.h),
                              CustomDropDawnBtn(
                                items: variantSelectedList.value,
                                onChange: (int? value, int index) {
                                  selectedVariantId.value =
                                      product
                                          .value
                                          .variants?[index]
                                          .id ??
                                          0;
                                },
                                title: 'Select Variant',
                                btnHeight: 48.h,
                                isIndexValue: true,
                              ),
                            ],
                          );
                        }),

                        SizedBox(height: 16.h),
                        TitleText(text: AppText.quantity),
                        SizedBox(height: 8.h),
                        CustomDropDawnBtn(
                          items: productDetailsController.quantitySelectedList,
                          onChange: (int? value, int index) {
                            selectedQuantity.value =
                                int.parse(
                                  productDetailsController.quantityList[index]
                                      .toString(),
                                );
                          },
                          title: 'Select Quantity',
                          btnHeight: 48.h,
                          isIndexValue: true,
                        ),

                        if (_productUserId != _userId)SizedBox(height: 32.h),
                        if (_productUserId != _userId)
                          Row(
                            children: [
                              Expanded(
                                child: Obx(() {
                                  return CustomButton(
                                    marginLeft: 0,
                                    marginRight: 8.w,
                                    color: AppColor.leafGreen4,
                                    text: AppText.chat.toUpperCase(),
                                    textStyle: sansMedium.copyWith(
                                      fontSize: 16.sp,
                                      color: Colors.white,
                                      letterSpacing: 1.2.w,
                                    ),
                                    trailing: SvgPicture.asset(
                                      AppImage.icChatTwo,
                                      height: 20.h,
                                    ),
                                    textIconWidth: 12.w,
                                    isLoading: Get
                                        .find<MessageController>()
                                        .isLoading
                                        .value,
                                    onPressed: () {
                                      if (_isLoggedIn) {
                                        Get.find<MessageController>()
                                            .createMsgThread(
                                          productId: productId,
                                          senderId: _userId,
                                          receiverId: _productUserId,
                                        );
                                      } else {
                                        FadeScreenTransition(
                                          routeName: Routes.authRoute,
                                        ).navigate();
                                      }
                                    },
                                  );
                                }),
                              ),
                              Expanded(
                                child: CustomButton(
                                  marginRight: 0,
                                  marginLeft: 8.w,
                                  color: AppColor.amberOrange10,
                                  text: AppText.report.toUpperCase(),
                                  textStyle: sansMedium.copyWith(
                                    fontSize: 16.sp,
                                    color: Colors.white,
                                    letterSpacing: 1.2.w,
                                  ),
                                  trailing: SvgPicture.asset(
                                    AppImage.icReport,
                                    height: 20.h,
                                  ),
                                  textIconWidth: 12.w,
                                  onPressed: () {
                                    if (_isLoggedIn) {
                                      Get.dialog(
                                        barrierDismissible: false,
                                        ReportPropertyDialog(
                                          propertyId: productId,
                                        ),
                                      );
                                    } else {
                                      FadeScreenTransition(
                                        routeName: Routes.authRoute,
                                      ).navigate();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),

                        if (_productUserId != _userId)SizedBox(height: 16.h),
                        if (_productUserId != _userId)
                          Obx(() {
                            final loading = productDetailsController
                                .isAddToCardLoading
                                .value;
                            return CustomButton(
                              marginLeft: 0,
                              marginRight: 0,
                              text: AppText.addToCard.toUpperCase(),
                              textStyle: sansBold.copyWith(
                                fontSize: 16.sp,
                                color: Colors.white,
                                letterSpacing: 1.2.w,
                              ),
                              isLoading: loading,
                              trailing: SvgPicture.asset(
                                AppImage.icCard,
                                height: 24.h,
                              ),
                              textIconWidth: 12.w,
                              onPressed: () {
                                if (_isLoggedIn) {
                                  onButtonClick(
                                    type: 'cart',
                                  );
                                } else {
                                  FadeScreenTransition(
                                    routeName: Routes.authRoute,
                                  ).navigate();
                                }
                              },
                            );
                          }),

                        if (_productUserId != _userId)SizedBox(height: 16.h),
                        if (_productUserId != _userId)
                          CustomButton(
                            marginLeft: 0,
                            marginRight: 0,
                            borderWidth: 1.5.sp,
                            borderColor: AppColor.buttonColor.withValues(
                              alpha: .50,
                            ),
                            color: AppColor.buttonColor.withValues(alpha: .09),
                            text: AppText.buyNow.toUpperCase(),
                            textStyle: sansBold.copyWith(
                              fontSize: 16.sp,
                              color: AppColor.buttonColor,
                              letterSpacing: 1.2.w,
                            ),
                            onPressed: () {
                              if (_isLoggedIn) {
                                onButtonClick();
                              } else {
                                FadeScreenTransition(
                                  routeName: Routes.authRoute,
                                ).navigate();
                              }
                            },
                          ),

                        SizedBox(height: 40.h),
                        DescriptionSection(
                          widget1: Container(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              product
                                  .value
                                  .productDescription ??
                                  '',
                              style: sansReg.copyWith(
                                fontSize: 14.sp,
                                color: AppColor.coolGray14,
                                height: 1.4.h,
                              ),
                            ),
                          ),
                          isBottomSide: false,
                          titleText: AppText.description,
                        ),

                        Obx(() {
                          final raw = product.value.additionalInfo
                              ?.additionalInfo;
                          final isEmpty = raw == null || raw == "\"[]\"" ||
                              raw == "[]";
                          return isEmpty
                              ? SizedBox.shrink()
                              : DescriptionSection(
                            rawJsonString:
                            product
                                .value
                                .additionalInfo
                                ?.specification ??
                                '',
                            titleText: AppText.specification,
                            isBottomSide: false,
                          );
                        }),

                        Obx(() {
                          final raw = product.value.additionalInfo?.specification;
                          final isEmpty = raw == null || raw == "\"[]\"" || raw == "[]";
                          return isEmpty
                              ? SizedBox.shrink()
                              :DescriptionSection(
                            rawJsonString:
                            product
                                .value
                                .additionalInfo
                                ?.additionalInfo ??
                                '',
                            titleText: AppText.additionalInfo,
                            isBottomSide: false,
                          );
                        }),

                        DescriptionSection(
                          widget1: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if ((product
                                  .value
                                  .ratings
                                  ?.isNotEmpty ??
                                  false))
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    (product.value.ratings!.first.user
                                        ?.userImg ==
                                        null)
                                        ? ClipOval(
                                      child: Image.asset(
                                        AppImage.icDefaultDp,
                                        height: 40.h,
                                      ),
                                    )
                                        : ImageLoader(
                                      borderRadius: BorderRadius.circular(
                                        30.r,
                                      ),
                                      url:
                                      '${Constant.bannersUrl}${product.value
                                          .ratings!.first.user?.userImg}',
                                      height: 40.h,
                                    ),

                                    SizedBox(width: 8.w),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            RatingBar(
                                              rating: double.parse(
                                                product
                                                    .value
                                                    .ratings!
                                                    .first
                                                    .rating
                                                    .toString(),
                                              ),
                                              size: 16.sp,
                                              color: Colors.amber,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              "(${product.value.ratings!.first
                                                  .rating})",
                                              style: sansReg.copyWith(
                                                fontSize: 12.sp,
                                                height: 1.33.h,
                                                color: AppColor.coolGray1,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4.h),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 4.w,
                                          ),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            productDetailsController
                                                .product
                                                .value
                                                .ratings!
                                                .first
                                                .user
                                                ?.name ??
                                                '',
                                            style: sansSemiBold.copyWith(
                                              fontSize: 14.sp,
                                              color: AppColor.primaryColor,
                                              height: 1.4.h,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 4.w,
                                          ),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            productDetailsController
                                                .product
                                                .value
                                                .ratings!
                                                .first
                                                .message ??
                                                '',
                                            style: sansReg.copyWith(
                                              fontSize: 14.sp,
                                              color: AppColor.coolGray14,
                                              height: 1.4.h,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              else
                                Text(
                                  "No reviews yet",
                                  style: sansReg.copyWith(
                                    fontSize: 14.sp,
                                    color: AppColor.coolGray10,
                                    height: 1.4.h,
                                  ),
                                ),
                            ],
                          ),
                          titleText: AppText.review,
                        ),

                        /// Top Rated
                        Obx(() {
                          final isLoading =
                              productDetailsController.isTopRatedLoading.value;
                          final isEmpty =
                              productDetailsController.topRatedList.isEmpty;

                          if (!isLoading && isEmpty) {
                            return SizedBox.shrink();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 40.h),
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
                                  paddingRightSeeAll: 0,
                                  title: AppText.topRated,
                                  titleStyle: sansSemiBold.copyWith(
                                    fontSize: 20.sp,
                                    height: 1.3.h,
                                    color: AppColor.primaryColor,
                                    letterSpacing: .25,
                                  ),
                                  endTitle: AppText.seeAll,
                                  onTap: () {
                                    FadeScreenTransition(
                                      routeName: Routes.postListRoute,
                                      arguments: {
                                        'type': 'TopRated',
                                        'categoryName': 'Top Rated',
                                      },
                                    ).navigate();
                                  },
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
                                  child: Row(
                                    children: List.generate(
                                      isLoading
                                          ? 5
                                          : productDetailsController
                                          .topRatedList
                                          .length,
                                          (index) {
                                        final item = isLoading
                                            ? ProductsItem()
                                            : productDetailsController
                                            .topRatedList[index];
                                        return ProductsCard(
                                          item: item,
                                          isLoading: isLoading,
                                        );
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
                          final isLoading = productDetailsController
                              .isNewArrivalsLoading
                              .value;
                          final isEmpty =
                              productDetailsController.newArrivalsList.isEmpty;

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
                                  paddingRightSeeAll: 0,
                                  title: AppText.newArrivals,
                                  titleStyle: sansSemiBold.copyWith(
                                    fontSize: 20.sp,
                                    height: 1.3.h,
                                    color: AppColor.primaryColor,
                                    letterSpacing: .25,
                                  ),
                                  endTitle: AppText.seeAll,
                                  onTap: () {
                                    FadeScreenTransition(
                                      routeName: Routes.postListRoute,
                                      arguments: {
                                        'type': 'New',
                                        'categoryName': 'New Arrivals',
                                      },
                                    ).navigate();
                                  },
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
                                  child: Row(
                                    children: List.generate(
                                      isLoading
                                          ? 5
                                          : productDetailsController
                                          .newArrivalsList
                                          .length,
                                          (index) {
                                        final item = isLoading
                                            ? ProductsItem()
                                            : productDetailsController
                                            .newArrivalsList[index];
                                        return ProductsCard(
                                          item: item,
                                          isLoading: isLoading,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),

                        SizedBox(height: 50.h),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final String? valueColor;
  final TextStyle? textStyle;
  final Color? txtColor;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.textStyle,
    this.txtColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: sansReg.copyWith(
                fontSize: 14.sp,
                height: 1.42.h,
                color: AppColor.coolGray14,
              ),
            ),
          ),
          SizedBox(width: 16.0.w),
          Text(
            ':',
            style: sansReg.copyWith(
              fontSize: 14.sp,
              height: 1.42.h,
              color: AppColor.coolGray14,
            ),
          ),
          SizedBox(width: 16.0.w),
          Expanded(
            child: Text(
              value,
              style:
              textStyle ??
                  sansSemiBold.copyWith(
                    fontSize: 14.sp,
                    height: 1.42.h,
                    color: (value == 'Stock Out')
                        ? AppColor.amberOrange
                        : (txtColor ?? AppColor.primaryColor),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class TitleText extends StatelessWidget {
  final String text;

  const TitleText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: sansReg.copyWith(
        fontSize: 14.sp,
        height: 1.42.h,
        color: AppColor.primaryColor,
      ),
    );
  }
}

int calculateDiscountPercent({String? originalPrice, String? discountedPrice}) {
  if (originalPrice == null) return 0;

  double? original = double.tryParse(originalPrice);
  double? discount = discountedPrice != null
      ? double.tryParse(discountedPrice)
      : null;

  if (original == null || original <= 0) {
    return 0;
  }

  if (discount == null) {
    return 0;
  }

  double percent = ((original - discount) / original) * 100;

  if (percent < 0) {
    return 0;
  }

  return percent.round();
}

class DescriptionSection extends StatelessWidget {
  final String? rawJsonString;
  final Widget? widget1;
  final String titleText;
  final bool isBottomSide;

  const DescriptionSection({
    super.key,
    this.rawJsonString,
    this.isBottomSide = true,
    required this.titleText,
    this.widget1,
  });

  List<Map<String, dynamic>> parseJson(String raw) {
    if (raw.isEmpty) return [];
    String jsonString = jsonDecode(raw);
    return List<Map<String, dynamic>>.from(jsonDecode(jsonString));
  }

  @override
  Widget build(BuildContext context) {
    final features = rawJsonString != null ? parseJson(rawJsonString!) : [];

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColor.coolGray12),
          bottom: BorderSide(
            color: isBottomSide ? AppColor.coolGray12 : Colors.transparent,
          ),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Text(
            titleText.toUpperCase(),
            style: sansSemiBold.copyWith(
              fontSize: 14.sp,
              color: AppColor.primaryColor,
              height: 1.4.h,
            ),
          ),
          iconColor: AppColor.primaryColor,
          collapsedIconColor: AppColor.primaryColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.transparent),
          ),
          tilePadding: EdgeInsets.symmetric(horizontal: 4.w),
          childrenPadding: EdgeInsets.symmetric(horizontal: 4.w),
          children: [
            if (widget1 != null) widget1!,
            if (widget1 == null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: features.map((feature) {
                  final key = feature.keys.first;
                  final value = feature[key];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "• ",
                          style: sansMedium.copyWith(
                            fontSize: 14.sp,
                            color: AppColor.primaryColor,
                            height: 1.4.h,
                          ),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: "$key: ",
                              style: sansMedium.copyWith(
                                fontSize: 14.sp,
                                color: AppColor.primaryColor,
                                height: 1.4.h,
                              ),
                              children: [
                                TextSpan(
                                  text: value,
                                  style: sansReg.copyWith(
                                    fontSize: 14.sp,
                                    color: AppColor.coolGray14,
                                    height: 1.4.h,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
