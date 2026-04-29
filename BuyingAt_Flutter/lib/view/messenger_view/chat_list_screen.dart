import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controller/message_controller.dart';
import '../../controller/navigation_controller.dart';
import '../../model/get_all_msg_thread_model.dart';
import '../../routes/app_routes.dart';
import '../../utils/_constant.dart';
import '../../utils/app_color.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_image.dart';
import '../../utils/image_loader.dart';
import '../../utils/session_manager.dart';
import '../../widget/custom_app_bar.dart';
import '../../widget/custom_text_field_widget.dart';
import '../../helper/date_converter_helper.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late MessageController messageController;
  late dynamic myId;
  final TextEditingController _searchController = TextEditingController();
  var filteredConversations = <AllThreadData>[].obs;

  @override
  void initState() {
    super.initState();
    messageController = Get.find<MessageController>();
    myId = SessionManager.getValue(kUserId);
    
    // Only load conversations if user is logged in
    final isLoggedIn = SessionManager.getValue(kIsLOGIN, value: false);
    if (isLoggedIn && myId != null) {
      // Only load if not already loading and list is empty
      if (!messageController.getMsgThreadLoading.value && 
          messageController.getAllMsgThreadList.isEmpty) {
        _loadConversations();
      } else {
        // Use existing data if available
        filteredConversations.value = messageController.getAllMsgThreadList;
      }
    } else {
      filteredConversations.value = [];
    }
    
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadConversations() async {
    try {
      await messageController.getAllMsgThread();
      filteredConversations.value = messageController.getAllMsgThreadList;
    } catch (e) {
      print("Error loading conversations: $e");
      // Set empty list on error to prevent UI issues
      filteredConversations.value = [];
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      filteredConversations.value = messageController.getAllMsgThreadList;
    } else {
      filteredConversations.value = messageController.getAllMsgThreadList.where((conv) {
        final otherUser = _getOtherUser(conv);
        final name = otherUser?['name']?.toString().toLowerCase() ?? '';
        final username = otherUser?['profile']?['username']?.toString().toLowerCase() ?? '';
        final lastMessage = _getLastMessage(conv)?.toLowerCase() ?? '';
        return name.contains(query) || username.contains(query) || lastMessage.contains(query);
      }).toList();
    }
  }

  Map<String, dynamic>? _getOtherUser(AllThreadData conv) {
    final sender = conv.sender;
    final receiver = conv.receiver;
    
    if (sender is Map && sender['id'] == myId) {
      return receiver is Map<String, dynamic> ? receiver : null;
    } else if (receiver is Map && receiver['id'] == myId) {
      return sender is Map<String, dynamic> ? sender : null;
    }
    
    // Fallback: try to get from sender/receiver directly
    if (receiver is Map<String, dynamic>) return receiver;
    if (sender is Map<String, dynamic>) return sender;
    return null;
  }

  String? _getLastMessage(AllThreadData conv) {
    // The API returns the last message in the messages array
    if (conv.messages != null && conv.messages!.isNotEmpty) {
      final lastMsg = conv.messages![0];
      if (lastMsg is Map) {
        final rawMessage = lastMsg['message'];
        return _formatMessagePreview(rawMessage);
      }
    }
    return null;
  }

  String? _formatMessagePreview(dynamic rawMessage) {
    if (rawMessage == null) return null;
    final messageString = rawMessage.toString();
    if (messageString.isEmpty) return null;

    try {
      final parsed = jsonDecode(messageString);
      if (parsed is Map) {
        final type = parsed['type']?.toString();
        if (type == 'deal_item') {
          final item = parsed['item'];
          final title = item is Map ? item['title']?.toString() : null;
          if (title != null && title.isNotEmpty) {
            return 'Added to deal: $title';
          }
          return 'Added to deal';
        } else if (type == 'deal_item_removed') {
          final itemId = parsed['itemId'];
          if (itemId != null) {
            return 'Removed from deal';
          }
          return 'Removed from deal';
        }
      }
    } catch (_) {
      // Not JSON, fall through to return original
    }

    return messageString;
  }

  String _formatTimestamp(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m';
      }
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // Return day name (Mon, Tue, etc.)
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dateTime.weekday - 1];
    } else {
      // Return short date (MM/DD or similar)
      return '${dateTime.month}/${dateTime.day}';
    }
  }

  String _getInitials(String? username) {
    if (username == null || username.isEmpty) return 'U';
    // For BA#### format, use first 2 characters (BA) or first character
    if (username.length >= 2) {
      return username.substring(0, 2).toUpperCase();
    }
    return username[0].toUpperCase();
  }

  String _getDisplayName(Map<String, dynamic>? user) {
    if (user == null) return 'Unknown';
    // Show only username in BA#### format
    final profile = user['profile'];
    if (profile is Map && profile['username'] != null) {
      return profile['username'].toString();
    }
    return 'Unknown';
  }

  String _getUsername(Map<String, dynamic>? user) {
    if (user == null) return '';
    final profile = user['profile'];
    if (profile is Map && profile['username'] != null) {
      return '@${profile['username']}';
    }
    return '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToProfilePage() {
    // Set the index to profile page (index 3) BEFORE navigation
    // This must be done synchronously to prevent showing home page
    try {
      final navController = Get.find<NavigationController>();
      // Set the index value FIRST - this is critical
      // When PageController is accessed, it will use this index as initialPage
      navController.index.value = 3;
      
      // If PageController is already attached, jump to page immediately
      if (navController.pageController.hasClients) {
        navController.pageController.jumpToPage(3);
      }
    } catch (e) {
      // If controller doesn't exist yet, it will be created with index 0
      // We'll set it after navigation
    }
    
    // Navigate to bottom nav route, clearing all previous routes
    Get.offAllNamed(Routes.bottomNavRoute);
    
    // Immediately after navigation, ensure the page is correct
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final controller = Get.find<NavigationController>();
        if (controller.index.value != 3) {
          controller.index.value = 3;
        }
        if (controller.pageController.hasClients) {
          final currentPage = controller.pageController.page?.round() ?? 0;
          if (currentPage != 3) {
            controller.pageController.jumpToPage(3);
          }
        }
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          // Handle system back button press
          _navigateToProfilePage();
        }
      },
      child: Scaffold(
        backgroundColor: AppColor.white,
        appBar: CustomAppBar(
          title: 'Chats',
          onTapBack: () {
            _navigateToProfilePage();
          },
        ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: CustomTextFieldWidget(
              controller: _searchController,
              hintText: 'Search',
              showTitle: false,
              prefixIcon: Icons.search,
            ),
          ),

          // Chats Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'Chats',
              style: sansBold.copyWith(
                fontSize: 20.sp,
                color: AppColor.primaryColor,
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Conversations List
          Expanded(
            child: Obx(() {
              // Check if user is logged in
              final isLoggedIn = SessionManager.getValue(kIsLOGIN, value: false);
              if (!isLoggedIn) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppImage.icNoData,
                        height: 200.h,
                        width: 275.w,
                      ),
                      SizedBox(height: 29.h),
                      Text(
                        "Please login to view conversations",
                        style: sansReg.copyWith(
                          color: AppColor.primaryColor,
                          fontSize: 15.h,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              if (messageController.getMsgThreadLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColor.buttonColor,
                    strokeWidth: 2,
                  ),
                );
              }

              if (filteredConversations.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppImage.icNoData,
                        height: 200.h,
                        width: 275.w,
                      ),
                      SizedBox(height: 29.h),
                      Text(
                        "No conversations available",
                        style: sansReg.copyWith(
                          color: AppColor.primaryColor,
                          fontSize: 15.h,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: filteredConversations.length,
                itemBuilder: (context, index) {
                  final conversation = filteredConversations[index];
                  final otherUser = _getOtherUser(conversation);
                  final displayName = _getDisplayName(otherUser);
                  final username = _getUsername(otherUser);
                  final lastMessage = _getLastMessage(conversation) ?? 'No messages yet';
                  // Get timestamp from last message if available, otherwise use conversation created_at
                  DateTime? messageTime;
                  if (conversation.messages != null && conversation.messages!.isNotEmpty) {
                    final lastMsg = conversation.messages![0];
                    if (lastMsg is Map && lastMsg['created_at'] != null) {
                      try {
                        messageTime = DateTime.parse(lastMsg['created_at'].toString());
                      } catch (e) {
                        messageTime = conversation.createdAt;
                      }
                    } else {
                      messageTime = conversation.createdAt;
                    }
                  } else {
                    messageTime = conversation.createdAt;
                  }
                  final timestamp = _formatTimestamp(messageTime);
                  
                  // Get avatar
                  String? avatarUrl;
                  if (otherUser != null) {
                    final profile = otherUser['profile'];
                    if (profile is Map && profile['avatar'] != null) {
                      avatarUrl = profile['avatar'].toString();
                    } else if (otherUser['profile_img'] != null) {
                      avatarUrl = otherUser['profile_img'].toString();
                    }
                  }

                  return InkWell(
                    onTap: () {
                      // Navigate to individual chat screen
                      Get.toNamed(
                        Routes.messengerScreenRoute,
                        arguments: {'conversationId': conversation.id},
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColor.coolGray17,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 56.w,
                                height: 56.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColor.buttonColor.withOpacity(0.1),
                                ),
                                child: avatarUrl != null && avatarUrl.isNotEmpty
                                    ? ClipOval(
                                        child: ImageLoader(
                                          url: '${Constant.imageBaseUrl}$avatarUrl',
                                          width: 56.w,
                                          height: 56.w,
                                          boxFit: BoxFit.cover,
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          _getInitials(displayName),
                                          style: sansSemiBold.copyWith(
                                            fontSize: 20.sp,
                                            color: AppColor.buttonColor,
                                          ),
                                        ),
                                      ),
                              ),
                              // Status indicator (green/grey dot)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 14.w,
                                  height: 14.w,
                                  decoration: BoxDecoration(
                                    color: AppColor.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 10.w,
                                      height: 10.w,
                                      decoration: BoxDecoration(
                                        color: AppColor.coolGray21, // Change to AppColor.buttonColor for online
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(width: 12.w),

                          // Username and message (only show username in BA#### format)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        displayName, // This now returns username in BA#### format
                                        style: sansSemiBold.copyWith(
                                          fontSize: 16.sp,
                                          color: AppColor.primaryColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        lastMessage,
                                        style: sansReg.copyWith(
                                          fontSize: 14.sp,
                                          color: AppColor.coolGray21,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (timestamp.isNotEmpty) ...[
                                      SizedBox(width: 8.w),
                                      Text(
                                        timestamp,
                                        style: sansReg.copyWith(
                                          fontSize: 12.sp,
                                          color: AppColor.coolGray21,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      ),
    );
  }
}

