import 'dart:io';

import 'package:classified/controller/home_controller.dart';
import 'package:classified/model/wish_list_model.dart';
import 'package:classified/widget/custom_snackbar_widget.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import '../helper/drop_down_helper.dart';
import '../model/product_model.dart';
import '../model/products_model.dart';
import '../routes/app_routes.dart';
import '../service/api/api_client.dart';
import '../service/api/api_retry_manager.dart';
import '../transition/fade_transition.dart';
import '../utils/_constant.dart';
import '../view/bottom_sheet/buy_now_bottom_sheet.dart';
import '../widget/custom_dropdown_widget.dart';

class ProductDetailsController extends GetxController {
  ApiClient apiClient;

  ProductDetailsController({required this.apiClient});

  @override
  void onInit() {
    super.onInit();
    fetchTopRated();
    fetchNewArrivals();
  }



  var isProductLoading = true.obs;
  var product = ProductsItem().obs;

  var selectedColorIndex = (-1).obs;

  //
  // var selectedSizeId = 0.obs;
  // var selectedVariantId = 0.obs;
  // var selectedColorId = 0.obs;
  // var skuStock = ''.obs;
  // var amount = 0.obs;
  // var selectedQuantity = 1.obs;


  List<Map<dynamic, String>> sizeWithAllList = [];
  

  var colorsSelectedMap = <int, List<ProductColor>>{}.obs;

  Future<ProductsItem> getSingleProduct({bool isReload = false, required productId}) async {
    if (isReload) {}
    isProductLoading.value = true;
    try {
      http.Response? response = await apiClient.getData("${Constant.singleProductUrl}/$productId");
      if (response.statusCode == 200) {
        ProductModel productModel = productModelFromJson(response.body);
        product.value = productModel.data ?? ProductsItem();

        /// added all Gallery images to main image list
        product.value = product.value.copyWith(
          getGalleryImages: [
            ...?product.value.getGalleryImages,
            ...?product.value.colors?.expand((color) {
              return color.images
                  ?.map((img) => GetGalleryImage(
                img: (img as Map<String, dynamic>)['color_image'] as String?,
              )) ??
                  [];
            })
          ],
        );





      //  colorsSelectedMap[productId] = product.value.colors ?? [];

      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        getSingleProduct(productId: productId);
      });
    } finally {
      isProductLoading.value = false;
    }

