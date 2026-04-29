



import 'dart:convert';

import 'package:classified/model/product_model.dart';



AllMsgThreadModel allMsgThreadModelFromJson(String str) => AllMsgThreadModel.fromJson(json.decode(str));

String allMsgThreadModelToJson(AllMsgThreadModel data) => json.encode(data.toJson());

class AllMsgThreadModel {
  final String? status;
  final String? message;
  final List<AllThreadData>? data;

  AllMsgThreadModel({
    this.status,
    this.message,
    this.data,
  });

  factory AllMsgThreadModel.fromJson(Map<String, dynamic> json) => AllMsgThreadModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<AllThreadData>.from(json["data"]!.map((x) => AllThreadData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class AllThreadData {
  final int? id;
  final int? senderId;
  final int? receiverId;
  final int? productId;
  final int? buyerProfileId;
  final String? conversationType;
  final DateTime? createdAt;
  final ProductsItem? product;
  final dynamic buyerProfile; // Can be null or buyer profile data
  final dynamic sender; // Sender user data
  final dynamic receiver; // Receiver user data
  final List<dynamic>? messages; // Last message(s) from API

  AllThreadData({
    this.id,
    this.senderId,
    this.receiverId,
    this.productId,
    this.buyerProfileId,
    this.conversationType,
    this.createdAt,
    this.product,
    this.buyerProfile,
    this.sender,
    this.receiver,
    this.messages,
  });

  factory AllThreadData.fromJson(Map<String, dynamic> json) => AllThreadData(
    id: json["id"],
    senderId: json["sender_id"],
    receiverId: json["receiver_id"],
    productId: json["product_id"],
    buyerProfileId: json["buyer_profile_id"],
    conversationType: json["conversation_type"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    product: json["product"] == null ? null : ProductsItem.fromJson(json["product"]),
    buyerProfile: json["buyer_profile"],
    sender: json["sender"],
    receiver: json["receiver"],
    messages: json["messages"] == null ? null : (json["messages"] as List),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "sender_id": senderId,
    "receiver_id": receiverId,
    "product_id": productId,
    "buyer_profile_id": buyerProfileId,
    "conversation_type": conversationType,
    "created_at": createdAt?.toIso8601String(),
    "product": product?.toJson(),
    "buyer_profile": buyerProfile,
    "sender": sender,
    "receiver": receiver,
    "messages": messages,
  };
}

