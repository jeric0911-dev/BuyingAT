import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../service/api/api_client.dart';
import '../service/api/api_retry_manager.dart';
import '../utils/_constant.dart';
import '../widget/custom_snackbar_widget.dart';

class UserStatusController extends GetxController {
  ApiClient apiClient;
  UserStatusController({required this.apiClient});

  // Cache for user statuses (userId -> status)
  var userStatusCache = <int, UserStatus>{}.obs;
  var isLoading = <int, bool>{}.obs;

  /// Get user status by user ID
  Future<UserStatus?> getUserStatus(int userId) async {
    // Return cached status if available
    if (userStatusCache.containsKey(userId)) {
      return userStatusCache[userId];
    }

    // Check if already loading
    if (isLoading[userId] == true) {
      return null;
    }

    isLoading[userId] = true;

    try {
      http.Response? response = await apiClient.getData(
        '${Constant.userStatusUrl}/$userId',
      );

      if (response != null && response.statusCode == 200) {
        final json = jsonDecode(response.body);
        
        if (json['status'] == 'success' && json['data'] != null) {
          final statusData = json['data'];
          final status = UserStatus(
            userId: userId,
            isOnline: statusData['is_online'] ?? false,
            lastSeen: statusData['last_seen'] != null
                ? DateTime.tryParse(statusData['last_seen'])
                : null,
          );
          
          userStatusCache[userId] = status;
          return status;
        }
      }
    } catch (e) {
      print("Error fetching user status: $e");
    } finally {
      isLoading[userId] = false;
    }

    return null;
  }

  /// Mark current user as online
  Future<bool> markOnline() async {
    try {
      http.Response? response = await apiClient.postData(
        Constant.userStatusOnlineUrl,
        {},
      );

      return response != null && response.statusCode == 200;
    } catch (e) {
      print("Error marking user online: $e");
      return false;
    }
  }

  /// Mark current user as offline
  Future<bool> markOffline() async {
    try {
      http.Response? response = await apiClient.postData(
        Constant.userStatusOfflineUrl,
        {},
      );

      return response != null && response.statusCode == 200;
    } catch (e) {
      print("Error marking user offline: $e");
      return false;
    }
  }

  /// Update last seen timestamp
  Future<bool> updateLastSeen() async {
    try {
      http.Response? response = await apiClient.postData(
        Constant.userStatusLastSeenUrl,
        {},
      );

      return response != null && response.statusCode == 200;
    } catch (e) {
      print("Error updating last seen: $e");
      return false;
    }
  }

  /// Clear cache for a specific user
  void clearUserStatus(int userId) {
    userStatusCache.remove(userId);
    isLoading.remove(userId);
  }

  /// Clear all cached statuses
  void clearAllStatuses() {
    userStatusCache.clear();
    isLoading.clear();
  }
}

class UserStatus {
  final int userId;
  final bool isOnline;
  final DateTime? lastSeen;

  UserStatus({
    required this.userId,
    required this.isOnline,
    this.lastSeen,
  });

  String get statusText {
    if (isOnline) {
      return 'Online';
    }
    if (lastSeen != null) {
      final now = DateTime.now();
      final difference = now.difference(lastSeen!);
      
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return 'Offline';
      }
    }
    return 'Offline';
  }
}

