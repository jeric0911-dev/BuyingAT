// To parse this JSON data, do
//
//     final cartProductModel = cartProductModelFromJson(jsonString);

import 'dart:convert';

import 'package:classified/model/product_model.dart';

CartProductModel cartProductModelFromJson(String str) => CartProductModel.fromJson(json.decode(str));

String cartProductModelToJson(CartProductModel data) => json.encode(data.toJson());

class CartProductModel {
  final String? status;
  final String? message;
  final List<CartProduct>? data;

  CartProductModel({
    this.status,
    this.message,
    this.data,
  });

  factory CartProductModel.fromJson(Map<String, dynamic> json) => CartProductModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<CartProduct>.from(json["data"]!.map((x) => CartProduct.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class CartProduct {
  final int? id;
  final int? customerId;
  final int? productId;
  final String? sku;
  final dynamic variantId;
  final dynamic colorId;
  final dynamic sizeId;
  final int? vendorId;
  final dynamic size;
  final dynamic color;
  final int? quantity;
  final dynamic variant;
  final ProductsItem? product;

  CartProduct({
    this.id,
    this.customerId,
    this.productId,
    this.sku,
    this.variantId,
    this.colorId,
    this.sizeId,
    this.vendorId,
    this.size,
    this.color,
    this.quantity,
    this.variant,
    this.product,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) => CartProduct(
    id: json["id"],
    customerId: json["customer_id"],
    productId: json["product_id"],
    sku: json["sku"],
    variantId: json["variant_id"],
    colorId: json["color_id"],
    sizeId: json["size_id"],
    vendorId: json["vendor_id"],
    size: json["size"],
    color: json["color"],
    quantity: json["quantity"],
    variant: json["variant"],
    product: json["product"] == null ? null : ProductsItem.fromJson(json["product"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "customer_id": customerId,
    "product_id": productId,
    "sku": sku,
    "variant_id": variantId,
    "color_id": colorId,
    "size_id": sizeId,
    "vendor_id": vendorId,
    "size": size,
    "color": color,
    "quantity": quantity,
    "variant": variant,
    "product": product?.toJson(),
  };
}

