
import 'dart:convert';

GetMessageModel getMessageModelFromJson(String str) => GetMessageModel.fromJson(json.decode(str));

String getMessageModelToJson(GetMessageModel data) => json.encode(data.toJson());

class GetMessageModel {
  final String? status;
  final String? message;
  final List<GetMessage>? data;

  GetMessageModel({
    this.status,
    this.message,
    this.data,
  });

  factory GetMessageModel.fromJson(Map<String, dynamic> json) => GetMessageModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<GetMessage>.from(json["data"]!.map((x) => GetMessage.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class GetMessage {
  final int? id;
  final int? conversationId;
  final int? userId;
  final String? message;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final User? user;
  GetMessage({
    this.id,
    this.conversationId,
    this.userId,
    this.message,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory GetMessage.fromJson(Map<String, dynamic> json) => GetMessage(
    id: json["id"],
    conversationId: json["conversation_id"],
    userId: json["user_id"],
    message: json["message"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "conversation_id": conversationId,
    "user_id": userId,
    "message": message,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "user": user?.toJson(),
  };
}
class User {
  final int? id;
  final String? name;
  final String? userImg;

  User({
    this.id,
    this.name,
    this.userImg,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    userImg: json["user_img"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "user_img": userImg,
  };
}