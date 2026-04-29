import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../model/buyer_profile_model.dart';
import '../service/api/api_client.dart';
import '../service/api/api_retry_manager.dart';
import '../utils/_constant.dart';
import '../widget/custom_snackbar_widget.dart';

class BuyerProfileDetailController extends GetxController {
  ApiClient apiClient;
  final int profileId;
  
  BuyerProfileDetailController({
    required this.apiClient,
    required this.profileId,
  });

  var isLoading = false.obs;
  var buyerProfile = Rx<BuyerProfile?>(null);

  Future<void> fetchBuyerProfile() async {
    isLoading.value = true;
    
    try {
      http.Response? response = await apiClient.getData('${Constant.buyerProfilesUrl}/$profileId');
      
      if (response == null) {
        showCustomSnackBar("No response from server");
        buyerProfile.value = null;
        isLoading.value = false;
        return;
      }
      
      print("Buyer Profile Detail API Response Status: ${response.statusCode}");
      print("Buyer Profile Detail API Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        try {
          final json = jsonDecode(response.body);
          print("Buyer Profile Detail JSON: $json");
          
          if (json['status'] == 'success' && json['data'] != null) {
            buyerProfile.value = BuyerProfile.fromJson(json['data']);
          } else if (json['data'] != null) {
            buyerProfile.value = BuyerProfile.fromJson(json['data']);
          } else {
            print("Unexpected response format: $json");
            buyerProfile.value = null;
          }
        } catch (e) {
          print("Error parsing JSON: $e");
          print("Response body: ${response.body}");
          showCustomSnackBar("Error parsing response: $e");
          buyerProfile.value = null;
        }
      } else if (response.statusCode == 404) {
        buyerProfile.value = null;
      } else {
        try {
          final errorJson = jsonDecode(response.body);
          final errorMessage = errorJson['message'] ?? "Failed to load buyer profile";
          print("API Error: $errorMessage");
          showCustomSnackBar(errorMessage);
        } catch (e) {
          print("Error parsing error response: $e");
          showCustomSnackBar("Failed to load buyer profile (Status: ${response.statusCode})");
        }
        buyerProfile.value = null;
      }
    } catch (e, stackTrace) {
      print("Exception in fetchBuyerProfile: $e");
      print("Stack trace: $stackTrace");
      apiRetryManager.addRequest(() {
        fetchBuyerProfile();
      });
      showCustomSnackBar("Error loading buyer profile: ${e.toString()}");
      buyerProfile.value = null;
    } finally {
      isLoading.value = false;
    }
  }
}

