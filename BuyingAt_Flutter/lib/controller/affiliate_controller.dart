import 'dart:convert';

import 'package:get/get.dart';
import '../model/affiliate_stats_model.dart';
import '../service/api/api_client.dart';
import '../service/api/api_retry_manager.dart';

class AffiliateController extends GetxController {
  final ApiClient apiClient;

  AffiliateController({required this.apiClient});

  var isLoading = false.obs;
  var stats = const AffiliateStats().obs;

  Future<void> fetchAffiliateStats({bool isReload = false}) async {
    if (isReload) {
      stats.value = const AffiliateStats();
    }

    isLoading.value = true;
    try {
      // Base URL and /api prefix are handled inside ApiClient
      final response = await apiClient.getData('/affiliate/stats');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded['data'];
        if (data is Map<String, dynamic>) {
          stats.value = AffiliateStats.fromJson(data);
        }
      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        fetchAffiliateStats(isReload: isReload);
      });
    } finally {
      isLoading.value = false;
    }
  }
}


