import 'dart:convert';

import 'package:classified/model/package_model.dart';
import 'package:classified/utils/session_manager.dart';
import 'package:classified/widget/custom_snackbar_widget.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../routes/app_routes.dart';
import '../service/api/api_client.dart';
import '../service/api/api_retry_manager.dart';
import '../transition/fade_transition.dart';
import '../utils/_constant.dart';

class PremiumController extends GetxController {
  ApiClient apiClient;
  PremiumController({required this.apiClient});
  var isMonthlySelected = true.obs;
  var selectedIndex = 0.obs;
  var packageId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPackages();
  }

  void selectMonthly() {
    isMonthlySelected.value = true;
    selectedIndex.value = 0;
  }

  void selectYearly() {
    isMonthlySelected.value = false;
    selectedIndex.value = 1;
  }

  var packageList = <PackageData>[].obs;
  var isLoadingPackages = true.obs;

  /// Fetch Packages
  Future<void> fetchPackages({bool isReload = false}) async {
    if (isReload) {
      packageList.clear();
    }
    isLoadingPackages.value = true;
    try {
      http.Response? response = await apiClient.getData(Constant.packagesUrl);
      if (response.statusCode == 200) {
        PackageModel packageModel = packageModelFromJson(response.body);
        packageList.value = packageModel.data ?? [];
      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        fetchPackages();
      });
    } finally {
      isLoadingPackages.value = false;
    }
  }

  /// purchase Package
  var isPackageLoading =  false.obs;
  Future<void> purchasePackage() async {
    var body = {"package_id": packageId.value};
    isPackageLoading.value = true;
    try {
      http.Response? response = await apiClient.postData(
        Constant.subscribeUrl,
        body,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final packagesId = data['data']['package_id'];
        SessionManager.setValue(kPackageId, packagesId);
        packageId.value = packagesId;
        Get.back();
        showCustomSnackBar('Packages retrieved successfully', duration: 4, isError: false);
        FadeScreenTransition(routeName: Routes.walletScreenRoute).navigate();

      } else if (response.statusCode == 400) {
        showCustomSnackBar('Insufficient credit balance', duration: 5);
        FadeScreenTransition(routeName: Routes.walletScreenRoute).navigate();
      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        purchasePackage();
      });
    } finally {
      isPackageLoading.value = false;
    }
  }
}
