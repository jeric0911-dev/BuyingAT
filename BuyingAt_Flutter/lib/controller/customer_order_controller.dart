
import 'dart:convert';

import 'package:classified/model/customer_order_model.dart';
import 'package:classified/model/order_details_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../service/api/api_client.dart';
import '../service/api/api_retry_manager.dart';
import '../utils/_constant.dart';
import '../widget/custom_snackbar_widget.dart';



class CustomerOrderController extends GetxController{
  ApiClient apiClient;
  CustomerOrderController({required this.apiClient});


  var  pagination = Pagination().obs;
  var isPaginating= false.obs;
  var currentPage = 1.obs;
  var isOrderLoading = true.obs;
  var customerOrderList = <CustomerOrder>[].obs;
  var isUpdatingStatus = false.obs;

  Future<void> fetchCustomerOrder({bool isReload = false, dynamic orderRoute}) async {
    if (isReload) {
       isOrderLoading.value = true;
      customerOrderList.clear();
      currentPage.value = 1;
      isPaginating.value = true;
      pagination.value = Pagination();
    }else{
      isPaginating.value = true;
    }


    try {
      http.Response? response= await apiClient.getData(orderRoute == 'customerOrder'?Constant.customerOrderUrl : Constant.myOrderUrl, query: {"page": currentPage.value.toString()});
      if (response.statusCode == 200) {
        CustomerOrderModel customerOrderModel = customerOrderModelFromJson(response.body);
        //customerOrderList.value = customerOrderModel.data ?? [];

        if (currentPage.value == 1) {
          customerOrderList.value = customerOrderModel.data ?? [];
        } else {
          customerOrderList.addAll(customerOrderModel.data ?? []);
        }
        pagination.value = customerOrderModel.pagination ?? Pagination();
        currentPage.value = (pagination.value.currentPage ?? 0) + 1;
      }
    } catch (_) {

      apiRetryManager.addRequest(() {fetchCustomerOrder(orderRoute: orderRoute,);});
    } finally {
      isOrderLoading.value = false;
      isPaginating.value = false;
    }
  }



  var isOrderDtlLoading = true.obs;
  var orderDetailsData = CustomerOrder().obs;
  Future<void> fetchOrderDetails({bool isReload = false, dynamic oId}) async {

    if (isReload) {
      orderDetailsData.value = CustomerOrder();
    }
    isOrderDtlLoading.value = true;

    try {
      http.Response? response= await apiClient.getData("${Constant.orderDetailsUrl}/$oId" );
      if (response.statusCode == 200) {
        OrderDetailsModel orderDetailsModel = orderDetailsModelFromJson(response.body,);
        orderDetailsData.value = orderDetailsModel.data ?? CustomerOrder();

      }
    } catch (_) {
      apiRetryManager.addRequest(() {fetchOrderDetails();});
    } finally {
      isOrderDtlLoading.value = false;

    }
  }

  /// Update order status (pending, processing, completed, cancelled)
  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    if (isUpdatingStatus.value) return;

    isUpdatingStatus.value = true;
    try {
      final body = {'order_status': status};

      http.Response response = await apiClient.postData(
        "${Constant.updateOrderStatusUrl}/$orderId",
        body,
      );

      final statusCode = response.statusCode;
      final bodyString = response.body;

      if (statusCode == 200 || statusCode == 201) {
        try {
          final json = jsonDecode(bodyString);
          final message =
              json['message']?.toString() ?? 'Status updated successfully';
          showCustomSnackBar(message, isError: false);

          // Refresh order details to reflect latest status/timeline
          await fetchOrderDetails(oId: orderId, isReload: true);
        } catch (e) {
          showCustomSnackBar(
            "Status updated, but failed to refresh details. Please reopen the page.",
          );
        }
      } else {
        try {
          final json = jsonDecode(bodyString);
          final message = json['message']?.toString() ??
              'Failed to update status (Status: $statusCode)';
          showCustomSnackBar(message);
        } catch (_) {
          showCustomSnackBar(
            "Failed to update status (Status: $statusCode)",
          );
        }
      }
    } catch (e) {
      showCustomSnackBar(
        "Failed to update status: ${e.toString()}",
      );
    } finally {
      isUpdatingStatus.value = false;
    }
  }

}