import 'dart:convert';

TransactionsModel transactionsModelFromJson(String str) => TransactionsModel.fromJson(json.decode(str));

String transactionsModelToJson(TransactionsModel data) => json.encode(data.toJson());

class TransactionsModel {
  final String? status;
  final String? message;
  final List<TransactionsData>? data;

  TransactionsModel({
    this.status,
    this.message,
    this.data,
  });

  factory TransactionsModel.fromJson(Map<String, dynamic> json) => TransactionsModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<TransactionsData>.from(json["data"]!.map((x) => TransactionsData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class TransactionsData {
  final int? id;
  final int? userId;
  final String? transactionId;
  final DateTime? initiated;
  final String? paymentMethod;
  final String? conversion;
  final dynamic credits;
  final String? amount;
  final String? currency;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TransactionsData({
    this.id,
    this.userId,
    this.transactionId,
    this.initiated,
    this.paymentMethod,
    this.conversion,
    this.credits,
    this.amount,
    this.currency,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory TransactionsData.fromJson(Map<String, dynamic> json) => TransactionsData(
    id: json["id"],
    userId: json["user_id"],
    transactionId: json["transaction_id"],
    initiated: json["initiated"] == null ? null : DateTime.parse(json["initiated"]),
    paymentMethod: json["payment_method"],
    conversion: json["conversion"],
    credits: json["credits"],
    amount: json["amount"],
    currency: json["currency"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "transaction_id": transactionId,
    "initiated": initiated?.toIso8601String(),
    "payment_method": paymentMethod,
    "conversion": conversion,
    "credits": credits,
    "amount": amount,
    "currency": currency,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
