import 'package:classified/controller/navigation_controller.dart';
import 'package:classified/utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controller/message_controller.dart';
import '../../model/get_message_model.dart';
import '../../model/get_all_msg_thread_model.dart';
import '../../routes/app_routes.dart';
import '../../utils/_constant.dart';
import '../../utils/app_color.dart';
import '../../utils/app_image.dart';
import '../../utils/app_text.dart';
import '../../utils/image_loader.dart';
import 'dart:convert';
import '../../utils/session_manager.dart';
import '../../widget/chat_heads_widget.dart';
import '../../widget/custom_app_bar.dart';
import '../../widget/deal_builder_widget.dart';

class MessengerScreen extends StatefulWidget {
  const MessengerScreen({super.key});
  @override
  MessengerScreenState createState() => MessengerScreenState();
}

class MessengerScreenState extends State<MessengerScreen> {
  late MessageController messageController;
  late dynamic myId;
  bool _showDealBuilder = false;
  @override
  void initState() {
    super.initState();
    messageController = Get.find<MessageController>();
    //messageController.getAllMsgThread();
    myId = SessionManager.getValue(kUserId);
    initializeData();
  }


  Future<void> initializeData() async {
    // Get conversationId from navigation arguments (required)
    final args = Get.arguments as Map<String, dynamic>?;
    final conversationIdArg = args?['conversationId'];
    final conversationIdValue = conversationIdArg is int
        ? conversationIdArg
        : int.tryParse(conversationIdArg?.toString() ?? '');

    if (conversationIdValue == null) {
      // No conversation ID provided, go back to chat list
      Get.back();
      return;
    }

    // Clear previous messages when opening a new conversation
    messageController.getMessageList.clear();

    // Reset deal builder state when loading new conversation
    _showDealBuilder = false;

    // Set conversationId immediately so getMessage can use it
    messageController.conversationId.value = conversationIdValue;

    // Load conversations to find the selected one (in parallel with getting messages)
    final loadThreadsFuture = messageController.getAllMsgThread();

    // Start loading messages immediately with the conversationId
    final loadMessagesFuture = messageController.getMessage(isReload: true);

    // Wait for both to complete
    await Future.wait([loadThreadsFuture, loadMessagesFuture]);

    // Find the conversation by ID to set up Pusher and userId
    AllThreadData? conversation;
    try {
      conversation = messageController.getAllMsgThreadList.firstWhere(
        (conv) => conv.id == conversationIdValue,
      );
    } catch (e) {
      conversation = null;
    }

    if (conversation != null) {
      final myId = SessionManager.getValue(kUserId);
      messageController.userId.value = (conversation.senderId == myId) 
          ? conversation.receiverId! 
          : conversation.senderId!;
      messageController.initPusher();

      if (mounted) {
        setState(() {
          _showDealBuilder = false;
        });
      }
    }
  }

