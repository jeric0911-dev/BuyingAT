import 'package:classified/model/user_data_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../service/api/api_client.dart';
import '../../service/api/api_retry_manager.dart';
import '../../utils/_constant.dart';
import '../../utils/session_manager.dart';

class UserDataController extends GetxController{
  ApiClient apiClient;
  UserDataController({required this.apiClient});

  // @override
  // void onInit() {
  //   super.onInit();
  //   isLoggedIn = SessionManager.getValue(kIsLOGIN, value: false);
  //   if (isLoggedIn) {
  //     Future.delayed(Duration(milliseconds: 300), () {
  //       fetchUserData();
  //     });
  //   }
  //
  // }


  var isUserDataLoading = false.obs;
  var userData = UserData().obs;
  var totalItems = 0.obs;
  late dynamic isLoggedIn;


  Future<void> fetchUserData({bool isReload = false}) async {
    if (isReload) {
      userData.value = UserData();
    }
    isUserDataLoading.value = true;
    try {
      http.Response? response= await apiClient.getData(Constant.getUserUrl);
      if (response.statusCode == 200) {
        UserdataModel userdataModel = userdataModelFromJson(response.body);
        userData.value = userdataModel.data ?? UserData();
        SessionManager.setValue(kUserPackage, userdataModel.data?.userPackage?.packageName);
        SessionManager.setValue(kPackageId, userdataModel.data?.userPackage?.packageId);
        SessionManager.setValue(kUserName, userdataModel.data?.userName);
        SessionManager.setValue(kUserPhone, userdataModel.data?.phone);
        SessionManager.setValue(kUserEmail, userdataModel.data?.email);
        SessionManager.setValue(kUserId, userdataModel.data?.id);
        SessionManager.setValue(kUserImage, userdataModel.data?.profileImg);
        SessionManager.setValue(kPackageEndDate, userdataModel.data?.userPackage?.packageEndDate?.toIso8601String() ?? '');
      }
    } catch (_) {
      apiRetryManager.addRequest(() {fetchUserData();});
    } finally {
      isUserDataLoading.value = false;
    }
  }



}
