import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../service/api/api_client.dart';
import '../service/api/api_retry_manager.dart';
import '../utils/_constant.dart';
import '../widget/custom_snackbar_widget.dart';

class PromoteCardsController extends GetxController {
  final ApiClient apiClient;
  PromoteCardsController({required this.apiClient});

  var isLoading = false.obs;
  var promotionsList = <dynamic>[].obs;

  Future<void> fetchMyPromotions({bool isReload = false}) async {
    if (isReload) {
      promotionsList.clear();
    }
    isLoading.value = true;

    try {
      http.Response? response = await apiClient.getData(
        '${Constant.promotionsUrl}/mine',
      );

      if (response == null) {
        showCustomSnackBar("No response from server");
        promotionsList.value = [];
        isLoading.value = false;
        return;
      }

      if (response.statusCode == 200) {
        try {
          final json = jsonDecode(response.body);
          print("Promotions API Response: $json");

          List<dynamic> parsedList = [];
          
          if (json is Map<String, dynamic>) {
            if (json['status'] == 'success' && json['data'] != null) {
              final data = json['data'];
              
              // Handle paginated response structure
              if (data is Map<String, dynamic> && data['data'] != null) {
                if (data['data'] is List) {
                  parsedList = data['data'] as List;
                }
              } else if (data is List) {
                parsedList = data as List;
              }
            } else if (json['data'] != null && json['data'] is List) {
              parsedList = json['data'] as List;
            }
          } else if (json is List) {
            parsedList = json;
          }
          
          // Ensure all items are Maps
          promotionsList.value = parsedList
              .where((item) => item is Map<String, dynamic>)
              .map((item) => item as Map<String, dynamic>)
              .toList();
              
        } catch (e, stackTrace) {
          print("Error parsing promotions JSON: $e");
          print("Stack trace: $stackTrace");
          print("Response body: ${response.body}");
          showCustomSnackBar("Error parsing response: $e");
          promotionsList.value = [];
        }
      } else {
        try {
          final errorJson = jsonDecode(response.body);
          final errorMessage =
              errorJson['message'] ?? "Failed to load promotions";
          showCustomSnackBar(errorMessage);
        } catch (e) {
          showCustomSnackBar(
              "Failed to load promotions (Status: ${response.statusCode})");
        }
        promotionsList.value = [];
      }
    } catch (e, stackTrace) {
      print("Exception in fetchMyPromotions: $e");
      print("Stack trace: $stackTrace");
      apiRetryManager.addRequest(() {
        fetchMyPromotions();
      });
      showCustomSnackBar("Error loading promotions: ${e.toString()}");
      promotionsList.value = [];
    } finally {
      isLoading.value = false;
    }
  }
}

