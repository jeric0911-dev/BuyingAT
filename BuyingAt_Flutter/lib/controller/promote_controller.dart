import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../service/api/api_client.dart';
import '../service/api/api_retry_manager.dart';
import '../utils/_constant.dart';
import '../widget/custom_snackbar_widget.dart';
import 'dashboard_controller.dart';

class PromoteController extends GetxController {
  final ApiClient apiClient;
  PromoteController({required this.apiClient});

  var isLoading = false.obs;
  var isSuccess = false.obs;

  Future<void> createPromotion({
    required int cardId,
    required double promotionPrice,
    required String promotionType,
    int? promotionDuration,
    int? maxViews,
  }) async {
    isLoading.value = true;
    isSuccess.value = false;

    try {
      // Ensure all values are properly typed
      final body = <String, dynamic>{
        'card_id': cardId,
        'seller_inventory_id': cardId, // For backward compatibility
        'promotion_price': promotionPrice.toDouble(),
        'promotion_type': promotionType,
      };

      if (promotionType == 'time' && promotionDuration != null) {
        body['promotion_duration'] = promotionDuration;
      }

      if (promotionType == 'impression' && maxViews != null) {
        body['max_views'] = maxViews;
      }

      print("Promotion request body: $body");
      print("Promotion price type: ${promotionPrice.runtimeType}");
      print("Promotion price value: $promotionPrice");
      print("Promotion type: $promotionType");
      print("Card ID: $cardId");

      http.Response? response = await apiClient.postData(
        Constant.promotionsUrl,
        body,
      );

      print("Promotion response status: ${response.statusCode}");
      print("Promotion response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          isSuccess.value = true;
          // Update promotion status in dashboard controller
          try {
            final dashboardController = Get.find<DashboardController>();
            dashboardController.checkPromotionStatus(cardId);
          } catch (_) {
            // Dashboard controller might not be initialized
          }
        } else {
          final errorMessage =
              json['message'] ?? 'Failed to create promotion';
          showCustomSnackBar(errorMessage);
        }
      } else {
        try {
          final errorJson = jsonDecode(response.body);
          print("Promotion error response: $errorJson");
          final errorMessage =
              errorJson['message'] ?? 'Failed to create promotion';
          final errorDetails = errorJson['error'] ?? errorJson['errors'];
          if (errorDetails != null) {
            print("Promotion error details: $errorDetails");
          }
          showCustomSnackBar(errorMessage);
        } catch (e) {
          print("Error parsing error response: $e");
          print("Response body: ${response.body}");
          showCustomSnackBar('Failed to create promotion');
        }
      }
    } catch (e) {
      apiRetryManager.addRequest(() {
        createPromotion(
          cardId: cardId,
          promotionPrice: promotionPrice,
          promotionType: promotionType,
          promotionDuration: promotionDuration,
          maxViews: maxViews,
        );
      });
      showCustomSnackBar('Error creating promotion: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}

