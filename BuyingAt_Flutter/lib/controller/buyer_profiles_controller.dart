import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../model/buyer_profile_model.dart';
import '../service/api/api_client.dart';
import '../service/api/api_retry_manager.dart';
import '../utils/_constant.dart';
import '../widget/custom_snackbar_widget.dart';

class BuyerProfilesController extends GetxController {
  ApiClient apiClient;
  BuyerProfilesController({required this.apiClient});

  final searchController = TextEditingController();
  final selectedCategory = 'All Categories'.obs;
  
  var isLoading = false.obs;
  var buyerProfilesList = <BuyerProfile>[].obs;
  var filteredProfilesList = <BuyerProfile>[].obs;

  // Available categories for filtering
  final availableCategories = [
    'All Categories',
    'Sports Cards',
    'Trading Cards',
    'Collectible Cards',
    'Baseball Cards',
    'Football Cards',
    'Basketball Cards',
    'Hockey Cards',
    'Soccer Cards',
    'Rookie Cards',
    'Vintage Cards',
    'Modern Cards',
    'Autographed Cards',
    'Graded Cards',
  ];

  @override
  void onInit() {
    super.onInit();
    // Don't auto-fetch here - let the screen control when to fetch
    // This prevents duplicate API calls
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchBuyerProfiles({bool isReload = false, bool showCachedData = true}) async {
    // Prevent multiple simultaneous API calls
    if (isLoading.value && !isReload) {
      return;
    }
    
    if (isReload) {
      // Don't clear list immediately - show cached data while loading
      if (!showCachedData) {
        buyerProfilesList.clear();
        filteredProfilesList.clear();
      }
    }
    isLoading.value = true;
    
    try {
      // Add timeout handling and faster response
      http.Response? response = await apiClient.getData(Constant.buyerProfilesUrl);
      
      if (response == null) {
        showCustomSnackBar("No response from server");
        buyerProfilesList.value = [];
        filteredProfilesList.value = [];
        isLoading.value = false;
        return;
      }
      
      print("Buyer Profiles API Response Status: ${response.statusCode}");
      print("Buyer Profiles API Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        try {
          final json = jsonDecode(response.body);
          print("Buyer Profiles JSON: $json");
          
          // Check if response has 'status' and 'data' structure
          List<BuyerProfile> newProfiles = [];
          if (json['status'] == 'success' && json['data'] != null && json['data'] is List) {
            newProfiles = (json['data'] as List)
                .map((item) {
                  try {
                    return BuyerProfile.fromJson(item);
                  } catch (e) {
                    print("Error parsing buyer profile item: $e");
                    print("Item data: $item");
                    return null;
                  }
                })
                .whereType<BuyerProfile>()
                .toList();
          } else if (json['data'] != null && json['data'] is List) {
            // Handle case where response doesn't have 'status' field
            newProfiles = (json['data'] as List)
                .map((item) {
                  try {
                    return BuyerProfile.fromJson(item);
                  } catch (e) {
                    print("Error parsing buyer profile item: $e");
                    print("Item data: $item");
                    return null;
                  }
                })
                .whereType<BuyerProfile>()
                .toList();
          } else {
            print("Unexpected response format: $json");
            // Only clear if we have no cached data
            if (buyerProfilesList.isEmpty) {
              buyerProfilesList.value = [];
              filteredProfilesList.value = [];
            }
          }
          
          // Only update if we got new data, otherwise keep cached data
          if (newProfiles.isNotEmpty) {
            buyerProfilesList.value = newProfiles;
            applyFilters();
          } else if (buyerProfilesList.isEmpty) {
            // Only clear if we have no cached data and got empty response
            buyerProfilesList.value = [];
            filteredProfilesList.value = [];
          } else {
            // Keep cached data and just refresh filters
            applyFilters();
          }
        } catch (e) {
          print("Error parsing JSON: $e");
          print("Response body: ${response.body}");
          showCustomSnackBar("Error parsing response: $e");
          buyerProfilesList.value = [];
          filteredProfilesList.value = [];
        }
      } else {
        try {
          final errorJson = jsonDecode(response.body);
          final errorMessage = errorJson['message'] ?? "Failed to load buyer profiles";
          print("API Error: $errorMessage");
          showCustomSnackBar(errorMessage);
        } catch (e) {
          print("Error parsing error response: $e");
          showCustomSnackBar("Failed to load buyer profiles (Status: ${response.statusCode})");
        }
        buyerProfilesList.value = [];
        filteredProfilesList.value = [];
      }
    } catch (e, stackTrace) {
      print("Exception in fetchBuyerProfiles: $e");
      print("Stack trace: $stackTrace");
      
      // Only retry on network errors, not on timeout
      if (e.toString().contains('timeout') || e.toString().contains('Timeout')) {
        showCustomSnackBar("Request timed out. Please check your connection and try again.");
        buyerProfilesList.value = [];
        filteredProfilesList.value = [];
      } else {
        apiRetryManager.addRequest(() {
          fetchBuyerProfiles();
        });
        showCustomSnackBar("Error loading buyer profiles: ${e.toString()}");
        buyerProfilesList.value = [];
        filteredProfilesList.value = [];
      }
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    var filtered = List<BuyerProfile>.from(buyerProfilesList);

    // Filter by search term
    final searchTerm = searchController.text.trim().toLowerCase();
    if (searchTerm.isNotEmpty) {
      filtered = filtered.where((profile) {
        final userName = profile.user?.profile?.username?.toLowerCase() ?? 
                         profile.user?.name?.toLowerCase() ?? '';
        final userEmail = profile.user?.email?.toLowerCase() ?? '';
        final categories = profile.categories ?? [];
        final tags = profile.buyerTags ?? [];
        
        return userName.contains(searchTerm) ||
               userEmail.contains(searchTerm) ||
               categories.any((cat) => cat.toLowerCase().contains(searchTerm)) ||
               tags.any((tag) => tag.tagName?.toLowerCase().contains(searchTerm) ?? false);
      }).toList();
    }

    // Filter by category
    if (selectedCategory.value != 'All Categories') {
      filtered = filtered.where((profile) {
        final categories = profile.categories ?? [];
        return categories.contains(selectedCategory.value);
      }).toList();
    }

    filteredProfilesList.value = filtered;
  }

  void setCategory(String category) {
    selectedCategory.value = category;
    applyFilters();
  }

  void clearFilters() {
    searchController.clear();
    selectedCategory.value = 'All Categories';
    applyFilters();
  }

  void onSearchChanged() {
    applyFilters();
  }
}

