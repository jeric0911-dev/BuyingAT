import 'dart:convert';
import 'package:classified/controller/transection_controller.dart';
import 'package:classified/controller/user_data_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../service/api/api_client.dart';
import '../../service/api/api_retry_manager.dart';
import '../../utils/_constant.dart';
import '../../utils/session_manager.dart';
import '../../widget/custom_dropdown_widget.dart';
import '../model/payment_gateway_model.dart';
import '../view/wallet_and_recharge/payment_web_view.dart';
import '../widget/custom_snackbar_widget.dart';

class RechargeController extends GetxController{
  ApiClient apiClient;
  RechargeController({required this.apiClient});

TextEditingController amount = TextEditingController();
TextEditingController phoneNumber = TextEditingController();

  final FocusNode fAmount = FocusNode();
  final FocusNode fPhone = FocusNode();

final FocusNode fAmountNode = FocusNode();
var currencyName = ''.obs;
var gatewayName = ''.obs;
var transactionId = ''.obs;
var razorpayOrderId = ''.obs;
var razorpayKey = ''.obs;
var isLoading = false.obs;


late String name;
late String email;
late String phone;
late dynamic userId;
 late Razorpay razorpay;

@override
  void onInit() {
    super.onInit();
    name = SessionManager.getValue(kUserName) ?? '';
    email = SessionManager.getValue(kUserEmail) ?? '';
    phone = SessionManager.getValue(kUserPhone) ?? '';
    userId = SessionManager.getValue(kUserId) ?? '';
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }


  ///  fetch all payment gateways
  var isGatewayLoading = true.obs;
  var allGatewayList = <GatewayData>[].obs;
  var paymentGatewayList = <DropdownItem<int>>[].obs;
  var paymentCurrencyList = <DropdownItem<int>>[].obs;
  Future<void> gateway({bool isReload = false}) async {
    if (isReload) {
    }
    try {
      http.Response? response= await apiClient.getData(Constant.gatewayUrl);
      if (response.statusCode == 200) {
        PaymentGatewayModel paymentGatewayModel = paymentGatewayModelFromJson(response.body);
        allGatewayList.value = paymentGatewayModel.data ?? [];
        paymentGatewayList.value = generateDropdownItems<GatewayData>(
          allGatewayList,
              (category) => category.gatewayName,
              (category) => category.id,
        );

      }
    } catch (_) {
      apiRetryManager.addRequest(() {gateway();});
    } finally {
      isGatewayLoading.value = false;
    }
  }

