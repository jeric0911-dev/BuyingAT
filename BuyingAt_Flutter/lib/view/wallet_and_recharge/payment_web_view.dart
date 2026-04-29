import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import '../../controller/transection_controller.dart';
import '../../controller/user_data_controller.dart';
import '../../routes/app_routes.dart';
import '../../service/api/api_client.dart';
import '../../transition/fade_transition.dart';
import '../../utils/_constant.dart';
import '../../utils/session_manager.dart';
import '../../widget/custom_app_bar.dart';
import '../../widget/custom_snackbar_widget.dart';


class PaymentWebView extends StatefulWidget {
  final String url;
  final dynamic title;

  const PaymentWebView({super.key, required this.url, this.title});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  //late TranSectionAndHistoryController tranSectionAndHistoryController;

  // @override
  // void initState() {
  //   super.initState();
  //   _controller = WebViewController()
  //     ..setJavaScriptMode(JavaScriptMode.unrestricted)
  //     ..loadRequest(Uri.parse(widget.url));
  // }
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (NavigationRequest request) {
              Uri uri = Uri.parse(request.url);
              log('Payment redirect URI: $uri');

              // Handle wallet redirect pattern (existing logic)
              if (uri.path.contains("wallet") && uri.queryParameters.containsKey("success")) {
                String success = uri.queryParameters["success"] ?? "false";

                if (success.toLowerCase() == "true") {
                  Get.back();
                  Get.back();
                  Get.find<UserDataController>().fetchUserData(isReload: true);
                  Get.find<TransectionController>().transactionHistory(isReload: true);

                  showCustomSnackBar(
                    'Payment Successful',
                    isError: false,
                    duration: 3,
                  );
                  
                  // Navigate to wallet screen
                  FadeScreenTransition(routeName: Routes.walletScreenRoute).navigate();
                } else {
                  Get.back();
                  showCustomSnackBar(
                    'Payment Failed',
                    isError: true,
                    duration: 3,
                  );
                }

                return NavigationDecision.prevent;
              }

              // Handle Stripe payment success redirect
              // Check for payment-success in path or stripe in path with transaction_id
              if ((uri.path.contains("payment-success") || 
                   uri.path.contains("stripe")) && 
                  (uri.queryParameters.containsKey("transaction_id") ||
                   uri.queryParameters.containsKey("success"))) {
                
                // Check if it's a success (transaction_id present usually means success)
                bool isSuccess = uri.queryParameters.containsKey("transaction_id") ||
                                uri.queryParameters["success"]?.toLowerCase() == "true";
                
                if (isSuccess) {
                  // Process the payment on backend by calling the success URL
                  final transactionId = uri.queryParameters["transaction_id"];
                  if (transactionId != null) {
                    _processStripePayment(transactionId);
                  } else {
                    // No transaction ID, just refresh and navigate
                    Get.back();
                    Get.back();
                    Get.find<UserDataController>().fetchUserData(isReload: true);
                    Get.find<TransectionController>().transactionHistory(isReload: true);
                    showCustomSnackBar('Payment Successful', isError: false, duration: 3);
                    FadeScreenTransition(routeName: Routes.walletScreenRoute).navigate();
                  }
                } else {
                  Get.back();
                  showCustomSnackBar('Payment Failed', isError: true, duration: 3);
                }

                return NavigationDecision.prevent;
              }

              // Prevent loading localhost URLs on mobile (they won't work)
              if (uri.host == "localhost" || uri.host == "127.0.0.1") {
                // If it's a payment success URL, process it
                if (uri.path.contains("payment-success") || 
                    uri.path.contains("stripe") ||
                    uri.queryParameters.containsKey("transaction_id")) {
                  
                  final transactionId = uri.queryParameters["transaction_id"];
                  if (transactionId != null) {
                    _processStripePayment(transactionId);
                  } else {
                    // Fallback: just refresh and navigate
                    Get.back();
                    Get.back();
                    Get.find<UserDataController>().fetchUserData(isReload: true);
                    Get.find<TransectionController>().transactionHistory(isReload: true);
                    showCustomSnackBar('Payment Successful', isError: false, duration: 3);
                    FadeScreenTransition(routeName: Routes.walletScreenRoute).navigate();
                  }
                }
                return NavigationDecision.prevent;
              }

              return NavigationDecision.navigate;
            },
          ),

      )
      ..loadRequest(Uri.parse(widget.url));
  }

  // Process Stripe payment by calling backend API
  Future<void> _processStripePayment(String transactionId) async {
    try {
      // Close webview first
      Get.back();
      Get.back();

      // Show loading
      showCustomSnackBar('Processing payment...', isError: false, duration: 2);

      // Call backend to process the payment
      // Use ApiClient to ensure proper authentication headers
      final apiClient = Get.find<ApiClient>();
      final paymentSuccessUrl = '/api/stripe/payment-success?transaction_id=$transactionId';

      // Make GET request to process payment on backend
      // Add Accept header to get JSON response instead of redirect
      // Get authentication token
      final token = SessionManager.getValue(kToken, value: '');
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };
      
      // Use raw HTTP request with headers to get JSON response
      final backendUrl = Constant.baseUrl;
      final fullUrl = '$backendUrl$paymentSuccessUrl';
      
      log('Calling payment success URL: $fullUrl');
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: headers,
      );

      // Parse response
      final responseBody = response.body;
      log('Payment processing response: ${response.statusCode} - $responseBody');
      
      Map<String, dynamic>? responseData;
      try {
        responseData = jsonDecode(responseBody) as Map<String, dynamic>;
      } catch (e) {
        log('Failed to parse response: $e');
      }

      // Check if payment was processed successfully
      if (response.statusCode == 200 && responseData != null) {
        final status = responseData['status']?.toString().toLowerCase();
        
        if (status == 'success') {
          // Payment processed successfully
          await Get.find<UserDataController>().fetchUserData(isReload: true);
          await Get.find<TransectionController>().transactionHistory(isReload: true);

        showCustomSnackBar(
          'Payment Successful',
          isError: false,
          duration: 3,
        );
        
          FadeScreenTransition(routeName: Routes.walletScreenRoute).navigate();
          return;
        } else {
          // Payment failed
          final errorMsg = responseData['message'] ?? 'Payment failed';
          log('Stripe payment failed: $errorMsg');
          await Get.find<UserDataController>().fetchUserData(isReload: true);
          await Get.find<TransectionController>().transactionHistory(isReload: true);
          
          showCustomSnackBar(
            errorMsg.toString(),
            isError: true,
            duration: 3,
          );
          
        FadeScreenTransition(routeName: Routes.walletScreenRoute).navigate();
          return;
        }
      } else {
        // Unexpected response, but still refresh to check
        log('Stripe payment confirmation returned unexpected response: ${response.statusCode} - $responseBody');
        await Get.find<UserDataController>().fetchUserData(isReload: true);
        await Get.find<TransectionController>().transactionHistory(isReload: true);
        
        showCustomSnackBar(
          'We could not confirm the payment status. Please check your wallet history.',
          isError: true,
          duration: 3,
        );
        
        FadeScreenTransition(routeName: Routes.walletScreenRoute).navigate();
      }
    } catch (e) {
      log('Error processing Stripe payment: $e');
      // Still refresh data in case payment was processed on backend
      try {
        await Get.find<UserDataController>().fetchUserData(isReload: true);
        await Get.find<TransectionController>().transactionHistory(isReload: true);
      } catch (_) {}
      
      showCustomSnackBar(
        'Something went wrong while confirming your payment. Please check your wallet history.',
        isError: true,
        duration: 3,
      );
      
      FadeScreenTransition(routeName: Routes.walletScreenRoute).navigate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title:  widget.title ?? "Payment"),
      body: WebViewWidget(controller: _controller),
    );
  }
}