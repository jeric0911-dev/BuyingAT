import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../model/shop_with_category_model.dart';
import '../service/api/api_client.dart';
import '../service/api/api_retry_manager.dart';
import '../utils/_constant.dart';

class SeeAllController extends GetxController {
  ApiClient apiClient;
  SeeAllController({required this.apiClient});


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
        ShopWithCategoryModel shopWithCategoryModel = shopWithCategoryModelFromJson(
            response.body);
        categoryList.value = shopWithCategoryModel.data ?? [];
      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        fetchCategory();
      });
    } finally {
      isCategoryLoading.value = false;
    }
  }
}