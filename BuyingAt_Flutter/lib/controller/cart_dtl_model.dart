import 'dart:convert';

CartDetailsModel cartDetailsModelFromJson(String str) => CartDetailsModel.fromJson(json.decode(str));

String cartDetailsModelToJson(CartDetailsModel data) => json.encode(data.toJson());

class CartDetailsModel {
  final String? status;
  final String? message;
  final CartDtl? data;

  CartDetailsModel({
    this.status,
    this.message,
    this.data,
  });

  CartDetailsModel copyWith({
    String? status,
    String? message,
    CartDtl? data,
  }) =>
      CartDetailsModel(
        status: status ?? this.status,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory CartDetailsModel.fromJson(Map<String, dynamic> json) => CartDetailsModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : CartDtl.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class CartDtl {
  final double? totalPrice;
  final double? subTotal;
  final double? discount;
  final double? deliveryFee;
  final double? tax;
  final double? platformFee;

  CartDtl({
    this.totalPrice,
    this.subTotal,
    this.discount,
    this.deliveryFee,
    this.tax,
    this.platformFee,
  });

  CartDtl copyWith({
    double? totalPrice,
    double? subTotal,
    double? discount,
    double? deliveryFee,
    double? tax,
    double? platformFee,
  }) =>
      CartDtl(
        totalPrice: totalPrice ?? this.totalPrice,
        subTotal: subTotal ?? this.subTotal,
        discount: discount ?? this.discount,
        deliveryFee: deliveryFee ?? this.deliveryFee,
        tax: tax ?? this.tax,
        platformFee: platformFee ?? this.platformFee,
      );

  factory CartDtl.fromJson(Map<String, dynamic> json) {
    // Helper to safely convert to double
    double? toDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        return parsed;
      }
      return null;
    }

    return CartDtl(
      totalPrice: toDouble(json["total_price"]),
      subTotal: toDouble(json["sub_total"]),
      discount: toDouble(json["discount"]),
      deliveryFee: toDouble(json["delivery_fee"]),
      tax: toDouble(json["tax"]),
      platformFee: toDouble(json["platform_fee"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "total_price": totalPrice,
    "sub_total": subTotal,
    "discount": discount,
    "delivery_fee": deliveryFee,
    "tax": tax,
    "platform_fee": platformFee,
  };
}
