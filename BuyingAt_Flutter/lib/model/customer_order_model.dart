
import 'dart:convert';

import 'package:classified/model/product_model.dart';

CustomerOrderModel customerOrderModelFromJson(String str) => CustomerOrderModel.fromJson(json.decode(str));

String customerOrderModelToJson(CustomerOrderModel data) => json.encode(data.toJson());

class CustomerOrderModel {
  final String? status;
  final String? message;
  final List<CustomerOrder>? data;
  final Pagination? pagination;

  CustomerOrderModel({
    this.status,
    this.message,
    this.data,
    this.pagination,
  });

  factory CustomerOrderModel.fromJson(Map<String, dynamic> json) => CustomerOrderModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<CustomerOrder>.from(json["data"]!.map((x) => CustomerOrder.fromJson(x))),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),

  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class CustomerOrder {
  final int? id;
  final String? orderId;
  final int? customerId;
  final int? vendorId;
  final String? amount;
  final dynamic taxAmount;
  final dynamic couponId;
  final dynamic couponDiscount;
  final String? paymentStatus;
  final String? orderStatus;
  final dynamic paymentMethodId;
  final dynamic transactionReference;
  final String? deliveryAddress;
  final dynamic estimatedDeliveryDate;
  final dynamic deliveryStatus;
  final dynamic deliveryCharge;
  final String? orderNote;
  final dynamic orderTracking;
  final int? quantity;
  final dynamic productVariation;
  final String? productSize;
  final String? productColor;
  final dynamic deliveryManId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
   final List<OrderedItem>? orderedItems;
  final List<OrderStatusDetail>? orderStatusDetail;

  CustomerOrder({
    this.id,
    this.orderId,
    this.customerId,
    this.vendorId,
    this.amount,
    this.taxAmount,
    this.couponId,
    this.couponDiscount,
    this.paymentStatus,
    this.orderStatus,
    this.paymentMethodId,
    this.transactionReference,
    this.deliveryAddress,
    this.estimatedDeliveryDate,
    this.deliveryStatus,
    this.deliveryCharge,
    this.orderNote,
    this.orderTracking,
    this.quantity,
    this.productVariation,
    this.productSize,
    this.productColor,
    this.deliveryManId,
    this.createdAt,
    this.updatedAt,
     this.orderedItems,
    this.orderStatusDetail,
  });

  factory CustomerOrder.fromJson(Map<String, dynamic> json) => CustomerOrder(
    id: json["id"],
    orderId: json["order_id"],
    customerId: json["customer_id"],
    vendorId: json["vendor_id"],
    amount: json["amount"],
    taxAmount: json["tax_amount"],
    couponId: json["coupon_id"],
    couponDiscount: json["coupon_discount"],
    paymentStatus: json["payment_status"],
    orderStatus: json["order_status"],
    paymentMethodId: json["payment_method_id"],
    transactionReference: json["transaction_reference"],
    deliveryAddress: json["delivery_address"],
    estimatedDeliveryDate: json["estimated_delivery_date"],
    deliveryStatus: json["delivery_status"],
    deliveryCharge: json["delivery_charge"],
    orderNote: json["order_note"],
    orderTracking: json["order_tracking"],
    quantity: json["quantity"],
    productVariation: json["product_variation"],
    productSize: json["product_size"],
    productColor: json["product_color"],
    deliveryManId: json["delivery_man_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
     orderedItems: json["ordered_items"] == null ? [] : List<OrderedItem>.from(json["ordered_items"]!.map((x) => OrderedItem.fromJson(x))),
    orderStatusDetail: json["order_status_detail"] == null ? [] : List<OrderStatusDetail>.from(json["order_status_detail"]!.map((x) => OrderStatusDetail.fromJson(x))),

  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "customer_id": customerId,
    "vendor_id": vendorId,
    "amount": amount,
    "tax_amount": taxAmount,
    "coupon_id": couponId,
    "coupon_discount": couponDiscount,
    "payment_status": paymentStatus,
    "order_status": orderStatus,
    "payment_method_id": paymentMethodId,
    "transaction_reference": transactionReference,
    "delivery_address": deliveryAddress,
    "estimated_delivery_date": estimatedDeliveryDate,
    "delivery_status": deliveryStatus,
    "delivery_charge": deliveryCharge,
    "order_note": orderNote,
    "order_tracking": orderTracking,
    "quantity": quantity,
    "product_variation": productVariation,
    "product_size": productSize,
    "product_color": productColor,
    "delivery_man_id": deliveryManId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "ordered_items": orderedItems == null ? [] : List<dynamic>.from(orderedItems!.map((x) => x.toJson())),
    "order_status_detail": orderStatusDetail == null ? [] : List<dynamic>.from(orderStatusDetail!.map((x) => x.toJson())),
  };
}

class OrderedItem {
  final int? id;
  final int? orderId;
  final int? productId;
  final String? sku;
  final dynamic variantId;
  final int? colorId;
  final int? sizeId;
  final int? quantity;
  final String? price;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? productSize;
  final String? productColor;
  final String? productVariant;
  final ProductsItem? product;

  OrderedItem({
    this.id,
    this.orderId,
    this.productId,
    this.sku,
    this.variantId,
    this.colorId,
    this.sizeId,
    this.quantity,
    this.price,
    this.createdAt,
    this.updatedAt,
    this.productSize,
    this.productColor,
    this.productVariant,
    this.product,
  });

  factory OrderedItem.fromJson(Map<String, dynamic> json) => OrderedItem(
    id: json["id"],
    orderId: json["order_id"],
    productId: json["product_id"],
    sku: json["sku"],
    variantId: json["variant_id"],
    colorId: json["color_id"],
    sizeId: json["size_id"],
    quantity: json["quantity"],
    price: json["price"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    productSize: json["product_size"],
    productColor: json["product_color"],
    productVariant: json["product_variant"],
    product: json["product"] == null ? null : ProductsItem.fromJson(json["product"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "product_id": productId,
    "sku": sku,
    "variant_id": variantId,
    "color_id": colorId,
    "size_id": sizeId,
    "quantity": quantity,
    "price": price,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "product_size": productSize,
    "product_color": productColor,
    "product_variant": productVariant,
    "product": product?.toJson(),
  };
}

/*class Product {
  final int? id;
  final String? productTitle;
  final int? userId;
  final dynamic listingTypeId;
  final int? categoryId;
  final int? subCategoryId;
  final dynamic childCategoryId;
  final int? brandId;
  final int? shopId;
  final String? productDescription;
  final String? additionalInfo;
  final dynamic slugUrl;
  final String? stock;
  final String? sku;
  final String? price;
  final String? discountedPrice;
  final dynamic discountPercent;
  final dynamic shippingClass;
  final dynamic deliveryTime;
  final dynamic tags;
  final String? status;
  final bool? isFavorite;
  final int? isFeatured;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<GetGalleryImage>? getGalleryImages;

  Product({
    this.id,
    this.productTitle,
    this.userId,
    this.listingTypeId,
    this.categoryId,
    this.subCategoryId,
    this.childCategoryId,
    this.brandId,
    this.shopId,
    this.productDescription,
    this.additionalInfo,
    this.slugUrl,
    this.stock,
    this.sku,
    this.price,
    this.discountedPrice,
    this.discountPercent,
    this.shippingClass,
    this.deliveryTime,
    this.tags,
    this.status,
    this.isFavorite,
    this.isFeatured,
    this.createdAt,
    this.updatedAt,
    this.getGalleryImages,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    productTitle: json["product_title"],
    userId: json["user_id"],
    listingTypeId: json["listing_type_id"],
    categoryId: json["category_id"],
    subCategoryId: json["sub_category_id"],
    childCategoryId: json["child_category_id"],
    brandId: json["brand_id"],
    shopId: json["shop_id"],
    productDescription: json["product_description"],
    additionalInfo: json["additional_info"],
    slugUrl: json["slug_url"],
    stock: json["stock"],
    sku: json["sku"],
    price: json["price"],
    discountedPrice: json["discounted_price"],
    discountPercent: json["discount_percent"],
    shippingClass: json["shipping_class"],
    deliveryTime: json["delivery_time"],
    tags: json["tags"],
    status: json["status"],
    isFavorite: json["is_favorite"],
    isFeatured: json["is_featured"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    getGalleryImages: json["get_gallery_images"] == null ? [] : List<GetGalleryImage>.from(json["get_gallery_images"]!.map((x) => GetGalleryImage.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_title": productTitle,
    "user_id": userId,
    "listing_type_id": listingTypeId,
    "category_id": categoryId,
    "sub_category_id": subCategoryId,
    "child_category_id": childCategoryId,
    "brand_id": brandId,
    "shop_id": shopId,
    "product_description": productDescription,
    "additional_info": additionalInfo,
    "slug_url": slugUrl,
    "stock": stock,
    "sku": sku,
    "price": price,
    "discounted_price": discountedPrice,
    "discount_percent": discountPercent,
    "shipping_class": shippingClass,
    "delivery_time": deliveryTime,
    "tags": tags,
    "status": status,
    "is_favorite": isFavorite,
    "is_featured": isFeatured,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "get_gallery_images": getGalleryImages == null ? [] : List<dynamic>.from(getGalleryImages!.map((x) => x.toJson())),
  };
}*/



class Pagination {
  final int? currentPage;
  final int? perPage;
  final int? total;
  final int? lastPage;

  Pagination({
    this.currentPage,
    this.perPage,
    this.total,
    this.lastPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"],
    perPage: json["per_page"],
    total: json["total"],
    lastPage: json["last_page"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "per_page": perPage,
    "total": total,
    "last_page": lastPage,
  };
}

class OrderStatusDetail {
  final int? id;
  final int? orderId;
  final String? status;
  final String? message;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderStatusDetail({
    this.id,
    this.orderId,
    this.status,
    this.message,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderStatusDetail.fromJson(Map<String, dynamic> json) => OrderStatusDetail(
    id: json["id"],
    orderId: json["order_id"],
    status: json["status"],
    message: json["message"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "status": status,
    "message": message,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}