import 'dart:io';
import 'package:classified/utils/app_text.dart';
import 'package:classified/widget/custom_snackbar_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../service/api/api_client.dart';
import '../model/shop_with_category_model.dart';
import '../service/api/api_retry_manager.dart';
import '../utils/_constant.dart';

class CreateShopController extends GetxController{
  ApiClient apiClient;
  CreateShopController({required this.apiClient});


  @override
  void onInit() {
    super.onInit();
    setupListeners();


  }



  ///   Create Shop`

  final shopName = TextEditingController();
  final description = TextEditingController();
  var shopBanner= ''.obs;


  final FocusNode fShopName = FocusNode();
  final FocusNode fDescription = FocusNode();


  // pick  image
  final Rx<File?> bannerImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();
  Future<void> pickBannerImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      bannerImage.value = File(image.path);
    }
  }

  void removeImage(int index) {
    bannerImage.value = null;
  }



  void setupListeners() {
    shopName.addListener(validateForm);
    description.addListener(validateForm);

  }

  void validateForm() {
    isFormValid.value = description.text.isNotEmpty &&
        shopName.text.isNotEmpty ;
  }

  var isCreateShopLoading = false.obs;
  var isFormValid = false.obs;
/// Create Shop and Update Shop
  Future<void> createShop({bool isReload = false}) async {
    if (isReload) {}
    isCreateShopLoading.value = true;
    List<MultipartBody> multipartFiles = [];
    multipartFiles.clear();
    if (bannerImage.value != null) {
      multipartFiles.add(MultipartBody('banner', bannerImage.value));
    }
      var body = {
      'name': shopName.text.trim(),
      'description': description.text.trim(),
    };
    try {

      http.Response response =   isShopAvailable.value? await apiClient.postMultipartData(Constant.shopUpdateUrl,body,multipartFiles) : await apiClient.postMultipartData(Constant.shopUrl,body,multipartFiles);

      if (response.statusCode == 200) {
        showCustomSnackBar( isShopAvailable.value?AppText.shopUpdatedSuccessfully : AppText.shopCreatedSuccessfully ,isError: false);
      }


    } catch (e) {
      apiRetryManager.addRequest(() {createShop();});
    } finally {
      isCreateShopLoading.value = false;
    }
  }

/// fetch Shop Data

  var shopDataList = <ShopCategoryItem>[].obs;
  var isShopDataLoading = false.obs;
  var isShopAvailable = false.obs;

  Future<void> fetchShopData({bool isReload = false}) async {
    if (isReload) {
      shopDataList.clear();
    }
    isShopDataLoading.value = true ;
    try {
      http.Response? response = await apiClient.getData(Constant.shopUrl);

      if (response.statusCode == 200) {
        ShopWithCategoryModel shopWithCategoryModel = shopWithCategoryModelFromJson(response.body);
        shopDataList.value = shopWithCategoryModel.data ?? [];
        isShopAvailable.value = true;
      }
    } catch (_) {
      apiRetryManager.addRequest(() {});
    } finally {
      isShopDataLoading.value = false;

    }
  }
}