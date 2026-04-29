import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../controller/browse_cards_controller.dart';
import '../controller/message_controller.dart';
import '../controller/shopping_cart_controller.dart';
import '../model/card_model.dart';
import '../routes/app_routes.dart';
import '../service/api/api_client.dart';
import '../transition/fade_transition.dart';
import '../utils/_constant.dart';
import '../utils/app_color.dart';
import '../utils/app_fonts.dart';
import '../utils/app_image.dart';
import '../utils/app_text.dart';
import '../utils/image_loader.dart';
import '../utils/session_manager.dart';
import 'package:get_storage/get_storage.dart';
import '../widget/custom_app_bar.dart';
import '../widget/custom_text_field_widget.dart';
import '../widget/custom_button.dart';
import '../widget/custom_snackbar_widget.dart';

class BrowseCardsScreen extends StatefulWidget {
  const BrowseCardsScreen({super.key});

  @override
  State<BrowseCardsScreen> createState() => _BrowseCardsScreenState();
}

class _BrowseCardsScreenState extends State<BrowseCardsScreen> {
  late BrowseCardsController browseCardsController;
  late MessageController messageController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  late final VoidCallback _messageListener;
  var currentCardIndex = 0.obs;
  var isSendingMessage = false.obs;
  var wishlistIds = <String>{}.obs; // Track wishlist items
  var isAddingToWishlist = false.obs;

