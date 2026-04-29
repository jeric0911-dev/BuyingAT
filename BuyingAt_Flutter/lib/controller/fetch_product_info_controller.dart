import 'package:classified/controller/add_products_controller.dart';
import 'package:classified/controller/filter_search_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../helper/drop_down_helper.dart';
import '../model/shop_with_category_model.dart';
import '../service/api/api_client.dart';
import '../service/api/api_retry_manager.dart';
import '../utils/_constant.dart';
import '../widget/custom_dropdown_widget.dart';

class FetchProductInfoController extends GetxController {
  ApiClient apiClient;

  FetchProductInfoController({required this.apiClient});

  late AddProductsController addProductsController;
  @override
  void onInit() {
    super.onInit();
    fetchCategory(isReload: true);
    fetchBrand(isReload: true);
    addProductsController = Get.find<AddProductsController>();
  }

  ///  fetch Category

  var categoryList = <ShopCategoryItem>[].obs;
  var categorySelectedTypeList = <DropdownItem<int>>[].obs;
  var isLoadingCategory = true.obs;

  Future<void> fetchCategory({bool isReload = false}) async {
    if (isReload) {
      categoryList.clear();
    }

    try {
      http.Response? response = await apiClient.getData(Constant.categoriesUrl,);
      if (response.statusCode == 200) {
        ShopWithCategoryModel shopWithCategoryModel = shopWithCategoryModelFromJson(response.body);
        categoryList.value = shopWithCategoryModel.data ?? [];
        categorySelectedTypeList.value = generateDropdownItems<ShopCategoryItem>(
          categoryList,
              (category) => category.categoryName,
              (category) => category.id,
        );
      }
    } catch (_) {
      apiRetryManager.addRequest(() {});
    } finally {
      isLoadingCategory.value = false;
    }
  }

  /// Filter Category Name based on selected CategoryId
  void filterCategoryByCategoryId(int categoryId, {String? route}) {
    final match = categoryList.firstWhere(
          (element) => element.id == categoryId,
      orElse: () => ShopCategoryItem(id: 0, categoryName: ''),
    );
    if(route == 'drawerScreen'){
      Get.find<FilterController>().categoryName.value = match.categoryName!;
    }
    else{
      addProductsController.categoryName.value = match.categoryName!;
    }

  }



  /// Filter sub category based on selected category
  var subCategorySelectedTypeList = <DropdownItem<int>>[].obs;
  var subCategoriesList = <SubCategory>[].obs;
  void filterSubCategoryByCategory(int categoryId) {
    final matchedCategory = categoryList.firstWhere(
          (product) => product.id == categoryId,
      orElse: () => ShopCategoryItem(id: 0, categoryName: '', subCategories: []),
    );
    subCategoriesList.value = matchedCategory.subCategories ?? [];
    subCategorySelectedTypeList.value = generateDropdownItems<SubCategory>(
      subCategoriesList,
          (subCat) => subCat.subCategoryName,
          (subCat) => subCat.id,
    );
    // if (subCategoriesList.isNotEmpty) {
    //   addProductsController.subCategoryName.value = subCategoriesList.first.subCategoryName ?? '';
    // } else {
    //   addProductsController.subCategoryName.value = '';
    // }

      addProductsController.subCategoryName.value = '';
      addProductsController.subCategoryId.value = 0;


  }


  /// Filter Sub Category Name based on selected Sub CategoryId
  void filterSubCategoryByCategoryId(int subCategoryId, {String? route}) {
    final match = subCategoriesList.firstWhere(
          (element) => element.id == subCategoryId,
      orElse: () => SubCategory(id: 0, subCategoryName: ''),
    );
    if(route == 'drawerScreen'){
      Get.find<FilterController>().subCategoryName.value = match.subCategoryName!;
    }else{
      addProductsController.subCategoryName.value = match.subCategoryName!;
    }

  }


  /// fetch Brands
  var brandList = <ShopCategoryItem>[].obs;
  var selectedBrandList = <DropdownItem<int>>[].obs;
  var isLoadingBrand = true.obs;

  Future<void> fetchBrand({bool isReload = false}) async {
    if (isReload) {
      brandList.clear();
    }

    try {
      http.Response? response = await apiClient.getData(Constant.brandUrl,);
      if (response.statusCode == 200) {

        ShopWithCategoryModel shopWithCategoryModel = shopWithCategoryModelFromJson(response.body);


        brandList.value = shopWithCategoryModel.data ?? [];


        selectedBrandList.value = generateDropdownItems<ShopCategoryItem>(
          brandList,
              (category) => category.brandName,
              (category) => category.id,
        );

      }
    } catch (_) {
      apiRetryManager.addRequest(() {fetchBrand();});
    } finally {
      isLoadingBrand.value = false;
    }
  }






}



