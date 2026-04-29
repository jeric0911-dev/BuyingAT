import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../model/get_all_msg_thread_model.dart';
import '../model/get_message_model.dart';
import '../model/get_pusger_msg_model.dart';
import '../routes/app_routes.dart';
import '../service/api/api_client.dart';
import '../service/api/api_retry_manager.dart';
import '../service/pusher_service.dart';
import '../transition/fade_transition.dart';
import '../utils/_constant.dart';
import '../utils/session_manager.dart';
import '../widget/custom_snackbar_widget.dart';

class MessageController extends GetxController {
  late PusherService _pusherService ;
  ApiClient apiClient;

  MessageController({required this.apiClient});

  var selectedIndex = (-1).obs;
  var conversationId = 0.obs;
  var userId = 0.obs;
  final TextEditingController messageTxt = TextEditingController();
  final FocusNode fMessageTxt = FocusNode();
  var isTextEmpty = true.obs;
  late dynamic myId;
  late ScrollController scrollController;
  @override
  void onInit() {
    super.onInit();
    myId = SessionManager.getValue(kUserId).toString();
    _pusherService = PusherService();
    messageTxt.addListener(() {
      isTextEmpty.value = messageTxt.text.isEmpty;
    });
    scrollController = ScrollController();
    ever(getMessageList, (_) {
      Future.delayed(Duration(milliseconds: 100), () {
        scrollToBottom();
      });
    });
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  var getPusherMsg = GetMessage().obs;
  Future<void> initPusher() async {
    String channel = 'conversation.$conversationId';
    await _pusherService.initialize(
      apiKey: "8e108a5a09a3ae23f441",
      cluster: "ap2",
      onConnectionStateChange: (current, previous) {
        debugPrint("Pusher connection state: $current");
      },
      onError: (message, code, e) {
        debugPrint("Pusher error: $message, code: $code, exception: $e");
      },
      onSubscriptionSucceeded: (channelName, data) {
        debugPrint("Subscribed to $channelName");
      },
    );
    await _pusherService.subscribe(channel);
    await _pusherService.connect();

    _pusherService.bindEvent("message.sent", (PusherEvent event) {
      if (event.data != null) {
        try {
           GetPusherMsgModel getMessageModel = getPusherMsgModelFromJson(event.data!);
          if (getMessageModel.data != null && getMessageModel.data?.userId != int.parse(myId)) {
            //getMessageList.add(getMessageModel.data!);
            if (!getMessageList.any((msg) => msg.id == getMessageModel.data!.id)) {
              getMessageList.insert(0, getMessageModel.data!);
            }

            scrollToBottom();
          }

        } catch (_) {

        }
      }
    });
  }
  /// create message thread for product/card
  var isLoading = false.obs;
  Future<int?> createMsgThread({
    bool isReload = false,
    required dynamic senderId,
    required dynamic receiverId,
    dynamic productId,
    dynamic buyerProfileId,
    String conversationType = 'product',
    bool shouldNavigate = true,
  }) async {
    isLoading.value = true;
    Map<String, dynamic> body = {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'conversation_type': conversationType,
    };

    if (conversationType == 'product') {
      body['product_id'] = productId;
    } else if (conversationType == 'buyer_profile') {
      body['buyer_profile_id'] = buyerProfileId;
    }

    try {
      http.Response response = await apiClient.postData(
        Constant.createMsgThreadUrl,
        body,
      );

      final statusCode = response.statusCode;
      final bodyString = response.body;

      if (statusCode == 200 || statusCode == 201) {
        try {
          final json = jsonDecode(bodyString);
          if (json['status'] == 'success' && json['data'] != null) {
            final dynamic responseId = json['data']['id'];
            final int? conversationIdValue = responseId is int
                ? responseId
                : int.tryParse(responseId.toString());

            if (conversationIdValue != null) {
              conversationId.value = conversationIdValue;

              if (shouldNavigate) {
                // Navigate to messenger screen with the conversation
                FadeScreenTransition(
                  routeName: Routes.messengerScreenRoute,
                  arguments: {'conversationId': conversationIdValue},
                ).navigate();
              }

              return conversationIdValue;
            }
          } else {
            // Backend responded with non-success status even though HTTP was OK
            final message = json['message']?.toString() ??
                'Failed to create conversation thread';
            showCustomSnackBar(message);
          }
        } catch (e) {
          print("Error parsing conversation thread response: $e");
          print("Response body: $bodyString");
          showCustomSnackBar("Failed to start chat. Please try again.");
        }
      } else {
        // Non-200/201 HTTP status – surface backend error message
        try {
          final json = jsonDecode(bodyString);
          final backendMessage = json['message']?.toString();
          String fallback;

          if (statusCode == 401) {
            fallback = 'You are not logged in. Please log in again to start a chat.';
          } else if (statusCode == 422) {
            fallback = 'The chat request was invalid. Please try again or refresh.';
          } else if (statusCode >= 500) {
            fallback = 'Server error while starting chat. Please try again later.';
          } else {
            fallback = 'Failed to create conversation (Status: $statusCode)';
          }

          final message = backendMessage?.isNotEmpty == true
              ? backendMessage
              : fallback;

          showCustomSnackBar(message);
          print("Conversation thread error ($statusCode): $bodyString");
        } catch (_) {
          showCustomSnackBar(
              "Failed to create conversation (Status: $statusCode)");
          print("Conversation thread error ($statusCode): $bodyString");
        }
      }
    } catch (e) {
      print("Error creating conversation thread: $e");
      apiRetryManager.addRequest(() {});
      showCustomSnackBar("Failed to create conversation: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }

    return null;
  }

  /// Create buyer profile conversation
  Future<void> createBuyerProfileConversation({
    required dynamic senderId,
    required dynamic receiverId,
    required dynamic buyerProfileId,
  }) async {
    await createMsgThread(
      senderId: senderId,
      receiverId: receiverId,
      buyerProfileId: buyerProfileId,
      conversationType: 'buyer_profile',
    );
  }

  /// create msg
  var createMessageList = <GetMessage>[].obs;
  Future<void> createMessage({
    bool isReload = false,
    dynamic id,
    String? customMessage,
    int? customConversationId,
  }) async {
    if (isReload) {}

    final String message = (customMessage ?? messageTxt.text).trim();
    if (message.isEmpty) {
      return;
    }

    final int conversation = customConversationId ?? conversationId.value;
    if (conversation == 0) {
      return;
    }

    var body = {
      'conversation_id': conversation,
      'message': message,
    };

    if (customMessage == null) {
    messageTxt.clear();
    }
    try {
      http.Response? response = await apiClient.postData(
          Constant.createMsgUrl,body
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (customMessage == null) {
        messageTxt.clear();
        }
      }
    } catch (e) {

      apiRetryManager.addRequest(() {});
    } finally {

    }
  }

  /// get msg
  var getMessageList = <GetMessage>[].obs;
  var getMsgLoading = false.obs;
  Future<void> getMessage({bool isReload = false}) async {
    if (isReload) {
      getMessageList.clear();
    }
    getMsgLoading.value = true;

    try {
      http.Response? response = await apiClient.getData(
          "${Constant.getMsgUrl}/${conversationId.value}"
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        GetMessageModel getMessageModel = getMessageModelFromJson(response.body);
        getMessageList.value = (getMessageModel.data ?? []);
      }
    } catch (_) {

      apiRetryManager.addRequest(() {});
    } finally {
      getMsgLoading.value = false;
    }
  }

/// fetch all Msg Thread
  var getAllMsgThreadList = <AllThreadData>[].obs;
  var getMsgThreadLoading = false.obs;
  Future<void> getAllMsgThread({bool isReload = false}) async {
    // Prevent multiple simultaneous calls
    if (getMsgThreadLoading.value) {
      return;
    }
    
    if (isReload) {}
    getMsgThreadLoading.value = true;
    try {
      http.Response? response = await apiClient.getData(
        Constant.getAllMsgThreadUrl,
      );
      if (response.statusCode == 200) {
        AllMsgThreadModel allMsgThreadModel = allMsgThreadModelFromJson(response.body);
        getAllMsgThreadList.value = allMsgThreadModel.data ?? [];
      } else {
        // Handle non-200 status codes
        print("Failed to load conversations: ${response.statusCode}");
        getAllMsgThreadList.value = [];
      }
    } catch (e) {
      print("Error fetching conversations: $e");
      // Don't retry on timeout - just set empty list
      if (e.toString().contains('TimeoutException')) {
        getAllMsgThreadList.value = [];
      } else {
      apiRetryManager.addRequest(() {});
      }
    } finally {
      getMsgThreadLoading.value = false;
    }
  }

  @override
  void onClose() {
    _pusherService.disconnect();
    _pusherService.unbindEvent("my-event");
    _pusherService.unsubscribe('my-channel.$myId');
      super.onClose();
  }
}