  @override
  void initState() {
    super.initState();
    final apiClient = Get.find<ApiClient>();
    // Use findOrPut to reuse existing controller if available (keeps data in memory)
    try {
      browseCardsController = Get.find<BrowseCardsController>(tag: 'browse_cards');
    } catch (_) {
      browseCardsController = Get.put(BrowseCardsController(apiClient: apiClient), tag: 'browse_cards', permanent: false);
    }
    messageController = Get.find<MessageController>();
    _messageListener = () {
      if (mounted) {
        setState(() {});
      }
    };
    _messageController.addListener(_messageListener);
    
    // Setup page controller listener for pagination
    _pageController.addListener(_onPageChanged);
    
    // Fetch purchased card IDs, then cards and wishlist.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load IDs of cards the user has already bought (completed orders)
      await browseCardsController.loadPurchasedCompletedCardIds();

      // If we have cached data, show it immediately and refresh in background
      if (browseCardsController.cardsList.isNotEmpty) {
        // Data already exists, refresh in background
        browseCardsController.fetchCards(isReload: true, showCachedData: true);
      } else {
        // No cached data, fetch normally
        browseCardsController.fetchCards(isReload: true, showCachedData: false);
      }
      _fetchWishlist();
    });
  }

  Future<void> _fetchWishlist() async {
    try {
      // Fetch product wishlist from backend
      final apiClient = Get.find<ApiClient>();
      http.Response? response = await apiClient.getData(Constant.fetchWishListUrl);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['data'] != null && json['data'] is List) {
          final wishlistItems = json['data'] as List;
          final productIds = wishlistItems
              .map((item) => item['product_id']?.toString() ?? '')
              .where((id) => id.isNotEmpty)
              .toSet();
          wishlistIds.value = productIds;
        }
      }
    } catch (e) {
      // Silently fail - wishlist check is optional
    }
    
    // Also fetch card wishlist from local storage
    try {
      final cardWishlist = GetStorage().read<List>('card_wishlist') ?? [];
      final cardIds = cardWishlist.map((id) => id.toString()).toSet();
      wishlistIds.value = {...wishlistIds.value, ...cardIds};
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _toggleWishlist(CardItem card) async {
    if (isAddingToWishlist.value) return;
    
    final cardId = card.id?.toString() ?? '';
    if (cardId.isEmpty) {
      showCustomSnackBar("Card ID not available");
      return;
    }

    isAddingToWishlist.value = true;
    final isInWishlist = wishlistIds.contains(cardId);

    try {
      // Since backend doesn't support cards in wishlist, use local storage
      // Similar to how Frontend handles it
      final storage = GetStorage();
      List<dynamic> cardWishlist = storage.read<List>('card_wishlist') ?? [];
      
      if (isInWishlist) {
        // Remove from wishlist
        cardWishlist.removeWhere((id) => id.toString() == cardId);
        storage.write('card_wishlist', cardWishlist);
        wishlistIds.remove(cardId);
        showCustomSnackBar("Removed from wishlist", isError: false);
        
        // Refresh wishlist in shopping cart controller if it exists
        try {
          final shoppingCartController = Get.find<ShoppingCartController>();
          shoppingCartController.fetchCardWishList();
        } catch (_) {
          // Controller might not be initialized yet
        }
      } else {
        // Add to wishlist
        if (!cardWishlist.contains(int.tryParse(cardId) ?? cardId)) {
          cardWishlist.add(int.tryParse(cardId) ?? cardId);
          storage.write('card_wishlist', cardWishlist);
        }
        wishlistIds.add(cardId);
        showCustomSnackBar("Added to wishlist", isError: false);
        
        // Refresh wishlist in shopping cart controller if it exists
        try {
          final shoppingCartController = Get.find<ShoppingCartController>();
          shoppingCartController.fetchCardWishList();
        } catch (_) {
          // Controller might not be initialized yet
        }
      }
    } catch (e) {
      showCustomSnackBar("Failed to update wishlist");
    } finally {
      isAddingToWishlist.value = false;
    }
  }

  void _onPageChanged() {
    if (_pageController.hasClients) {
      final page = _pageController.page?.round() ?? 0;
      if (page != currentCardIndex.value) {
        currentCardIndex.value = page;
        
        // Load more cards when near the end
        if (page >= browseCardsController.cardsList.length - 2) {
          browseCardsController.loadMore();
        }
      }
    }
  }

  // Helper method to extract raw image URL for deal messages
  String? _extractRawImage(dynamic images) {
    if (images == null) return null;
    if (images is String) {
      final trimmed = images.trim();
      if (trimmed.isEmpty) return null;
      if (trimmed.startsWith('[')) {
        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is List && decoded.isNotEmpty) {
            return decoded.first.toString();
          }
        } catch (_) {
          // Fall back to original string if parsing fails
        }
      }
      return trimmed;
    }
    if (images is List && images.isNotEmpty) {
      return images.first.toString();
    }
    if (images is Map && images.isNotEmpty) {
      final firstValue = images.values.first;
      if (firstValue != null) {
        return firstValue.toString();
      }
    }
    return images.toString();
  }

  Future<void> _sendMessage(CardItem card) async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    final isLoggedIn = SessionManager.getValue(kIsLOGIN, value: false);
    if (!isLoggedIn) {
      showCustomSnackBar("Please login to send messages");
      return;
    }

    final myId = SessionManager.getValue(kUserId);
    if (myId == null) {
      showCustomSnackBar("User ID not found. Please login again.");
      return;
    }

    if (card.seller?.id == null) {
      showCustomSnackBar("Seller information not available");
      return;
    }

    // Prevent chatting with own card
    if (card.seller!.id.toString() == myId.toString()) {
      showCustomSnackBar("You cannot start a chat with your own card");
      return;
    }

    isSendingMessage.value = true;
    
    try {
      // Create conversation thread
      final conversationId = await messageController.createMsgThread(
        senderId: myId,
        receiverId: card.seller!.id!,
        productId: card.id,
        conversationType: 'product',
        shouldNavigate: false,
      );

      if (conversationId != null) {
        // Send the initial message to the conversation
        await messageController.createMessage(
          id: myId,
          customMessage: messageText,
          customConversationId: conversationId,
        );

        // Automatically add the card to the deal
        try {
          final dealMessage = {
            'type': 'deal_item',
            'item': {
              'id': card.id,
              'title': card.cardTitle,
              'price': card.price,
              'image': _extractRawImage(card.images),
            }
          };
          
          final dealMessageString = jsonEncode(dealMessage);
          
          await messageController.createMessage(
            id: myId,
            customMessage: dealMessageString,
            customConversationId: conversationId,
          );
        } catch (e) {
          // If adding to deal fails, continue anyway - the chat was created successfully
          print("Failed to add card to deal automatically: $e");
        }

        // Clear message input
        _messageController.clear();
        _messageFocusNode.unfocus();

        // Navigate to the chat screen
        FadeScreenTransition(
          routeName: Routes.messengerScreenRoute,
          arguments: {'conversationId': conversationId},
        ).navigate();
      } else {
        showCustomSnackBar("Failed to start chat. Please try again.");
      }
    } catch (e) {
      showCustomSnackBar("Failed to send message: ${e.toString()}");
    } finally {
      isSendingMessage.value = false;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _messageController.removeListener(_messageListener);
    _messageController.dispose();
    _messageFocusNode.dispose();
    // Don't delete controller - keep data in memory for faster subsequent loads
    // Get.delete<BrowseCardsController>(tag: 'browse_cards');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(AppImage.icFilter, width: 24.w, height: 24.h, colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn)),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
                        },
                        ),
                      ],
                    ),
      endDrawer: _buildFilterDrawer(),
      body: Obx(() {
        // Only show full loading if we have no cached data
        if (browseCardsController.isLoading.value && browseCardsController.cardsList.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColor.buttonColor,
                    strokeWidth: 2,
                  ),
                );
              }
              
        // Show empty state only when loading is complete and list is empty
        if (browseCardsController.cardsList.isEmpty && !browseCardsController.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 80.w,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "No cards found",
                        style: sansReg.copyWith(
                    color: Colors.white,
                          fontSize: 15.h,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Try adjusting your search or filter criteria",
                        style: sansReg.copyWith(
                    color: Colors.white70,
                          fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            Column(
              children: [
                // User info and price at top
                Obx(() {
              if (currentCardIndex.value < browseCardsController.cardsList.length) {
                final card = browseCardsController.cardsList[currentCardIndex.value];
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // User profile
                      Row(
                        children: [
                          Container(
                            width: 32.w,
                            height: 32.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColor.buttonColor,
                            ),
                            child: Icon(Icons.person, color: Colors.white, size: 20.w),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            card.seller?.name ?? "Seller",
                            style: sansMedium.copyWith(
                              fontSize: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      // Price
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          "\$${card.price ?? '0.00'}",
                          style: sansBold.copyWith(
                            fontSize: 16.sp,
                            color: AppColor.buttonColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SizedBox.shrink();
            }),

            // Swipeable Cards
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: browseCardsController.cardsList.length + (browseCardsController.isLoadMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == browseCardsController.cardsList.length) {
                    return Center(
                      child: CircularProgressIndicator(
                color: AppColor.buttonColor,
                        strokeWidth: 2,
                  ),
                );
              }
              
                  final card = browseCardsController.cardsList[index];
                  return _buildSwipeableCard(card);
                },
              ),
            ),

            // Chat input at bottom
            Obx(() {
              if (currentCardIndex.value < browseCardsController.cardsList.length) {
                final card = browseCardsController.cardsList[currentCardIndex.value];
                return _buildChatInput(card);
              }
              return SizedBox.shrink();
            }),
              ],
            ),
            // Subtle loading indicator when refreshing cached data
            if (browseCardsController.isLoading.value && browseCardsController.cardsList.isNotEmpty)
              Positioned(
                top: 8.h,
                right: 16.w,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColor.buttonColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildSwipeableCard(CardItem card) {
    // Parse images
    List<String> imageList = [];
    if (card.images != null) {
      try {
        if (card.images is String) {
          try {
            final decoded = jsonDecode(card.images!);
            if (decoded is List) {
              imageList = decoded.map((e) => e.toString()).toList();
            } else if (decoded is String) {
              imageList = [decoded];
            }
          } catch (e) {
            imageList = [card.images!];
          }
        } else if (card.images is List) {
          imageList = (card.images as List).map((e) => e.toString()).toList();
        } else {
          imageList = [card.images.toString()];
        }
      } catch (e) {
        if (card.images != null) {
          imageList = [card.images.toString()];
        }
      }
    }

    final firstImage = imageList.isNotEmpty ? imageList.first : '';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Stack(
        children: [
          // Card Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: firstImage.isNotEmpty
                ? ImageLoader(
                    url: '${Constant.imageBaseUrl}$firstImage',
                    height: double.infinity,
                    width: double.infinity,
                    boxFit: BoxFit.cover,
                  )
                : Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: AppColor.ghostWhite,
                    child: Icon(Icons.image, size: 48.w, color: AppColor.coolGray21),
                  ),
          ),

          // Card Info Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
                          padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Card Title
                  Text(
                    card.cardTitle ?? '',
                    style: sansBold.copyWith(
                      fontSize: 20.sp,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  
                  // Card Info Row
                  Row(
                    children: [
                      if (card.sportType != null && card.sportType!.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColor.buttonColor.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            card.sportType!,
                            style: sansMedium.copyWith(
                              fontSize: 12.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                      ],
                      if (card.condition != null && card.condition!.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            card.condition!,
                            style: sansMedium.copyWith(
                              fontSize: 12.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                      ],
                      if (card.grade != null && card.grade!.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            "Grade: ${card.grade}",
                            style: sansMedium.copyWith(
                              fontSize: 12.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Promoted Badge
          if (card.isPromoted == true)
            Positioned(
              top: 16.h,
              right: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColor.buttonColor,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  "PROMOTED",
                  style: sansBold.copyWith(
                    fontSize: 10.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChatInput(CardItem card) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(
          top: BorderSide(color: Colors.grey[800]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                style: sansReg.copyWith(
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(card),
                decoration: InputDecoration(
                  hintText: "Send message...",
                  hintStyle: sansReg.copyWith(
                    fontSize: 14.sp,
                    color: Colors.grey[400],
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Obx(() {
            final cardId = card.id?.toString() ?? '';
            final isInWishlist = wishlistIds.contains(cardId);
            
            return IconButton(
              icon: isAddingToWishlist.value
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                          child: CircularProgressIndicator(
                        strokeWidth: 2,
                            color: AppColor.buttonColor,
                      ),
                    )
                  : Icon(
                      isInWishlist ? Icons.favorite : Icons.favorite_border,
                      color: isInWishlist ? Colors.red : Colors.white,
                      size: 24.w,
                    ),
              onPressed: isAddingToWishlist.value ? null : () {
                _toggleWishlist(card);
              },
            );
          }),
          SizedBox(width: 8.w),
          Obx(() {
            return IconButton(
              icon: isSendingMessage.value
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                            strokeWidth: 2,
                        color: AppColor.buttonColor,
                          ),
                    )
                  : Icon(
                      Icons.send,
                      color: _messageController.text.trim().isNotEmpty
                          ? AppColor.buttonColor
                          : Colors.grey,
                      size: 24.w,
                    ),
              onPressed: _messageController.text.trim().isNotEmpty && !isSendingMessage.value
                  ? () => _sendMessage(card)
                  : null,
            );
          }),
        ],
                        ),
                      );
                    }
                    
  Widget _buildFilterDrawer() {
    return Drawer(
      width: 300.w,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Filters",
                    style: sansBold.copyWith(
                      fontSize: 20.sp,
                      color: AppColor.textColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Search
              Text(
                "Search",
                style: sansMedium.copyWith(
                  fontSize: 14.sp,
                  color: AppColor.textColor,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextFieldWidget(
                controller: browseCardsController.searchController,
                focusNode: browseCardsController.fSearch,
                hintText: "Search cards...",
                inputType: TextInputType.text,
                showTitle: false,
              ),

              SizedBox(height: 20.h),

              // Sport Type Filter
              Text(
                "Card Type",
                style: sansMedium.copyWith(
                  fontSize: 14.sp,
                  color: AppColor.textColor,
                ),
              ),
              SizedBox(height: 8.h),
              Obx(() {
                return DropdownButtonFormField<String>(
                  value: browseCardsController.selectedSportType.value.isEmpty
                      ? null
                      : browseCardsController.selectedSportType.value,
                  decoration: InputDecoration(
                    hintText: "All Types",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text("All Types", style: sansReg.copyWith(fontSize: 14.sp)),
                    ),
                    ...browseCardsController.sportTypes.map((sport) {
                      return DropdownMenuItem<String>(
                        value: sport,
                        child: Text(sport, style: sansReg.copyWith(fontSize: 14.sp)),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    browseCardsController.setSportType(value);
                  },
                );
              }),

              SizedBox(height: 20.h),

              // Condition Filter
              Text(
                "Condition",
                style: sansMedium.copyWith(
                  fontSize: 14.sp,
                  color: AppColor.textColor,
                ),
              ),
              SizedBox(height: 8.h),
              Obx(() {
                return DropdownButtonFormField<String>(
                  value: browseCardsController.selectedCondition.value.isEmpty
                      ? null
                      : browseCardsController.selectedCondition.value,
                  decoration: InputDecoration(
                    hintText: "All Conditions",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text("All Conditions", style: sansReg.copyWith(fontSize: 14.sp)),
                    ),
                    ...browseCardsController.conditions.map((condition) {
                      return DropdownMenuItem<String>(
                        value: condition,
                        child: Text(condition, style: sansReg.copyWith(fontSize: 14.sp)),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    browseCardsController.setCondition(value);
                  },
                );
              }),

              SizedBox(height: 20.h),

              // Grade Filter
              Text(
                "Graded",
                style: sansMedium.copyWith(
                  fontSize: 14.sp,
                  color: AppColor.textColor,
                ),
              ),
              SizedBox(height: 8.h),
              Obx(() {
                return DropdownButtonFormField<String>(
                  value: browseCardsController.selectedGrade.value.isEmpty
                      ? null
                      : browseCardsController.selectedGrade.value,
                  decoration: InputDecoration(
                    hintText: "All Grades",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text("All Grades", style: sansReg.copyWith(fontSize: 14.sp)),
                    ),
                    ...browseCardsController.grades.map((grade) {
                      return DropdownMenuItem<String>(
                        value: grade,
                        child: Text(grade, style: sansReg.copyWith(fontSize: 14.sp)),
                    );
                    }),
                  ],
                  onChanged: (value) {
                    browseCardsController.setGrade(value);
                  },
              );
            }),

              SizedBox(height: 20.h),

              // Price Range
              Text(
                "Price Range",
                style: sansMedium.copyWith(
                  fontSize: 14.sp,
                  color: AppColor.textColor,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFieldWidget(
                      controller: browseCardsController.minPriceController,
                      focusNode: browseCardsController.fMinPrice,
                      hintText: "Min",
                      inputType: TextInputType.number,
                      showTitle: false,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomTextFieldWidget(
                      controller: browseCardsController.maxPriceController,
                      focusNode: browseCardsController.fMaxPrice,
                      hintText: "Max",
                      inputType: TextInputType.number,
                      showTitle: false,
                    ),
          ),
        ],
              ),

              SizedBox(height: 32.h),

              // Clear Filters Button
              CustomButton(
                text: "Clear All Filters",
                height: 48.h,
                color: AppColor.coolGray17,
                textColor: AppColor.textColor,
                onPressed: () {
                  browseCardsController.clearFilters();
                  Navigator.of(context).pop();
                },
              ),

              SizedBox(height: 16.h),

              // Apply Filters Button
              CustomButton(
                text: "Apply Filters",
                height: 48.h,
                onPressed: () {
                  browseCardsController.applyFilters();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
