import 'dart:convert';

import 'package:classified/model/product_model.dart';

WishListModel wishListModelFromJson(String str) => WishListModel.fromJson(json.decode(str));

String wishListModelToJson(WishListModel data) => json.encode(data.toJson());

class WishListModel {
  final String? status;
  final String? message;
  final List<WishlistData>? data;

  WishListModel({
    this.status,
    this.message,
    this.data,
  });

  factory WishListModel.fromJson(Map<String, dynamic> json) => WishListModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<WishlistData>.from(json["data"]!.map((x) => WishlistData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class WishlistData {
  final int? id;
  final int? productId;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ProductsItem? product;

  WishlistData({
    this.id,
    this.productId,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.product,
  });

  factory WishlistData.fromJson(Map<String, dynamic> json) => WishlistData(
    id: json["id"],
    productId: json["product_id"],
    userId: json["user_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    product: json["product"] == null ? null : ProductsItem.fromJson(json["product"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_id": productId,
    "user_id": userId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "product": product?.toJson(),
  };
}


