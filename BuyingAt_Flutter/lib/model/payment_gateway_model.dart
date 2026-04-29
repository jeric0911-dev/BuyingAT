import 'dart:convert';

PaymentGatewayModel paymentGatewayModelFromJson(String str) => PaymentGatewayModel.fromJson(json.decode(str));

String paymentGatewayModelToJson(PaymentGatewayModel data) => json.encode(data.toJson());

class PaymentGatewayModel {
  final String? status;
  final String? message;
  final List<GatewayData>? data;

  PaymentGatewayModel({
    this.status,
    this.message,
    this.data,
  });

  factory PaymentGatewayModel.fromJson(Map<String, dynamic> json) => PaymentGatewayModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<GatewayData>.from(json["data"]!.map((x) => GatewayData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class GatewayData {
  final int? id;
  final String? gatewayName;
  final String? alias;
  final String? gatewayParameters;
  final String? supportedCurrencies;
  final dynamic extras;
  final dynamic description;
  final int? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GatewayData({
    this.id,
    this.gatewayName,
    this.alias,
    this.gatewayParameters,
    this.supportedCurrencies,
    this.extras,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory GatewayData.fromJson(Map<String, dynamic> json) => GatewayData(
    id: json["id"],
    gatewayName: json["gateway_name"],
    alias: json["alias"],
    gatewayParameters: json["gateway_parameters"],
    supportedCurrencies: json["supported_currencies"],
    extras: json["extras"],
    description: json["description"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "gateway_name": gatewayName,
    "alias": alias,
    "gateway_parameters": gatewayParameters,
    "supported_currencies": supportedCurrencies,
    "extras": extras,
    "description": description,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
