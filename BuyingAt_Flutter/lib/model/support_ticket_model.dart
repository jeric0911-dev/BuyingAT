
import 'dart:convert';

SupportTicketModel supportTicketModelFromJson(String str) => SupportTicketModel.fromJson(json.decode(str));

String supportTicketModelToJson(SupportTicketModel data) => json.encode(data.toJson());

class SupportTicketModel {
  final String? status;
  final String? message;
  final List<TicketData>? data;

  SupportTicketModel({
    this.status,
    this.message,
    this.data,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) => SupportTicketModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<TicketData>.from(json["data"]!.map((x) => TicketData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class TicketData {
  final int? id;
  final int? userId;
  final String? ticketId;
  final String? subject;
  final String? priority;
  final String? message;
  final int? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TicketData({
    this.id,
    this.userId,
    this.ticketId,
    this.subject,
    this.priority,
    this.message,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory TicketData.fromJson(Map<String, dynamic> json) => TicketData(
    id: json["id"],
    userId: json["user_id"],
    ticketId: json["ticket_id"],
    subject: json["subject"],
    priority: json["priority"],
    message: json["message"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "ticket_id": ticketId,
    "subject": subject,
    "priority": priority,
    "message": message,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
