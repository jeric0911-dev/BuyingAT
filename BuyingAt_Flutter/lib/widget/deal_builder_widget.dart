import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/message_controller.dart';
import '../controller/home_controller.dart';
import '../controller/shopping_cart_controller.dart';
import '../model/card_model.dart';
import '../model/get_message_model.dart';
import '../service/api/api_client.dart';
import '../utils/_constant.dart';
import '../utils/app_color.dart';
import '../utils/app_fonts.dart';
import '../utils/image_loader.dart';
import '../routes/app_routes.dart';
import '../transition/fade_transition.dart';
import '../widget/custom_button.dart';
import '../widget/custom_text_field_widget.dart';
import '../widget/custom_snackbar_widget.dart';

class DealBuilderWidget extends StatefulWidget {
  final int conversationId;
  final String conversationType;
  final int? sellerId;
  final int? buyerId;
  final int? currentUserId;
  final List<dynamic> messages;
  final VoidCallback? onBackToChat;

  const DealBuilderWidget({
    super.key,
    required this.conversationId,
    required this.conversationType,
    this.sellerId,
    this.buyerId,
    this.currentUserId,
    this.messages = const [],
  this.onBackToChat,
  });

  @override
  State<DealBuilderWidget> createState() => _DealBuilderWidgetState();
}

class _DealBuilderWidgetState extends State<DealBuilderWidget> {
  final TextEditingController _searchController = TextEditingController();
  var isLoading = false.obs;
  var cardsList = <CardItem>[].obs;
  // Keep full seller card list for fast local search/filter
  var _allSellerCards = <CardItem>[];
  var selectedCards = <int>{}.obs;
  var bundleCards = <CardItem>[].obs;
  var isAddingToDeal = false.obs;
  var isCheckoutLoading = false.obs;
  var isAcceptOfferLoading = false.obs;

  late MessageController messageController;
  late ApiClient apiClient;

  Worker? _messageListWorker;

  // Simple in-memory cache to avoid refetching the same seller's cards
  static final Map<int, List<CardItem>> _sellerCardsCache = {};

