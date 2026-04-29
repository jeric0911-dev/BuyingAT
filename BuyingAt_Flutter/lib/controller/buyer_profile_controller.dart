import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../model/buyer_profile_model.dart';
import '../service/api/api_client.dart';
import '../service/api/api_retry_manager.dart';
import '../utils/_constant.dart';
import '../widget/custom_snackbar_widget.dart';

class BuyerProfileController extends GetxController {
  final ApiClient apiClient;
  BuyerProfileController({required this.apiClient});

  var isLoading = false.obs;
  var buyerProfile = Rx<BuyerProfile?>(null);
  var hasProfile = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBuyerProfile();
  }

  /// Fetch current user's buyer profile
  Future<void> fetchBuyerProfile({bool isReload = false}) async {
    isLoading.value = true;
    try {
      http.Response? response = await apiClient.getData(Constant.buyerProfileUrl);

      if (response == null) {
        showCustomSnackBar("No response from server");
        buyerProfile.value = null;
        hasProfile.value = false;
        isLoading.value = false;
        return;
      }

      if (response.statusCode == 200) {
        try {
          final json = jsonDecode(response.body);
          if (json['status'] == 'success' && json['data'] != null) {
            try {
              buyerProfile.value = BuyerProfile.fromJson(json['data']);
              hasProfile.value = true;
            } catch (e) {
              print("Error parsing buyer profile data: $e");
              print("Data: ${json['data']}");
              buyerProfile.value = null;
              hasProfile.value = false;
            }
          } else if (json['status'] == 'not_found' || response.statusCode == 404) {
            buyerProfile.value = null;
            hasProfile.value = false;
          } else {
            buyerProfile.value = null;
            hasProfile.value = false;
          }
        } catch (e) {
          print("Error parsing buyer profile JSON: $e");
          print("Response body: ${response.body}");
          buyerProfile.value = null;
          hasProfile.value = false;
        }
      } else if (response.statusCode == 404) {
        buyerProfile.value = null;
        hasProfile.value = false;
      } else {
        try {
          final errorJson = jsonDecode(response.body);
          showCustomSnackBar(errorJson['message'] ?? "Failed to load buyer profile");
        } catch (e) {
          showCustomSnackBar("Failed to load buyer profile");
        }
        buyerProfile.value = null;
        hasProfile.value = false;
      }
    } catch (e, stackTrace) {
      print("Exception in fetchBuyerProfile: $e");
      print("Stack trace: $stackTrace");
      apiRetryManager.addRequest(() {
        fetchBuyerProfile();
      });
      buyerProfile.value = null;
      hasProfile.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Create buyer profile
  Future<bool> createBuyerProfile({
    required List<String> categories,
    required List<Map<String, dynamic>> tags,
    String? preferences,
    double? budgetMin,
    double? budgetMax,
    String? profileLink,
  }) async {
    isLoading.value = true;
    try {
      final body = <String, dynamic>{
        'categories': categories,
        'tags': tags,
        if (preferences != null && preferences.isNotEmpty) 'preferences': preferences,
        if (budgetMin != null) 'budget_min': budgetMin,
        if (budgetMax != null) 'budget_max': budgetMax,
        if (profileLink != null && profileLink.isNotEmpty) 'profile_link': profileLink,
      };

      http.Response? response = await apiClient.postData(
        Constant.buyerProfileUrl,
        body,
      );

      if (response == null) {
        showCustomSnackBar("No response from server");
        return false;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          buyerProfile.value = BuyerProfile.fromJson(json['data']);
          hasProfile.value = true;
          showCustomSnackBar("Buyer profile created successfully!", isError: false);
          return true;
        } else {
          showCustomSnackBar(json['message'] ?? "Failed to create buyer profile");
          return false;
        }
      } else {
        try {
          final errorJson = jsonDecode(response.body);
          showCustomSnackBar(errorJson['message'] ?? "Failed to create buyer profile");
        } catch (e) {
          showCustomSnackBar("Failed to create buyer profile");
        }
        return false;
      }
    } catch (e, stackTrace) {
      print("Exception in createBuyerProfile: $e");
      print("Stack trace: $stackTrace");
      apiRetryManager.addRequest(() {
        createBuyerProfile(
          categories: categories,
          tags: tags,
          preferences: preferences,
          budgetMin: budgetMin,
          budgetMax: budgetMax,
          profileLink: profileLink,
        );
      });
      showCustomSnackBar("Error creating buyer profile: ${e.toString()}");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update buyer profile
  Future<bool> updateBuyerProfile({
    required List<String> categories,
    required List<Map<String, dynamic>> tags,
    String? preferences,
    double? budgetMin,
    double? budgetMax,
    String? profileLink,
  }) async {
    isLoading.value = true;
    try {
      final body = <String, dynamic>{
        'categories': categories,
        'tags': tags,
        if (preferences != null && preferences.isNotEmpty) 'preferences': preferences,
        if (budgetMin != null) 'budget_min': budgetMin,
        if (budgetMax != null) 'budget_max': budgetMax,
        if (profileLink != null && profileLink.isNotEmpty) 'profile_link': profileLink,
      };

      http.Response? response = await apiClient.putData(
        Constant.buyerProfileUrl,
        body,
      );

      if (response == null) {
        showCustomSnackBar("No response from server");
        return false;
      }

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          buyerProfile.value = BuyerProfile.fromJson(json['data']);
          hasProfile.value = true;
          showCustomSnackBar("Buyer profile updated successfully!", isError: false);
          return true;
        } else {
          showCustomSnackBar(json['message'] ?? "Failed to update buyer profile");
          return false;
        }
      } else {
        try {
          final errorJson = jsonDecode(response.body);
          showCustomSnackBar(errorJson['message'] ?? "Failed to update buyer profile");
        } catch (e) {
          showCustomSnackBar("Failed to update buyer profile");
        }
        return false;
      }
    } catch (e, stackTrace) {
      print("Exception in updateBuyerProfile: $e");
      print("Stack trace: $stackTrace");
      apiRetryManager.addRequest(() {
        updateBuyerProfile(
          categories: categories,
          tags: tags,
          preferences: preferences,
          budgetMin: budgetMin,
          budgetMax: budgetMax,
          profileLink: profileLink,
        );
      });
      showCustomSnackBar("Error updating buyer profile: ${e.toString()}");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}

