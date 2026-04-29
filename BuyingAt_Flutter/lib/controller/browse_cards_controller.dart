import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../model/card_model.dart';
import '../service/api/api_client.dart';
import '../service/api/api_retry_manager.dart';
import '../utils/_constant.dart';
import '../widget/custom_snackbar_widget.dart';

class BrowseCardsController extends GetxController {
  ApiClient apiClient;
  BrowseCardsController({required this.apiClient});

  // Filter fields
  final searchController = TextEditingController();
  final minPriceController = TextEditingController();
  final maxPriceController = TextEditingController();
  final FocusNode fSearch = FocusNode();
  final FocusNode fMinPrice = FocusNode();
  final FocusNode fMaxPrice = FocusNode();

  // Filter state
  var selectedSportType = RxString('');
  var selectedCondition = RxString('');
  var selectedGrade = RxString('');
  var selectedSortBy = RxString('created_at');
  var currentPage = 1.obs;
  var lastPage = 1.obs;

  // Data
  var cardsList = <CardItem>[].obs;
  var isLoading = false.obs;
  var isLoadMore = false.obs;
  var hasMore = true.obs;

  /// IDs of cards (SellerInventory IDs) that the current user has already
  /// bought and whose order status is completed. These should be hidden
  /// from the Browse Cards page for this buyer.
  var purchasedCompletedCardIds = <int>{}.obs;

  // Available filter options (populated from API response)
  var sportTypes = <String>[].obs;
  var conditions = <String>[].obs;
  var grades = ['Yes', 'No'].obs;

  // Sort options
  final sortOptions = [
    {'value': 'created_at', 'label': 'Newest First'},
    {'value': 'price_asc', 'label': 'Price: Low to High'},
    {'value': 'price_desc', 'label': 'Price: High to Low'},
  ];

  @override
  void onInit() {
    super.onInit();
    // Don't auto-fetch here - let the screen control when to fetch
    // This prevents duplicate API calls
  }

