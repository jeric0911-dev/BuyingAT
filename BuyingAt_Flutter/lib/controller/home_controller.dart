import 'dart:async';
import 'package:classified/controller/user_data_controller.dart';
import 'package:classified/model/advertises_model.dart';
import 'package:classified/model/cart_product_model.dart';
import 'package:classified/model/shop_with_category_model.dart';
import 'package:get/get.dart';
import '../model/banner_model.dart';
import '../model/product_model.dart';
import '../model/products_model.dart';
import '../service/api/api_client.dart';
import '../service/api/api_retry_manager.dart';
import '../utils/_constant.dart';
import 'package:http/http.dart' as http;
import '../utils/session_manager.dart';

class HomeController extends GetxController {
  ApiClient apiClient;

  HomeController({required this.apiClient});
  late dynamic _isLoggedIn;
  @override
  void onInit() {
    super.onInit();
    _isLoggedIn = SessionManager.getValue(kIsLOGIN, value: false);
    if(_isLoggedIn) Get.find<UserDataController>().fetchUserData(isReload: true);
    fetchSlider();
    fetchCategory();
    fetchBestDeals();
    fetchFeaturedProduct();
    fetchElectronicsAccessories();
    fetchTopRated();
    fetchNewArrivals();
    fetchAdvertises();
    if(_isLoggedIn) fetchCartItem();

  }

  Future<void> refreshData() async {
    fetchSlider(isReload: true);
    fetchCategory(isReload: true);
    fetchBestDeals(isReload: true);
    fetchFeaturedProduct(isReload: true);
    fetchElectronicsAccessories(isReload: true);
    fetchTopRated(isReload: true);
    fetchNewArrivals(isReload: true);
    fetchAdvertises(isReload: true);
    if(_isLoggedIn) fetchCartItem(isReload: true);
    if(_isLoggedIn) Get.find<UserDataController>().fetchUserData(isReload: true);
  }

  ///  fetchSlider
  var isBannerLoading = true.obs;
  var listOfBanner = <BannerItem>[].obs;

  Future<void> fetchSlider({bool isReload = false}) async {
    if (isReload) {
      isBannerLoading.value = true;
      listOfBanner.clear();
    }
    try {
      http.Response? response = await apiClient.getData(Constant.bannersUrl);
      if (response.statusCode == 200) {
        BannerModel bannerModel = bannerModelFromJson(response.body);
        listOfBanner.value = bannerModel.data ?? [];
      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        fetchSlider();
      });
    } finally {
      isBannerLoading.value = false;
    }
  }


  ///  fetchCategory
  var isCategoryLoading = true.obs;
  var categoryList = <ShopCategoryItem>[].obs;

  Future<void> fetchCategory({bool isReload = false}) async {
    if (isReload) {
      isCategoryLoading.value = true;
      categoryList.clear();
    }
    isCategoryLoading.value = true;
    try {
      http.Response? response = await apiClient.getData(Constant.categoriesUrl,);
      if (response.statusCode == 200) {
        ShopWithCategoryModel shopWithCategoryModel = shopWithCategoryModelFromJson(response.body);
        categoryList.value = (shopWithCategoryModel.data)?.take(5).toList() ?? [];
      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        fetchCategory();
      });
    } finally {
      isCategoryLoading.value = false;
    }
  }


  ///  Fetch Best Deals
  var isBestDealsLoading = true.obs;
  var bestDealsList = <ProductsItem>[].obs;

  Future<void> fetchBestDeals({bool isReload = false}) async {
    if (isReload) {
      isBestDealsLoading.value = true;
      bestDealsList.clear();
    }
    isBestDealsLoading.value = true;
    try {
      http.Response? response = await apiClient.getData(Constant.bestDealsUrl,);
      if (response.statusCode == 200) {
         ProductsModel productsModel = productsModelFromJson(response.body);
         bestDealsList.value = (productsModel.data)?.take(5).toList() ?? [];
      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        fetchBestDeals();
      });
    } finally {
      isBestDealsLoading.value = false;
    }
  }


  ///  Fetch Featured Products
  var isFeaturedLoading = true.obs;
  var featuredProductList = <ProductsItem>[].obs;

  Future<void> fetchFeaturedProduct({bool isReload = false}) async {
    if (isReload) {
      isFeaturedLoading.value = true;
      featuredProductList.clear();
    }
    isFeaturedLoading.value = true;
    try {
      http.Response? response = await apiClient.getData(Constant.featuredProductsUrl);
      if (response.statusCode == 200) {
        ProductsModel productsModel = productsModelFromJson(response.body);
        featuredProductList.value = (productsModel.data)?.take(5).toList() ?? [];
      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        fetchFeaturedProduct();
      });
    } finally {
      isFeaturedLoading.value = false;
    }
  }


  ///  Fetch Electronics Accessories
  var isElectronicsAccessoriesLoading = true.obs;
  var electronicsAccessoriesList = <ProductsItem>[].obs;

  Future<void> fetchElectronicsAccessories({bool isReload = false}) async {
    if (isReload) {
      isElectronicsAccessoriesLoading.value = true;
      electronicsAccessoriesList.clear();
    }
    isElectronicsAccessoriesLoading.value = true;
    try {
      http.Response? response = await apiClient.getData(Constant.electronicsAccessoriesUrl);
      if (response.statusCode == 200) {
        ProductsModel productsModel = productsModelFromJson(response.body);
        electronicsAccessoriesList.value = (productsModel.data)?.take(5).toList() ?? [];
      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        fetchElectronicsAccessories();
      });
    } finally {
      isElectronicsAccessoriesLoading.value = false;
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


  ///  Fetch Advertises
  var isAdvertisesLoading = true.obs;
  var advertisesList = <AdvertisesItem>[].obs;
  var  advertisesItem = AdvertisesItem().obs;

  Future<void> fetchAdvertises({bool isReload = false}) async {
    if (isReload) {
      isAdvertisesLoading.value = true;
      advertisesList.clear();
    }
    isAdvertisesLoading.value = true;
    try {
      http.Response? response = await apiClient.getData(Constant.advertiseUrl);
      if (response.statusCode == 200) {
        AdvertisesModel advertisesModel = advertisesModelFromJson(response.body);
        advertisesItem.value = advertisesModel.data ?? AdvertisesItem();
      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        fetchAdvertises();
      });
    } finally {
      isAdvertisesLoading.value = false;
    }
  }


  ///  Fetch cartList

  var cartList = <CartProduct>[].obs;
  var totalProduct = 0.obs;

  Future<void> fetchCartItem({bool isReload = false}) async {
    totalProduct.value =0;
    if (isReload) {
      cartList.clear();
    }

    try {
      http.Response? response = await apiClient.getData(Constant.cartItemsUrl);
      if (response.statusCode == 200) {
        CartProductModel cartProductModel = cartProductModelFromJson(response.body);
        cartList.value = cartProductModel.data ?? [];
         totalProduct.value = cartList.length;
      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        fetchCartItem();
      });
    } finally {}
  }

}
