import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../model/more_page_model.dart';
import '../service/api/api_client.dart';
import '../service/api/api_retry_manager.dart';
import '../utils/_constant.dart';

class MorePageController extends GetxController {
  ApiClient apiClient;
  MorePageController({required this.apiClient});
  @override
  void onInit() {
    super.onInit();
    fetchMorePage();
  }

  var isMorePageLoading = false.obs;

  ///  more page data load
  var morePageList = <MorePageData>[].obs;
  Future<void> fetchMorePage({bool isReload = false}) async {
    if (isReload) {
      morePageList.clear();
    }
    isMorePageLoading.value = true;
    try {
      http.Response? response = await apiClient.getData(Constant.morePagesUrl);
      if (response.statusCode == 200) {
        MorePageModel morePageModel = morePageModelFromJson(response.body);
        morePageList.value = morePageModel.data ?? [];
      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        fetchMorePage();
      });
    } finally {
      isMorePageLoading.value = false;
    }
  }
}
