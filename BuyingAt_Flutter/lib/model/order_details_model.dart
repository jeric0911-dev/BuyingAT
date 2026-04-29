import 'dart:convert';

import 'customer_order_model.dart';

OrderDetailsModel orderDetailsModelFromJson(String str) => OrderDetailsModel.fromJson(json.decode(str));

String orderDetailsModelToJson(OrderDetailsModel data) => json.encode(data.toJson());

class OrderDetailsModel {
  final String? status;
  final String? message;
  final CustomerOrder? data;

  OrderDetailsModel({
    this.status,
    this.message,
    this.data,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) => OrderDetailsModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : CustomerOrder.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

