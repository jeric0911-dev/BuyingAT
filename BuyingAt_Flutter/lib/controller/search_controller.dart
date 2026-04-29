import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../model/card_model.dart';
import '../model/buyer_profile_model.dart';
import '../service/api/api_client.dart';
import '../service/api/api_retry_manager.dart';
import '../utils/_constant.dart';
import '../widget/custom_snackbar_widget.dart';

class UnifiedSearchController extends GetxController {
  ApiClient apiClient;
  UnifiedSearchController({required this.apiClient});

  var isLoading = false.obs;
  var isCardsLoading = false.obs;
  var isBuyerProfilesLoading = false.obs;
  
  var cardsList = <CardItem>[].obs;
  var buyerProfilesList = <BuyerProfile>[].obs;
  
  var hasCards = false.obs;
  var hasBuyerProfiles = false.obs;

  /// Search for cards and buyer profiles
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      cardsList.clear();
      buyerProfilesList.clear();
      hasCards.value = false;
      hasBuyerProfiles.value = false;
      return;
    }

    isLoading.value = true;
    isCardsLoading.value = true;
    isBuyerProfilesLoading.value = true;
    
    // Search both in parallel
    await Future.wait([
      _searchCards(query),
      _searchBuyerProfiles(query),
    ]);
    
    isLoading.value = false;
  }

  /// Search for cards
  Future<void> _searchCards(String query) async {
    isCardsLoading.value = true;
    try {
      final params = <String, dynamic>{
        'page': 1,
        'limit': 50, // Get more results for search
        'search': query.trim(),
      };

      final queryString = params.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');

      http.Response? response = await apiClient.getData(
        '${Constant.browseCardsUrl}?$queryString',
      );

      if (response != null && response.statusCode == 200) {
        final json = jsonDecode(response.body);
        
        List<CardItem> foundCards = [];
        if (json['data'] != null && json['data'] is List) {
          foundCards = (json['data'] as List)
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
        }

        cardsList.value = foundCards;
        hasCards.value = foundCards.isNotEmpty;
      } else {
        cardsList.clear();
        hasCards.value = false;
      }
    } catch (e) {
      print("Error searching cards: $e");
      cardsList.clear();
      hasCards.value = false;
    } finally {
      isCardsLoading.value = false;
    }
  }

  /// Search for buyer profiles
  Future<void> _searchBuyerProfiles(String query) async {
    isBuyerProfilesLoading.value = true;
    try {
      // Fetch all buyer profiles and filter client-side
      // (assuming the API doesn't have a search parameter)
      http.Response? response = await apiClient.getData(Constant.buyerProfilesUrl);
      
      if (response != null && response.statusCode == 200) {
        final json = jsonDecode(response.body);
        
        List<BuyerProfile> allProfiles = [];
        if (json['status'] == 'success' && json['data'] != null && json['data'] is List) {
          allProfiles = (json['data'] as List)
              .map((item) {
                try {
                  return BuyerProfile.fromJson(item);
                } catch (e) {
                  print("Error parsing buyer profile item: $e");
                  return null;
                }
              })
              .whereType<BuyerProfile>()
              .toList();
        } else if (json['data'] != null && json['data'] is List) {
          allProfiles = (json['data'] as List)
              .map((item) {
                try {
                  return BuyerProfile.fromJson(item);
                } catch (e) {
                  return null;
                }
              })
              .whereType<BuyerProfile>()
              .toList();
        }

        // Filter profiles by search query
        final queryLower = query.toLowerCase().trim();
        final filteredProfiles = allProfiles.where((profile) {
          // Search in username
          final username = profile.user?.profile?.username ?? '';
          if (username.toLowerCase().contains(queryLower)) return true;
          
          // Search in name
          final name = profile.user?.name ?? '';
          if (name.toLowerCase().contains(queryLower)) return true;
          
          // Search in bio
          final bio = profile.user?.profile?.bio ?? '';
          if (bio.toLowerCase().contains(queryLower)) return true;
          
          // Search in categories
          if (profile.categories != null) {
            for (var category in profile.categories!) {
              if (category.toLowerCase().contains(queryLower)) return true;
            }
          }
          
          // Search in tags
          if (profile.buyerTags != null) {
            for (var tag in profile.buyerTags!) {
              final tagName = tag.tagName ?? '';
              if (tagName.toLowerCase().contains(queryLower)) return true;
            }
          }
          
          // Search in preferences
          final preferences = profile.preferences ?? '';
          if (preferences.toLowerCase().contains(queryLower)) return true;
          
          return false;
        }).toList();

        buyerProfilesList.value = filteredProfiles;
        hasBuyerProfiles.value = filteredProfiles.isNotEmpty;
      } else {
        buyerProfilesList.clear();
        hasBuyerProfiles.value = false;
      }
    } catch (e) {
      print("Error searching buyer profiles: $e");
      buyerProfilesList.clear();
      hasBuyerProfiles.value = false;
    } finally {
      isBuyerProfilesLoading.value = false;
    }
  }

  void clearSearch() {
    cardsList.clear();
    buyerProfilesList.clear();
    hasCards.value = false;
    hasBuyerProfiles.value = false;
  }
}

