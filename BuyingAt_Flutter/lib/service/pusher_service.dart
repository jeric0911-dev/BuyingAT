import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PusherService {
   PusherChannelsFlutter? _pusher;

  final Map<String, List<void Function(PusherEvent)>> _eventBindings = {};

  Future<void> initialize({
    required String apiKey,
    required String cluster,
    void Function(dynamic currentState, dynamic previousState)?
    onConnectionStateChange,
    void Function(String message, int? code, dynamic e)? onError,
    void Function(String channelName, dynamic data)? onSubscriptionSucceeded,
    void Function(String message, dynamic e)? onSubscriptionError,
    void Function(String event, String reason)? onDecryptionFailure,
    void Function(String channelName, PusherMember member)? onMemberAdded,
    void Function(String channelName, PusherMember member)? onMemberRemoved,
    void Function(String channelName, int subscriptionCount)?
    onSubscriptionCount,
  }) async {
    _pusher = PusherChannelsFlutter.getInstance();

    await _pusher?.init(
      apiKey: apiKey,
      cluster: cluster,
      onConnectionStateChange: onConnectionStateChange,
      onError: onError,
      onSubscriptionSucceeded: onSubscriptionSucceeded,
      onSubscriptionError: onSubscriptionError,
      onDecryptionFailure: onDecryptionFailure,
      onMemberAdded: onMemberAdded,
      onMemberRemoved: onMemberRemoved,
      onSubscriptionCount: onSubscriptionCount,
      onEvent: (PusherEvent event) {
        if (_eventBindings.containsKey(event.eventName)) {
          for (var callback in _eventBindings[event.eventName]!) {
            callback(event);
          }
        }
      },
    );
  }

  Future<void> subscribe(String channelName) async {
    await _pusher?.subscribe(channelName: channelName);
  }

  Future<void> connect() async {
    await _pusher?.connect();
  }

  Future<void> disconnect() async {
    // if (_pusher != null) {
      await _pusher?.disconnect();
    // }
  }

  Future<void> unsubscribe(String channelName) async {
    await _pusher?.unsubscribe(channelName: channelName);
  }

  Future<void> trigger({
    required String channelName,
    required String eventName,
    required String data,
  }) async {
    await _pusher?.trigger(PusherEvent(
      channelName: channelName,
      eventName: eventName,
      data: data,
    ));
  }

  void bindEvent(String eventName, void Function(PusherEvent event) callback) {
    _eventBindings.putIfAbsent(eventName, () => []);
    _eventBindings[eventName]!.add(callback);
  }

  // void unbindEvent(
  //     String eventName, void Function(PusherEvent event) callback) {
  //   if (_eventBindings.containsKey(eventName)) {
  //     _eventBindings[eventName]!.remove(callback);
  //     if (_eventBindings[eventName]!.isEmpty) {
  //       _eventBindings.remove(eventName);
  //     }
  //   }
  // }

  void unbindEvent(String eventName) {
    _eventBindings.remove(eventName);
  }

  String get connectionState => _pusher!.connectionState;
}