  /// filter currency by gateway
  void filterCurrencyByGateway(int gatewayId) {
    final gateway = allGatewayList.firstWhere((g) => g.id == gatewayId);
    final Map<String, dynamic> currencyMap = jsonDecode(gateway.supportedCurrencies ?? '{}');
    final List<String> currencyKeys = currencyMap.keys.toList();

    paymentCurrencyList.value = currencyKeys.map((currency) {
      return DropdownItem<int>(
        value: currencyKeys.indexOf(currency),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(currency),
        ),
      );
    }).toList();
  }

  /// get gatewayName name based on gateway id
  void getGatewayNameByGateway(int gatewayId) {
    final gateway = allGatewayList.firstWhere(
          (gateway) => gateway.id == gatewayId,
    );
    gatewayName.value = gateway.gatewayName ?? '';
  }


  List<DropdownItem<int>> generateDropdownItems<T>(
      List<T> list,
      String? Function(T) getName,
      int? Function(T) getId,
      ) {
    return list.map((item) {
      return DropdownItem<int>(
        value: getId(item),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(getName(item) ?? ''),
        ),
      );
    }).toList();
  }

  var isPaymentLoading = false.obs;
  ///  ssl commerce
  Future<void> sslCommerce({bool isReload = false}) async {
    if (isReload) {}
    isPaymentLoading.value = true;
    String amountValue = amount.text;
    String currencyValue = currencyName.value;
    String phoneValue = phoneNumber.text;
    if (amountValue.isEmpty || currencyValue.isEmpty || phoneValue.isEmpty ) {
      showCustomSnackBar("Please fill all required fields.");
      return;
    }
    var body = {
      'amount': amount.text,
      'currency': currencyName.value,
      'customer_name': name,
      'customer_email': email,
      'customer_phone': phoneNumber.text,
    };

    try {
      http.Response? response = await apiClient.postData(
          Constant.sslCommerceUrl,body
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String paymentUrl = responseData['data'];
        Get.to(() => PaymentWebView(url: paymentUrl , title: 'SSL Commerce',));
      }else{
        showCustomSnackBar("Something went wrong. \nPlease try again.");
      }
    } catch (_) {

      apiRetryManager.addRequest(() {});
    } finally {
      isPaymentLoading.value = false;
    }
  }

  /// paypal payment
  Future<void> paypalPayment({bool isReload = false}) async {
    if (isReload) {}
    isPaymentLoading.value = true;
    String amountValue = amount.text;
    String currencyValue = currencyName.value;
    if (amountValue.isEmpty || currencyValue.isEmpty ) {
      showCustomSnackBar("Please fill all required fields.");
      return;
    }
    Map<String, dynamic> body = {
      'amount': amount.text,
      'currency': currencyName.value,
    };

    try {
      http.Response? response = await apiClient.postData(
          Constant.paypalPaymentUrl,body
      );
      if (response.statusCode == 200 ) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String paymentUrl = responseData['redirect_url'];
        Get.to(() => PaymentWebView(url: paymentUrl, title: 'PayPal Payment',));
      }
    } catch (_) {

      apiRetryManager.addRequest(() {paypalPayment();});
    } finally {
      isPaymentLoading.value = false;
    }
  }

  ///  Stripe
  Future<void> stripe({bool isReload = false}) async {
    if (isReload) {}
    isPaymentLoading.value = true;
    String amountValue = amount.text;
    String currencyValue = currencyName.value;
    if (amountValue.isEmpty || currencyValue.isEmpty ) {
      showCustomSnackBar("Please fill all required fields.");
      return;
    }
   var body = {
      'amount': amount.text,
     'currency': currencyName.value,
    };

    try {
      http.Response? response = await apiClient.postData(
          Constant.stripePaymentUrl,body
      );
      if (response.statusCode == 200 ) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String paymentUrl = responseData['redirect_url'];
        Get.to(() => PaymentWebView(url: paymentUrl , title: 'Stripe',),);
      }
    } catch (_) {

      apiRetryManager.addRequest(() {stripe();});
    } finally {
      isPaymentLoading.value = false;
    }
  }




  /// Razorpay
  Future<void> razorpayPayment({bool isReload = false}) async {
    if (isReload) {}
    isPaymentLoading.value = true;
    var body = {
      'amount': amount.text,
      'currency': currencyName.value,
    };
    try {
      http.Response? response = await apiClient.postData(
          Constant.razorpayUrl,body
      );
      if (response.statusCode == 200 || response.statusCode == 201) {

        var jsonResponse = jsonDecode(response.body);
        var orderData = jsonResponse['data'];
        razorpayOrderId .value = orderData['id'];
        var options = {
          'key': orderData['key'],
          'amount': amount.text,
          'name': name,
          'description': 'Order Payment',
          'order_id': orderData['id'],
          'prefill': {
            'contact': phone,
            'email': email,
          },
          // 'external': {
          //   'wallets': ['paytm']
          // }
        };

        razorpay.open(options);


      }else{
        showCustomSnackBar("Something went wrong. \nPlease try again.");
      }
    } catch (_) {

      apiRetryManager.addRequest(() {});
    } finally {
    }
  }
  void _handlePaymentSuccess(PaymentSuccessResponse response) {

    postRazorpayTransaction();
  }

  /// post razorpay transaction
  Future<void> postRazorpayTransaction({bool isReload = false}) async {
    if (isReload) {}
    var body = {
      'amount': amount.text,
      'currency': currencyName.value,
      'order_id': razorpayOrderId.value,

    };
    try {
      http.Response? response = await apiClient.postData(
          Constant.razorpayPayUrl,body
      );
      if (response.statusCode == 200) {

        Get.find<UserDataController>().fetchUserData(isReload: true);
        Get.find<TransectionController>().transactionHistory(isReload: true);
        Get.back();
        showCustomSnackBar("Transaction successful",isError: false);

      }else{
        showCustomSnackBar("Something went wrong. \nPlease try again.");
      }
    } catch (_) {

      apiRetryManager.addRequest(() {});
    } finally {
      isPaymentLoading.value = false;
    }
  }


  void _handlePaymentError(PaymentFailureResponse response) {
  }

  void _handleExternalWallet(ExternalWalletResponse response) {

  }
  @override
  void dispose() {
    razorpay.clear();
    super.dispose();
  }
}