    return product.value; // 👈 now returning
  }

  // Future<void> getSingleProduct({bool isReload = false, required productId}) async {
  //   if (isReload) {}
  //   isProductLoading.value = true;
  //   try {
  //     http.Response? response = await apiClient.getData("${Constant.singleProductUrl}/$productId");
  //     if (response.statusCode == 200) {
  //       ProductModel productModel = productModelFromJson(response.body);
  //       product.value = productModel.data ?? ProductsItem();
  //
  //
  //       /// added all Gallery images to main image list
  //       product.value = product.value.copyWith(
  //         getGalleryImages: [
  //           ...?product.value.getGalleryImages,
  //           ...?product.value.colors?.expand((color) {
  //             return color.images
  //                 ?.map((img) => GetGalleryImage(
  //               img: (img as Map<String, dynamic>)['color_image'] as String?,
  //             )) ?? [];
  //           })
  //         ],
  //       );
  //
  //
  //       ///  added sizes
  //       if (product.value.sizes?.isNotEmpty ?? false) {
  //         sizeSelectedList.value = generateDropdownItems<ProductSize>(
  //           product.value.sizes!,
  //               (sizeItem) => sizeItem.size,
  //               (sizeItem) => sizeItem.id,
  //         );
  //       }
  //
  //
  //       ///  added variants
  //       if (product.value.variants?.isNotEmpty ?? false) {
  //         variantSelectedList.value = generateDropdownItems<ProductVariant>(
  //           product.value.variants!,
  //               (variantItem) => variantItem.variantName,
  //               (variantItem) => variantItem.id,
  //         );
  //       }
  //
  //       /// added colors
  //       if (product.value.colors?.isNotEmpty ?? false) {
  //         colorsSelectedList.addAll(product.value.colors!,
  //         );
  //       }
  //
  //       /// added product Stock
  //       if (product.value.stocks?.isNotEmpty ?? false) {
  //         productStockList.addAll(product.value.stocks!,);
  //       }
  //
  //
  //     }
  //   } catch (_) {
  //     apiRetryManager.addRequest(() {getSingleProduct(productId: productId);});
  //   } finally {
  //     isProductLoading.value = false;
  //   }
  // }




  List<String> quantityList = List.generate(21, (index) => (index + 1).toString());
  List<DropdownItem<int>> quantitySelectedList = [];

  void quantity({dynamic stock}){
   quantitySelectedList.clear();
   for (
   int index = 0; index < quantityList.length; index++
   ) {
     quantitySelectedList.add(
       DropdownItem<int>(
         value: index,
         child: SizedBox(
           child: Padding(
             padding: EdgeInsets.all(8.0),
             child:  Text(quantityList[index]),
           ),
         ),
       ),
     );
   }

  }




  /// add to cart
   var isAddToCardLoading = false.obs;
  Future<void> addToCart(int productId,int vendorId, String sku, int selectedQuality  ) async {
    isAddToCardLoading.value = true;

    var body = {
      "product_id" : productId,
      "vendor_id" : vendorId,
      "quantity": selectedQuality,
      'sku': sku,
    };

    try {
      http.Response? response = await apiClient.postData(
          Constant.addToCardUrl,body
      );
      if (response.statusCode == 200 ) {
        Get.find<HomeController>().totalProduct.value += 1;
        showCustomSnackBar('Item added to cart',isError: false);
      }
    } catch (_) {
      apiRetryManager.addRequest(() {addToCart(productId,vendorId,sku,selectedQuality);});
    } finally {
      isAddToCardLoading.value = false;
    }
  }


  /// add to cart
  var isBuyLoading = false.obs;
  Future<void> buyProduct({int? productId, int? vendorId, int? quantity,String? deliveryAddress, String? orderNote, dynamic productAmount, dynamic selectedQuantity, dynamic sku } ) async {
    isBuyLoading.value = true;

    //final totalAmount = (selectedQuantity * int.parse(productAmount));
    var body = {
      "delivery_address":deliveryAddress,
      "order_note":orderNote,
      "product_id" : productId,
      "vendor_id" : vendorId,
      "quantity": quantity,
      'sku': sku,
      "amount":productAmount

    };

    try {
      http.Response? response = await apiClient.postData(
          Constant.buyNowUrl,body
      );
      if (response.statusCode == 200 ) {
        Get.back();
        FadeScreenTransition(routeName: Routes.customerOrderRoute,arguments: {'order':'myOrder'}).navigate();
      }
    } catch (_) {
      apiRetryManager.addRequest(() {buyProduct(productId: productId,vendorId: vendorId,quantity: quantity,orderNote: orderNote,deliveryAddress: deliveryAddress, productAmount: productAmount);});
    } finally {
      isBuyLoading.value = false;
    }
  }



  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt;
    }
    return 0;
  }


  /// download photo
  Future<void> downloadImage({String? imagePath}) async {
    PermissionStatus permission;
    if (Platform.isAndroid && (await _getAndroidVersion()) >= 33) {
      permission = await Permission.photos.request();
    } else {
      permission = await Permission.storage.request();
    }
    if (permission.isGranted) {
      String imageUrl = imagePath ??'';
          //'/*${Constant.imageBaseUrl}${adsDetails.value.images?[current.value].imagePath}*/';
      GallerySaver.saveImage(imageUrl, albumName: 'Classified').then((onValue) {
        if (onValue ?? false) {
          showCustomSnackBar('Download Complete ',isError: false);
        } else {
          showCustomSnackBar('Download Failed');
        }
      });
    }
  }



  /// report property
  List<String> subjectList = [
    'Misleading or False Information',
    'Inappropriate Content',
    'Scam or Fraud',
    'Prohibited or Illegal Item',
    'Duplicate Listing',
    'Wrong Category',
    'Counterfeit or Fake Product',
    'Stolen Item',
    'Harassment or Abusive Selle',
    'Other (please specify)',
  ];
  List<String> get subjectTypeList => subjectList;
  List<DropdownItem<int>> subjectSelectedList = [];
  var title =''.obs;

  final TextEditingController description = TextEditingController();
  final FocusNode fDescriptionNode = FocusNode();
  final isReportLoading = false.obs;



  void submitReport(dynamic productId) {
    if (description.text.isNotEmpty && title.isNotEmpty) {
      sendReport(
        productId: productId,
      );
    } else {
      showCustomSnackBar("Please fill in all fields.");
    }
  }
  /// post report property
  Future<void> sendReport({bool isReload = false, required dynamic productId}) async {
    isReportLoading.value = true;
    if (isReload) {}
    var body = {
      'car_id': productId,
      'title': title.value,
      'description':description.text,
    };

    try {
      http.Response? response = await apiClient.postData(
          Constant.sendReportUrl,body
      );

      if (response.statusCode == 201) {
        Get.back();
        showCustomSnackBar("Report submitted successfully.",isError: false);
        title.value = '';
        description.clear();
      }
    } catch (_) {

      apiRetryManager.addRequest(() {});
    } finally {
      isReportLoading.value = false;
    }
  }


  var wishList = <WishlistData>[].obs;
  var wishListId = <String>{}.obs;

  /// wishList
  Future<void> fetchWishList({bool isReload = false}) async {
    if (isReload) {
      wishList.clear();
      wishListId.clear();
    }

    try {
      http.Response? response = await apiClient.getData(Constant.fetchWishListUrl);
      if (response.statusCode == 200) {
        WishListModel wishListModel = wishListModelFromJson(response.body);
        wishList.value = wishListModel.data ?? [];

        for(var item in wishList){
          wishListId.add(item.productId.toString());
        }
        

      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        fetchWishList(isReload: true);
      });
    }
  }

  /// delete wishlist
  Future<void> deleteWishList({bool isReload = false, required dynamic productId}) async {
    wishListId.remove(productId.toString());
    try {
      http.Response? response = await apiClient.deleteData(
          "${Constant.deleteWishListUrl}/$productId",
      );

      if (response.statusCode != 200) {
        wishListId.add(productId.toString());
      }
    } catch (_) {

      apiRetryManager.addRequest(() {deleteWishList(productId: productId);});
    }
  }



  /// add wish list
  Future<void> addToWishList({required dynamic productId}) async {
    wishListId.add(productId.toString());
    wishListId.refresh();
    var body = {
      'product_id': productId,
    };

    try {
      http.Response? response = await apiClient.postData(
          Constant.addToWishListUrl,body
      );


      if (response.statusCode != 200 ) {
        wishListId.remove(productId.toString());
      }
    } catch (_) {

      apiRetryManager.addRequest(() {addToWishList(productId: productId);});
    }
  }


  ///  Fetch Top Rated Products
  var isTopRatedLoading = true.obs;
  var topRatedList = <ProductsItem>[].obs;

  Future<void> fetchTopRated({bool isReload = false}) async {
    if (isReload) {
      isTopRatedLoading.value = true;
      topRatedList.clear();
    }
    isTopRatedLoading.value = true;
    try {
      http.Response? response = await apiClient.getData(Constant.topRatedUrl);
      if (response.statusCode == 200) {
        ProductsModel productsModel = productsModelFromJson(response.body);
        topRatedList.value = (productsModel.data)?.take(5).toList() ?? [];
      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        fetchTopRated();
      });
    } finally {
      isTopRatedLoading.value = false;
    }
  }


  ///  Fetch New Products
  var isNewArrivalsLoading = true.obs;
  var newArrivalsList = <ProductsItem>[].obs;

  Future<void> fetchNewArrivals({bool isReload = false}) async {
    if (isReload) {
      isNewArrivalsLoading.value = true;
      newArrivalsList.clear();
    }
    isNewArrivalsLoading.value = true;
    try {
      http.Response? response = await apiClient.getData(Constant.newArrivalsUrl);
      if (response.statusCode == 200) {
        ProductsModel productsModel = productsModelFromJson(response.body);
        newArrivalsList.value = (productsModel.data)?.take(5).toList() ?? [];
      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        fetchNewArrivals();
      });
    } finally {
      isNewArrivalsLoading.value = false;
    }
  }


}