  /// Load IDs of cards the current user has already bought with
  /// completed orders, so we can hide them from Browse Cards.
  Future<void> loadPurchasedCompletedCardIds() async {
    try {
      // Fetch the user's own orders; use a higher limit to get recent history
      final response = await apiClient.getData(
        Constant.myOrderUrl,
        query: {'limit': '100'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded['data'];
        final ids = <int>{};

        if (data is List) {
          for (final dynamic order in data) {
            if (order is! Map<String, dynamic>) continue;

            final status =
                (order['order_status'] ?? '').toString().toLowerCase();
            if (status != 'completed') continue;

            final items = order['ordered_items'];
            if (items is! List) continue;

            for (final dynamic item in items) {
              if (item is! Map<String, dynamic>) continue;
              final sku = item['sku']?.toString() ?? '';
              if (!sku.startsWith('CARD-')) continue;

              final dynamic productId = item['product_id'];
              if (productId is int) {
                ids.add(productId);
              } else if (productId != null) {
                final parsed = int.tryParse(productId.toString());
                if (parsed != null) {
                  ids.add(parsed);
                }
              }
            }
          }
        }

        purchasedCompletedCardIds.value = ids;
      }
    } catch (e) {
      // If anything goes wrong, just keep the set empty and don't block browsing
      print('Failed to load purchased card ids: $e');
    }
  }

  // Build query parameters
  Map<String, dynamic> _buildQueryParams() {
    final params = <String, dynamic>{
      'page': currentPage.value,
      'limit': currentPage.value == 1 ? 20 : 12, // Load more on first page for faster initial display
    };

    if (searchController.text.trim().isNotEmpty) {
      params['search'] = searchController.text.trim();
    }
    if (selectedSportType.value.isNotEmpty) {
      params['sport_type'] = selectedSportType.value;
    }
    if (selectedCondition.value.isNotEmpty) {
      params['condition'] = selectedCondition.value;
    }
    if (selectedGrade.value.isNotEmpty) {
      params['grade'] = selectedGrade.value;
    }
    if (minPriceController.text.trim().isNotEmpty) {
      params['min_price'] = minPriceController.text.trim();
    }
    if (maxPriceController.text.trim().isNotEmpty) {
      params['max_price'] = maxPriceController.text.trim();
    }
    if (selectedSortBy.value.isNotEmpty) {
      params['sort_by'] = selectedSortBy.value;
    }

    return params;
  }

  // Fetch cards from API
  Future<void> fetchCards({bool isReload = false, bool showCachedData = true}) async {
    // Prevent multiple simultaneous API calls
    if (isReload) {
      if (isLoading.value) return; // Already loading, skip
      currentPage.value = 1;
      // Don't clear list immediately - show cached data while loading
      if (!showCachedData) {
        cardsList.clear();
      }
      hasMore.value = true;
      isLoading.value = true;
    } else {
      if (!hasMore.value || isLoadMore.value || isLoading.value) return;
      isLoadMore.value = true;
    }

    try {
      final params = _buildQueryParams();
      final queryString = params.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');

      http.Response? response = await apiClient.getData(
        '${Constant.browseCardsUrl}?$queryString',
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        try {
          final json = jsonDecode(responseBody);
          
          // Response structure from ResponseService::successWithPagination:
          // {
          //   "status": "success",
          //   "message": "...",
          //   "data": [...], // array of items
          //   "pagination": {
          //     "current_page": 1,
          //     "per_page": 12,
          //     "total": 100,
          //     "last_page": 9
          //   }
          // }
          
          List<CardItem> newCards = [];
          if (json['data'] != null && json['data'] is List) {
            // Response has data as a direct array
            newCards = (json['data'] as List)
                .map((item) {
                  try {
                    return CardItem.fromJson(item);
                  } catch (e) {
                    print("Error parsing card item: $e");
                    return null;
                  }
                })
                .whereType<CardItem>()
                .toList();

            // Hide cards that this buyer has already purchased and completed
            if (purchasedCompletedCardIds.isNotEmpty) {
              newCards = newCards.where((card) {
                final id = card.id;
                if (id == null) return true;
                return !purchasedCompletedCardIds.contains(id);
              }).toList();
            }
            
            // Update pagination
            if (json['pagination'] != null) {
              final pagination = json['pagination'];
              currentPage.value = pagination['current_page'] ?? 1;
              lastPage.value = pagination['last_page'] ?? 1;
              hasMore.value = currentPage.value < lastPage.value;
            }
          }

          if (isReload) {
            // Only update if we got new data, otherwise keep cached data
            if (newCards.isNotEmpty) {
              cardsList.value = newCards;
            } else if (cardsList.isEmpty) {
              // Only clear if we have no cached data and got empty response
              cardsList.value = [];
            }
          } else {
            cardsList.addAll(newCards);
          }

          // Extract unique sport types and conditions from cards
          final uniqueSportTypes = newCards
              .where((card) => card.sportType != null && card.sportType!.isNotEmpty)
              .map((card) => card.sportType!)
              .toSet()
              .toList();
          sportTypes.value = uniqueSportTypes;

          final uniqueConditions = newCards
              .where((card) => card.condition != null && card.condition!.isNotEmpty)
              .map((card) => card.condition!)
              .toSet()
              .toList();
          conditions.value = uniqueConditions;

        } catch (e) {
          print("Error parsing response: $e");
          print("Response body: ${response.body}");
          // Don't show error if it's just empty data
          if (response.statusCode == 200) {
            cardsList.value = [];
          } else {
            showCustomSnackBar("Failed to parse response: ${e.toString()}");
          }
        }
      } else if (response.statusCode == 404) {
        // Not found - just show empty list, don't show error
        cardsList.value = [];
      } else {
        showCustomSnackBar("Failed to load cards (Status: ${response.statusCode})");
        cardsList.value = [];
      }
    } catch (e) {
      // Only retry on network errors, not on timeout or other errors
      if (e.toString().contains('timeout') || e.toString().contains('Timeout')) {
        showCustomSnackBar("Request timed out. Please check your connection and try again.");
        cardsList.value = [];
      } else {
        showCustomSnackBar("Something went wrong! Please try again");
        apiRetryManager.addRequest(() {
          fetchCards(isReload: isReload);
        });
      }
    } finally {
      isLoading.value = false;
      isLoadMore.value = false;
    }
  }

  // Load more cards (pagination)
  void loadMore() {
    if (hasMore.value && !isLoadMore.value) {
      currentPage.value++;
      fetchCards(isReload: false);
    }
  }

  // Apply filters
  void applyFilters() {
    currentPage.value = 1;
    fetchCards(isReload: true);
  }

  // Clear all filters
  void clearFilters() {
    searchController.clear();
    minPriceController.clear();
    maxPriceController.clear();
    selectedSportType.value = '';
    selectedCondition.value = '';
    selectedGrade.value = '';
    selectedSortBy.value = 'created_at';
    applyFilters();
  }

  // Set sport type filter
  void setSportType(String? value) {
    selectedSportType.value = value ?? '';
    applyFilters();
  }

  // Set condition filter
  void setCondition(String? value) {
    selectedCondition.value = value ?? '';
    applyFilters();
  }

  // Set grade filter
  void setGrade(String? value) {
    selectedGrade.value = value ?? '';
    applyFilters();
  }

  // Set sort by
  void setSortBy(String value) {
    selectedSortBy.value = value;
    applyFilters();
  }

  @override
  void onClose() {
    searchController.dispose();
    minPriceController.dispose();
    maxPriceController.dispose();
    fSearch.dispose();
    fMinPrice.dispose();
    fMaxPrice.dispose();
    super.onClose();
  }
}
