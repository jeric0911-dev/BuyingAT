import 'dart:convert';

import 'package:classified/model/product_model.dart';

import 'customer_order_model.dart';


ProductsModel productsModelFromJson(String str) => ProductsModel.fromJson(json.decode(str));

String productsModelToJson(ProductsModel data) => json.encode(data.toJson());

class ProductsModel {
  final String? status;
  final String? message;
  final List<ProductsItem>? data;
  final Pagination? pagination;
  ProductsModel({
    this.status,
    this.message,
    this.data,
    this.pagination,
  });

  factory ProductsModel.fromJson(Map<String, dynamic> json) => ProductsModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<ProductsItem>.from(json["data"]!.map((x) => ProductsItem.fromJson(x))),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}