  void _handleSendMessage(dynamic myId) {
    final text = messageController.messageTxt.text.trim();
    if (text.isEmpty) return;

    final newMessage = GetMessage(
      userId: myId,
      message: text,
      conversationId: messageController.conversationId.value,
      createdAt: DateTime.now(),
    );

    messageController.createMessage(id: myId);
    messageController.getMessageList.insert(0, newMessage);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_showDealBuilder,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop && _showDealBuilder) {
          // If Add to Deal is open, close it instead of leaving the chat
          setState(() {
            _showDealBuilder = false;
          });
        }
      },
      child: Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(
          title: _showDealBuilder ? 'Add to Deal' : AppText.chat,
          isBackButtonExist: !_showDealBuilder,
        action: IconButton(
          icon: Icon(
            _showDealBuilder ? Icons.close : Icons.menu,
            color: AppColor.primaryColor,
          ),
          onPressed: () {
            setState(() {
              _showDealBuilder = !_showDealBuilder;
            });
          },
        ),
        onTapBack: () {
          messageController.fMessageTxt.unfocus();
            // Always navigate back to the previous screen if possible,
            // otherwise go to the chat list screen explicitly.
            if (Get.previousRoute.isNotEmpty) {
              Get.back();
            } else {
              Get.offNamed(Routes.chatListScreenRoute);
            }
        },
      ),
      body: Obx(() {
        // Find the current conversation
        final conversationId = messageController.conversationId.value;
        AllThreadData? selectedConversation;
        try {
          selectedConversation = messageController.getAllMsgThreadList.firstWhere(
            (conv) => conv.id == conversationId,
          );
        } catch (e) {
          selectedConversation = null;
        }

        if (selectedConversation == null && messageController.getAllMsgThreadList.isNotEmpty) {
          // Try to get from arguments
          final args = Get.arguments as Map<String, dynamic>?;
          final conversationIdArg = args?['conversationId'];
          if (conversationIdArg != null) {
            try {
              selectedConversation = messageController.getAllMsgThreadList.firstWhere(
                (conv) => conv.id == conversationIdArg,
              );
          } catch (e) {
              // Not found
            }
          }
        }

        final conversationType = selectedConversation?.conversationType ?? 'product';
        final isProductChat = conversationType == 'product';

        // Show loading indicator if conversation is being initialized or messages are loading
        if (messageController.conversationId.value == 0 || 
            (messageController.getMsgLoading.value && messageController.getMessageList.isEmpty)) {
          return Center(
            child: CircularProgressIndicator(color: AppColor.buttonColor, strokeWidth: 2,),
          );
        }

        // When deal builder is open, show it as a full-screen panel instead of a sidebar
        if (_showDealBuilder && selectedConversation != null && conversationId > 0) {
          return DealBuilderWidget(
            conversationId: conversationId,
            conversationType: conversationType,
            sellerId: selectedConversation.receiverId, // Seller is the receiver in product chats
            currentUserId: myId,
            messages: messageController.getMessageList.map((m) => {
              'message': m.message,
              'user_id': m.userId,
            }).toList(),
            onBackToChat: () {
              if (mounted) {
                setState(() {
                  _showDealBuilder = false;
                });
              }
            },
          );
        }

        // Default: show chat UI
        return Column(
            children: [
              Flexible(
                child: Obx(() {
                  // Show loading indicator while messages are being fetched
                  if (messageController.getMsgLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(color: AppColor.buttonColor, strokeWidth: 2,),
                    );
                  }
                  
                  // Show empty state if no messages and not loading
                  if (messageController.getMessageList.isEmpty && 
                      messageController.conversationId.value > 0) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No messages yet',
                            style: sansReg.copyWith(
                              color: AppColor.coolGray21,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    reverse: true,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: messageController.getMessageList.length,
                    itemBuilder: (context, index) {
                      final item = messageController.getMessageList[index];
                      final userId = item.userId;
                      return Align(
                        alignment:
                        userId == myId ? Alignment.centerRight : Alignment.centerLeft,
                        child:
                        userId == myId
                            ? Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 10.h,
                          ),
                          margin: EdgeInsets.only(
                            left: 100.w,
                            top: 5.h,
                            bottom: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.buttonColor5.withValues(alpha: .20),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.r),
                              topRight: Radius.circular(20.r),
                              bottomLeft: Radius.circular(20.r),
                            ),
                          ),
                          child: _buildMessageContent(item),
                        )
                            : Row(
                          children: [
                            // Avatar removed - no longer showing avatar in chat messages
                            Flexible(
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.w,
                                      vertical: 10.h,
                                    ),
                                    margin: EdgeInsets.only(right: 60.w),
                                    decoration: BoxDecoration(
                                      color: AppColor.coolGray20,
                                      borderRadius: (index == 0 || messageController.getMessageList[index - 1].userId != item.userId) ? BorderRadius.only(
                                        topLeft: Radius.circular(20.r),
                                        topRight: Radius.circular(20.r),
                                        bottomRight: Radius.circular(20.r),
                                      ) : BorderRadius.only(
                                        topLeft: Radius.circular(20.r),
                                        topRight: Radius.circular(20.r),
                                        bottomRight: Radius.circular(20.r),
                                        bottomLeft: Radius.circular(20.r),
                                      ),
                                    ),
                                    child: _buildMessageContent(item),
                                  ),
                                  SizedBox(height: 10.h,),
                                ],
                              ),
                            ),

                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            if (messageController.conversationId.value > 0)
              Container(
                height: 56.h,
                padding: EdgeInsets.symmetric(horizontal: 22.w),
                margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 24.h),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  border: Border.all(color: AppColor.coolGray17),
                  borderRadius: BorderRadius.circular(28.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController.messageTxt,
                        focusNode: messageController.fMessageTxt,
                        cursorColor: AppColor.textColor,
                        cursorHeight: 18.h,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) {
                          _handleSendMessage(myId);
                        },
                        decoration: InputDecoration(
                          hintText: AppText.sendMessage,
                          hintStyle: sansReg.copyWith(
                              color: AppColor.coolGray21),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _handleSendMessage(myId);
                      },
                      child: SvgPicture.asset(
                          AppImage.icSend, colorFilter: messageController
                          .isTextEmpty.value ? null : ColorFilter
                          .mode(AppColor.buttonColor, BlendMode.srcIn)),
                    ),
                  ],
                ),
              ),
            ],
        );
      }),
      ),
    );
  }

  Widget _buildMessageContent(GetMessage item) {
    final messageText = item.message?.toString() ?? '';
    
    // Try to parse as JSON to check if it's a structured deal-related message
    try {
      final parsed = jsonDecode(messageText);
      if (parsed is Map) {
        if (parsed['type'] == 'deal_item' && parsed['item'] != null) {
          final dealItem = parsed['item'];
    return Container(
            padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
              color: AppColor.ghostWhite,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColor.buttonColor, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shopping_cart, size: 16.w, color: AppColor.buttonColor),
                    SizedBox(width: 8.w),
                    Text(
                      'Added to deal',
                      style: sansSemiBold.copyWith(
                        fontSize: 12.sp,
                        color: AppColor.buttonColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  dealItem['title']?.toString() ?? 'Card',
                  style: sansMedium.copyWith(
                    fontSize: 14.sp,
                    color: AppColor.primaryColor,
                  ),
                ),
                if (dealItem['price'] != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    '\$${dealItem['price']}',
                    style: sansSemiBold.copyWith(
                      fontSize: 14.sp,
                      color: AppColor.buttonColor,
                    ),
                  ),
                ],
              ],
            ),
          );
        } else if (parsed['type'] == 'deal_item_removed') {
          return Container(
            padding: EdgeInsets.all(8.w),
            child: Text(
              'Removed from deal',
              style: sansReg.copyWith(
                fontSize: 12.sp,
                color: AppColor.coolGray21,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        } else if (parsed['type'] == 'deal_offer') {
          final amount = parsed['amount'];
          final status = (parsed['status'] ?? '').toString();
          final cardIds = parsed['card_ids'];
          final cardCount = cardIds is List ? cardIds.length : null;

          String title;
          if (status == 'accepted') {
            title = 'Offer accepted';
          } else {
            title = 'Offer';
          }

          String subtitle = '';
          if (amount != null) {
            subtitle = '\$${amount.toString()}';
            if (cardCount != null && cardCount > 0) {
              subtitle += ' for $cardCount card(s)';
            }
          }

          return Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColor.ghostWhite,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColor.buttonColor, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_offer,
                        size: 16.w, color: AppColor.buttonColor),
                    SizedBox(width: 8.w),
                    Text(
                      title,
                      style: sansSemiBold.copyWith(
                        fontSize: 12.sp,
                        color: AppColor.buttonColor,
                      ),
                    ),
                  ],
                ),
                if (subtitle.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    subtitle,
                    style: sansMedium.copyWith(
                      fontSize: 14.sp,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ],
              ],
            ),
          );
        }
        }
    } catch (e) {
      // Not JSON, treat as regular message
    }
    
    // Regular text message
    return Text(
      messageText,
      style: sansReg.copyWith(
        color: item.userId == myId ? AppColor.buttonColor : AppColor.coolGray11,
        height: 1.3.h,
        fontSize: 16.sp,
      ),
    );
  }
}