  @override
  void initState() {
    super.initState();
    messageController = Get.find<MessageController>();
    apiClient = Get.find<ApiClient>();
    _initializeBundleFromMessages();
    _loadSellerCards();
    
    // Listen to message list changes to update bundle
    // Use debounce to avoid too many updates
    _messageListWorker = debounce(
      messageController.getMessageList,
      (_) {
        if (mounted) {
          _initializeBundleFromMessages();
        }
      },
      time: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _messageListWorker?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initializeBundleFromMessages() {
    final bundleMap = <int, CardItem>{};
    
    // Use messageController.getMessageList directly instead of widget.messages
    // This ensures we always have the latest messages
    final messages = List<GetMessage>.from(messageController.getMessageList);
        
    // Process messages in chronological order (oldest first)
    // This ensures removals are processed after adds
    final sortedMessages = List<GetMessage>.from(messages);
    sortedMessages.sort((a, b) {
      final aTime = a.createdAt ?? DateTime(1970);
      final bTime = b.createdAt ?? DateTime(1970);
      return aTime.compareTo(bTime);
    });
    
    for (var msg in sortedMessages) {
      try {
        // Since sortedMessages is List<GetMessage>, msg is always GetMessage
        final messageText = msg.message?.toString();
        
        if (messageText == null || messageText.isEmpty) continue;
        
        final parsed = jsonDecode(messageText);
        if (parsed is Map) {
          if (parsed['type'] == 'deal_item' && parsed['item'] != null) {
            final item = parsed['item'];
            final cardId = item['id'];
            if (cardId != null) {
              // Handle both int and string IDs
              final id = cardId is int ? cardId : int.tryParse(cardId.toString());
              if (id != null) {
              // Create a CardItem from the deal item data
              final card = CardItem(
                  id: id,
                cardTitle: item['title']?.toString(),
                price: item['price']?.toString(),
                images: item['image']?.toString(),
              );
                bundleMap[id] = card;
              }
            }
          } else if (parsed['type'] == 'deal_item_removed' && parsed['itemId'] != null) {
            final itemId = parsed['itemId'];
            // Handle both int and string IDs
            final cardId = itemId is int ? itemId : int.tryParse(itemId.toString());
            if (cardId != null) {
              bundleMap.remove(cardId);
            }
          }
        }
      } catch (e) {
        // Not a JSON message, skip
        continue;
      }
    }

    bundleCards.value = bundleMap.values.toList();
    selectedCards.value = bundleMap.keys.toSet();
  }

  Future<void> _loadSellerCards() async {
    final sellerId = widget.sellerId;
    if (sellerId == null) return;

    // If we have cached cards for this seller, use them immediately
    if (_sellerCardsCache.containsKey(sellerId) && _sellerCardsCache[sellerId]!.isNotEmpty) {
      _allSellerCards = List<CardItem>.from(_sellerCardsCache[sellerId]!);
      cardsList.value = List<CardItem>.from(_allSellerCards);
      return;
    }

    isLoading.value = true;
    try {
      final params = <String, dynamic>{
        'page': 1,
        // Smaller limit for faster loading; we only show this seller's cards
        'limit': 50,
      };

      final queryString = params.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');

      final response = await apiClient.getData(
        '${Constant.browseCardsUrl}?$queryString',
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        List<CardItem> allCards = [];
        if (json['data'] != null && json['data'] is List) {
          allCards = (json['data'] as List)
              .map((item) {
                try {
                  return CardItem.fromJson(item);
                } catch (e) {
                  return null;
                }
              })
              .whereType<CardItem>()
              .toList();
        }

        // Filter cards by seller
        _allSellerCards = allCards.where((card) {
          return card.seller?.id == sellerId;
        }).toList();

        // Cache for subsequent openings of the same seller's deal builder
        _sellerCardsCache[sellerId] = List<CardItem>.from(_allSellerCards);
        cardsList.value = List<CardItem>.from(_allSellerCards);
      }
    } catch (e) {
      print("Error loading seller cards: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _addToDeal(CardItem card) async {
    if (isAddingToDeal.value) return;

    isAddingToDeal.value = true;
    GetMessage? optimisticMessage;
    try {
      // Add to local state
      selectedCards.add(card.id!);
      bundleCards.add(card);

      // Send as JSON message
      final dealMessage = {
        'type': 'deal_item',
        'item': {
          'id': card.id,
          'title': card.cardTitle,
          'price': card.price,
          'image': _extractRawImage(card.images),
        }
      };
      
      final messageString = jsonEncode(dealMessage);

      final int? userId = int.tryParse(messageController.myId.toString());
      optimisticMessage = GetMessage(
        conversationId: widget.conversationId,
        userId: userId,
        message: messageString,
        createdAt: DateTime.now(),
      );
      messageController.getMessageList.insert(0, optimisticMessage);
      
      final messageBody = {
        'conversation_id': widget.conversationId,
        'message': messageString,
      };
      
      final response = await apiClient.postData(
        Constant.createMsgUrl,
        messageBody,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success - item added to deal
        showCustomSnackBar("Added to deal", isError: false);
      } else {
        // Remove from local state on failure
        selectedCards.remove(card.id);
        bundleCards.removeWhere((c) => c.id == card.id);
        if (optimisticMessage != null) {
          messageController.getMessageList.remove(optimisticMessage);
        }
        showCustomSnackBar("Failed to add to deal");
      }
    } catch (e) {
      selectedCards.remove(card.id);
      bundleCards.removeWhere((c) => c.id == card.id);
      if (optimisticMessage != null) {
        messageController.getMessageList.remove(optimisticMessage);
      }
      showCustomSnackBar("Failed to add to deal");
    } finally {
      isAddingToDeal.value = false;
    }
  }

  Future<void> _removeFromDeal(int cardId) async {
    // Remove from local state
    selectedCards.remove(cardId);
    CardItem? removedCard;
    for (final card in bundleCards) {
      if (card.id == cardId) {
        removedCard = card;
        break;
      }
    }
    if (removedCard != null) {
      bundleCards.remove(removedCard);
    }
    
    GetMessage? optimisticMessage;
    try {
      // Send removal message
      final removalMessage = {
        'type': 'deal_item_removed',
        'itemId': cardId,
      };
      
      final messageString = jsonEncode(removalMessage);

      final int? userId = int.tryParse(messageController.myId.toString());
      optimisticMessage = GetMessage(
        conversationId: widget.conversationId,
        userId: userId,
        message: messageString,
        createdAt: DateTime.now(),
      );
      messageController.getMessageList.insert(0, optimisticMessage);

      final messageBody = {
        'conversation_id': widget.conversationId,
        'message': messageString,
      };
      
      final response = await apiClient.postData(
        Constant.createMsgUrl,
        messageBody,
      );
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to remove from deal');
      }
    } catch (e) {
      // Revert local state on failure
      if (removedCard != null) {
        bundleCards.add(removedCard);
        selectedCards.add(removedCard.id!);
      }
      if (optimisticMessage != null) {
        messageController.getMessageList.remove(optimisticMessage);
      }
      showCustomSnackBar("Failed to remove from deal");
    }
  }

  Future<void> _checkout() async {
    if (bundleCards.isEmpty) return;
    if (widget.sellerId == null) {
      showCustomSnackBar("Seller information not available");
      return;
    }

    isCheckoutLoading.value = true;

    final successItems = <CardItem>[];
    final alreadyItems = <CardItem>[];
    final failedItems = <String>[];

    try {
      final cardsToProcess = List<CardItem>.from(bundleCards);
      for (final card in cardsToProcess) {
        if (card.id == null) {
          failedItems.add('${card.cardTitle ?? 'Card'}: Missing card id');
          continue;
        }

        final body = {
          "product_id": card.id,
          "vendor_id": widget.sellerId,
          "quantity": 1,
          "is_card": true,
        };
        
        try {
          final response = await apiClient.postData(
          Constant.addToCardUrl,
          body,
        );
        
          Map<String, dynamic> decoded = {};
          try {
            decoded = jsonDecode(response.body);
          } catch (_) {}

          final message = (decoded['message'] ?? '').toString();
          final status = (decoded['status'] ?? '').toString().toLowerCase();
          final lowerMessage = message.toLowerCase();
          final bool isAlready = lowerMessage.contains('already in your cart');
          final bool isSuccess = response.statusCode == 200 ||
              response.statusCode == 201 ||
              status == 'success';

          if (isAlready) {
            alreadyItems.add(card);
          } else if (isSuccess) {
            successItems.add(card);
          } else {
            failedItems.add('${card.cardTitle ?? 'Card'}: ${message.isNotEmpty ? message : 'Failed to add to cart'}');
          }
        } catch (error) {
          failedItems.add('${card.cardTitle ?? 'Card'}: ${error.toString()}');
        }
      }

      // Update cart counts
      final addedCount = successItems.length;
      final alreadyCount = alreadyItems.length;

      if (addedCount > 0) {
        try {
          final homeController = Get.find<HomeController>();
          homeController.totalProduct.value += addedCount;
        } catch (_) {}
      }

      if (addedCount > 0 || alreadyCount > 0) {
      try {
        final cartController = Get.find<ShoppingCartController>();
          cartController.fetchCartItem(isReload: true);
      } catch (_) {}
      }

      if (failedItems.length == cardsToProcess.length) {
        // All failed
        showCustomSnackBar(
          failedItems.join('\n'),
          isError: true,
        );
        return;
      }

      if (failedItems.isNotEmpty) {
        showCustomSnackBar(
          failedItems.join('\n'),
          isError: true,
        );
      }

      final summaryParts = <String>[];
      if (addedCount > 0) {
        summaryParts.add('$addedCount item(s) added');
      }
      if (alreadyCount > 0) {
        summaryParts.add('$alreadyCount already in cart');
      }

      if (summaryParts.isNotEmpty) {
        showCustomSnackBar(
          summaryParts.join(', '),
          isError: false,
        );

        // If there is an accepted offer, pass the amount to the cart screen
        final acceptedOfferAmount = _getLatestAcceptedOfferAmount();

        FadeScreenTransition(
          routeName: Routes.shoppingCartRoute,
          arguments: acceptedOfferAmount != null
              ? {'acceptedOfferAmount': acceptedOfferAmount}
              : null,
        ).navigate();
      }
    } catch (e) {
      showCustomSnackBar("Failed to checkout", isError: true);
    } finally {
      isCheckoutLoading.value = false;
    }
  }

  /// Find the most recent accepted deal offer amount from the message list
  double? _getLatestAcceptedOfferAmount() {
    try {
      final messages = List<GetMessage>.from(messageController.getMessageList);
      for (final msg in messages) {
        final text = msg.message?.toString();
        if (text == null || text.isEmpty) continue;
        final parsed = jsonDecode(text);
        if (parsed is Map &&
            parsed['type'] == 'deal_offer' &&
            (parsed['status']?.toString() == 'accepted')) {
          final amount = parsed['amount'];
          if (amount is num) {
            return amount.toDouble();
          }
          final parsedAmount = double.tryParse(amount.toString());
          if (parsedAmount != null) {
            return parsedAmount;
          }
        }
      }
    } catch (_) {
      // Ignore parsing errors, just fall back to normal subtotal
    }
    return null;
  }

  /// Apply local search filter on already loaded seller cards
  void _applySearchFilter(String value) {
    final query = value.trim().toLowerCase();
    if (query.isEmpty) {
      // Reset to full list
      cardsList.value = List<CardItem>.from(_allSellerCards);
      return;
    }

    cardsList.value = _allSellerCards.where((card) {
      final title = (card.cardTitle ?? '').toLowerCase();
      final sport = (card.sportType ?? '').toLowerCase();
      final condition = (card.condition ?? '').toLowerCase();
      return title.contains(query) || sport.contains(query) || condition.contains(query);
    }).toList();
  }

  Future<void> _acceptOffer(double totalPrice) async {
    if (bundleCards.isEmpty) {
      showCustomSnackBar("Please add at least one card to the deal first");
      return;
    }

    if (widget.conversationId == 0) {
      showCustomSnackBar("Conversation not initialized");
      return;
    }

    isAcceptOfferLoading.value = true;

    GetMessage? optimisticMessage;
    try {
      final cardIds = bundleCards
          .where((c) => c.id != null)
          .map((c) => c.id)
          .toList();

      final offerPayload = {
        'type': 'deal_offer',
        'status': 'accepted',
        'amount': totalPrice,
        'currency': 'USD',
        'card_ids': cardIds,
      };

      final messageString = jsonEncode(offerPayload);

      final int? userId = int.tryParse(messageController.myId.toString());
      optimisticMessage = GetMessage(
        conversationId: widget.conversationId,
        userId: userId,
        message: messageString,
        createdAt: DateTime.now(),
      );
      // Show immediately in chat
      messageController.getMessageList.insert(0, optimisticMessage);

      final messageBody = {
        'conversation_id': widget.conversationId,
        'message': messageString,
      };

      final response = await apiClient.postData(
        Constant.createMsgUrl,
        messageBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showCustomSnackBar("Offer accepted", isError: false);
      } else {
        if (optimisticMessage != null) {
          messageController.getMessageList.remove(optimisticMessage);
        }
        showCustomSnackBar("Failed to accept offer");
      }
    } catch (_) {
      if (optimisticMessage != null) {
        messageController.getMessageList.remove(optimisticMessage);
      }
      showCustomSnackBar("Failed to accept offer");
    } finally {
      isAcceptOfferLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSeller = widget.sellerId != null &&
        widget.currentUserId != null &&
        widget.sellerId == widget.currentUserId;
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border(
          left: BorderSide(color: AppColor.coolGray17, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColor.coolGray17, width: 1),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Add to Deal',
                  style: sansSemiBold.copyWith(
                    fontSize: 16.sp,
                    color: AppColor.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Search
          Padding(
            padding: EdgeInsets.all(16.w),
            child: CustomTextFieldWidget(
              controller: _searchController,
              hintText: 'Search cards...',
              showTitle: false,
              onChanged: (value) {
                _applySearchFilter(value);
              },
              ),
            ),

          // Cards List
          Expanded(
            child: Obx(() {
              if (isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: AppColor.buttonColor),
                );
              }

              if (cardsList.isEmpty) {
                return Center(
                  child: Text(
                    'No cards available',
                    style: sansReg.copyWith(
                      fontSize: 14.sp,
                      color: AppColor.coolGray21,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: cardsList.length,
                itemBuilder: (context, index) {
                  final card = cardsList[index];
                  final isSelected = selectedCards.contains(card.id);
                  
                  return _buildCardItem(card, isSelected);
                },
              );
            }),
          ),
          
          // Bundle Summary
          if (bundleCards.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColor.coolGray17, width: 1),
                ),
                color: AppColor.ghostWhite,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deal Bundle (${bundleCards.length})',
                    style: sansSemiBold.copyWith(
                      fontSize: 14.sp,
                      color: AppColor.primaryColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ...bundleCards.take(3).map((card) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              card.cardTitle ?? 'Untitled',
                              style: sansReg.copyWith(
                                fontSize: 12.sp,
                                color: AppColor.primaryColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, size: 16.w),
                            onPressed: () => _removeFromDeal(card.id!),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (bundleCards.length > 3)
                    Text(
                      '+${bundleCards.length - 3} more',
                      style: sansReg.copyWith(
                        fontSize: 12.sp,
                        color: AppColor.coolGray21,
                      ),
                    ),
                  SizedBox(height: 12.h),
                  if (widget.onBackToChat != null) ...[
                    CustomButton(
                      text: 'Back to Chat',
                      height: 40.h,
                      color: AppColor.white,
                      textColor: AppColor.buttonColor,
                      borderColor: AppColor.buttonColor,
                      onPressed: widget.onBackToChat,
                    ),
                    SizedBox(height: 8.h),
                  ],
                  if (isSeller) ...[
                    Obx(
                      () => CustomButton(
                        text: isAcceptOfferLoading.value
                            ? 'Processing...'
                            : 'Accept Offer',
                        height: 40.h,
                        color: AppColor.buttonColor,
                        textColor: Colors.white,
                        onPressed: isAcceptOfferLoading.value
                            ? null
                            : () async {
                                final controller =
                                    TextEditingController(text: '');
                                await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Accept Offer',
                                        style: sansSemiBold.copyWith(
                                          fontSize: 16.sp,
                                          color: AppColor.primaryColor,
                                        ),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Enter total price for all cards in this deal.',
                                            style: sansReg.copyWith(
                                              fontSize: 14.sp,
                                              color: AppColor.coolGray21,
                                            ),
                                          ),
                                          SizedBox(height: 12.h),
                                          TextField(
                                            controller: controller,
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'Total price',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            'Cancel',
                                            style: sansReg.copyWith(
                                              color: AppColor.coolGray21,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            final raw =
                                                controller.text.trim();
                                            final value =
                                                double.tryParse(raw);
                                            if (value == null || value <= 0) {
                                              showCustomSnackBar(
                                                "Please enter a valid amount",
                                              );
                                              return;
                                            }
                                            Navigator.of(context).pop();
                                            _acceptOffer(value);
                                          },
                                          child: Text(
                                            'Accept',
                                            style: sansSemiBold.copyWith(
                                              color: AppColor.buttonColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                  Obx(
                    () => CustomButton(
                        text: isCheckoutLoading.value ? 'Processing...' : 'Checkout',
                        height: 40.h,
                        onPressed: isCheckoutLoading.value ? null : _checkout,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardItem(CardItem card, bool isSelected) {
    final imageUrl = _resolveImageUrl(card.images);

                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      border: Border.all(
          color: isSelected ? AppColor.buttonColor : AppColor.coolGray17,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card Image
                            Container(
            height: 120.h,
            width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColor.ghostWhite,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.r),
                topRight: Radius.circular(8.r),
              ),
                              ),
                              child: imageUrl != null && imageUrl.isNotEmpty
                                  ? ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.r),
                      topRight: Radius.circular(8.r),
                    ),
                                      child: ImageLoader(
                      url: imageUrl,
                      width: double.infinity,
                      height: 120.h,
                                        boxFit: BoxFit.cover,
                                      ),
                                    )
                : Center(
                    child: Icon(
                                      Icons.image,
                      size: 32.w,
                                      color: AppColor.coolGray21,
                                    ),
                            ),
          ),
          
                            // Card Info
          Padding(
            padding: EdgeInsets.all(8.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                  card.cardTitle ?? 'Untitled',
                                    style: sansMedium.copyWith(
                                      fontSize: 12.sp,
                                      color: AppColor.primaryColor,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    '\$${card.price ?? '0'}',
                                    style: sansSemiBold.copyWith(
                                      fontSize: 14.sp,
                                      color: AppColor.buttonColor,
                                    ),
                                  ),
                SizedBox(height: 8.h),
                Obx(() => CustomButton(
                  text: isSelected ? 'Remove' : 'Add to Deal',
                  height: 32.h,
                  color: isSelected ? AppColor.coolGray17 : AppColor.buttonColor,
                  textColor: isSelected ? AppColor.primaryColor : Colors.white,
                  onPressed: isAddingToDeal.value
                      ? null
                      : () {
                          if (isSelected) {
                            _removeFromDeal(card.id!);
                          } else {
                            _addToDeal(card);
                          }
                },
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

  String? _resolveImageUrl(dynamic images) {
    final raw = _extractRawImage(images);
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }
    return '${Constant.imageBaseUrl}$raw';
  }
}

