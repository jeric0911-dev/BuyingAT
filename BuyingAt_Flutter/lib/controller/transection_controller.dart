
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../service/api/api_client.dart';
import '../../../service/api/api_retry_manager.dart';
import '../../utils/_constant.dart';
import '../model/transection_model.dart';

class TransectionController extends GetxController{
  ApiClient apiClient;
  TransectionController({required this.apiClient});



  /// Get Transactions
  var isTransactionLoading = false.obs;
  var transactionList = <TransactionsData>[].obs;
  Future<void> transactionHistory({bool isReload = false}) async {
    if (isReload) {
      transactionList.clear();
    }
    isTransactionLoading.value = true;
    try {
      http.Response? response= await apiClient.getData(Constant.getTransactionsUrl);
      if (response.statusCode == 200) {
        TransactionsModel transactionsModel = transactionsModelFromJson(response.body);
        transactionList.value = transactionsModel.data ?? [];

      }
    } catch (_) {
      apiRetryManager.addRequest(() {});
    } finally {
      isTransactionLoading.value = false;
    }
  }




}