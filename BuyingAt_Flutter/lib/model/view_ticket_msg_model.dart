import 'dart:convert';

ViewSupportMsgModel viewSupportMsgModelFromJson(String str) => ViewSupportMsgModel.fromJson(json.decode(str));

String viewSupportMsgModelToJson(ViewSupportMsgModel data) => json.encode(data.toJson());

class ViewSupportMsgModel {
  final String? status;
  final String? message;
  final List<ViewSupportMsg>? data;

  ViewSupportMsgModel({
    this.status,
    this.message,
    this.data,
  });

  factory ViewSupportMsgModel.fromJson(Map<String, dynamic> json) => ViewSupportMsgModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<ViewSupportMsg>.from(json["data"]!.map((x) => ViewSupportMsg.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class ViewSupportMsg {
  final int? id;
  final int? ticketId;
  final int? userId;
  final String? message;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Attachment>? attachments;
  final SupportTicket? supportTicket;
  final User? user;

  ViewSupportMsg({
    this.id,
    this.ticketId,
    this.userId,
    this.message,
    this.createdAt,
    this.updatedAt,
    this.attachments,
    this.supportTicket,
    this.user,
  });

  factory ViewSupportMsg.fromJson(Map<String, dynamic> json) => ViewSupportMsg(
    id: json["id"],
    ticketId: json["ticket_id"],
    userId: json["user_id"],
    message: json["message"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    attachments: json["attachments"] == null ? [] : List<Attachment>.from(json["attachments"]!.map((x) => Attachment.fromJson(x))),
    supportTicket: json["support_ticket"] == null ? null : SupportTicket.fromJson(json["support_ticket"]),
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ticket_id": ticketId,
    "user_id": userId,
    "message": message,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "attachments": attachments == null ? [] : List<dynamic>.from(attachments!.map((x) => x.toJson())),
    "support_ticket": supportTicket?.toJson(),
    "user": user?.toJson(),
  };
}

class Attachment {
  final int? id;
  final int? ticketId;
  final int? userId;
  final int? messageId;
  final String? file;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Attachment({
    this.id,
    this.ticketId,
    this.userId,
    this.messageId,
    this.file,
    this.createdAt,
    this.updatedAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
    id: json["id"],
    ticketId: json["ticket_id"],
    userId: json["user_id"],
    messageId: json["message_id"],
    file: json["file"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ticket_id": ticketId,
    "user_id": userId,
    "message_id": messageId,
    "file": file,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class SupportTicket {
  final int? id;
  final String? ticketId;
  final int? status;

  SupportTicket({
    this.id,
    this.ticketId,
    this.status,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) => SupportTicket(
    id: json["id"],
    ticketId: json["ticket_id"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ticket_id": ticketId,
    "status": status,
  };
}

class User {
  final int? id;
  final String? name;

  User({
    this.id,
    this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
