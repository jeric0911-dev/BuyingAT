//
// import 'dart:convert';
//
// import 'package:classified/model/pagination_model.dart';
// import 'package:classified/model/product_model.dart';
//
// MyProductModel myProductModelFromJson(String str) => MyProductModel.fromJson(json.decode(str));
//
// String myProductModelToJson(MyProductModel data) => json.encode(data.toJson());
//
// class MyProductModel {
//   final String? status;
//   final String? message;
//   final List<MyProducts>? data;
//   final Pagination? pagination;
//
//   MyProductModel({
//     this.status,
//     this.message,
//     this.data,
//     this.pagination,
//   });
//
//   factory MyProductModel.fromJson(Map<String, dynamic> json) => MyProductModel(
//     status: json["status"],
//     message: json["message"],
//     data: json["data"] == null ? [] : List<MyProducts>.from(json["data"]!.map((x) => MyProducts.fromJson(x))),
//     pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "message": message,
//     "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
//     "pagination": pagination?.toJson(),
//   };
// }
//
// class MyProducts {
//   final int? id;
//   final String? productTitle;
//   final int? userId;
//   final int? categoryId;
//   final int? subCategoryId;
//   final int? brandId;
//   final int? shopId;
//   final String? price;
//   final String? discountedPrice;
//   final String? sku;
//   final String? stock;
//   final int? isFeatured;
//   final String? status;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//   final int? ratingsCount;
//   final dynamic ratingsAvgRating;
//   final List<GetGalleryImage>? getGalleryImages;
//   final List<Color>? colors;
//   final List<dynamic>? sizes;
//   final List<dynamic>? variants;
//   final List<dynamic>? stocks;
//
//   MyProducts({
//     this.id,
//     this.productTitle,
//     this.userId,
//     this.categoryId,
//     this.subCategoryId,
//     this.brandId,
//     this.shopId,
//     this.price,
//     this.discountedPrice,
//     this.sku,
//     this.stock,
//     this.isFeatured,
//     this.status,
//     this.createdAt,
//     this.updatedAt,
//     this.ratingsCount,
//     this.ratingsAvgRating,
//     this.getGalleryImages,
//     this.colors,
//     this.sizes,
//     this.variants,
//     this.stocks,
//   });
//
//   factory MyProducts.fromJson(Map<String, dynamic> json) => MyProducts(
//     id: json["id"],
//     productTitle: json["product_title"],
//     userId: json["user_id"],
//     categoryId: json["category_id"],
//     subCategoryId: json["sub_category_id"],
//     brandId: json["brand_id"],
//     shopId: json["shop_id"],
//     price: json["price"],
//     discountedPrice: json["discounted_price"],
//     sku: json["sku"],
//     stock: json["stock"],
//     isFeatured: json["is_featured"],
//     status: json["status"],
//     createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
//     updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
//     ratingsCount: json["ratings_count"],
//     ratingsAvgRating: json["ratings_avg_rating"],
//     getGalleryImages: json["get_gallery_images"] == null ? [] : List<GetGalleryImage>.from(json["get_gallery_images"]!.map((x) => GetGalleryImage.fromJson(x))),
//     colors: json["colors"] == null ? [] : List<Color>.from(json["colors"]!.map((x) => Color.fromJson(x))),
//     sizes: json["sizes"] == null ? [] : List<dynamic>.from(json["sizes"]!.map((x) => x)),
//     variants: json["variants"] == null ? [] : List<dynamic>.from(json["variants"]!.map((x) => x)),
//     stocks: json["stocks"] == null ? [] : List<dynamic>.from(json["stocks"]!.map((x) => x)),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "product_title": productTitle,
//     "user_id": userId,
//     "category_id": categoryId,
//     "sub_category_id": subCategoryId,
//     "brand_id": brandId,
//     "shop_id": shopId,
//     "price": price,
//     "discounted_price": discountedPrice,
//     "sku": sku,
//     "stock": stock,
//     "is_featured": isFeatured,
//     "status": status,
//     "created_at": createdAt?.toIso8601String(),
//     "updated_at": updatedAt?.toIso8601String(),
//     "ratings_count": ratingsCount,
//     "ratings_avg_rating": ratingsAvgRating,
//     "get_gallery_images": getGalleryImages == null ? [] : List<dynamic>.from(getGalleryImages!.map((x) => x.toJson())),
//     "colors": colors == null ? [] : List<dynamic>.from(colors!.map((x) => x.toJson())),
//     "sizes": sizes == null ? [] : List<dynamic>.from(sizes!.map((x) => x)),
//     "variants": variants == null ? [] : List<dynamic>.from(variants!.map((x) => x)),
//     "stocks": stocks == null ? [] : List<dynamic>.from(stocks!.map((x) => x)),
//   };
// }
//
// class Color {
//   final int? id;
//   final String? color;
//   final String? colorName;
//   final int? stock;
//   final int? productId;
//   final List<dynamic>? images;
//
//   Color({
//     this.id,
//     this.color,
//     this.colorName,
//     this.stock,
//     this.productId,
//     this.images,
//   });
//
//   factory Color.fromJson(Map<String, dynamic> json) => Color(
//     id: json["id"],
//     color: json["color"],
//     colorName: json["color_name"],
//     stock: json["stock"],
//     productId: json["product_id"],
//     images: json["images"] == null ? [] : List<dynamic>.from(json["images"]!.map((x) => x)),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "color": color,
//     "color_name": colorName,
//     "stock": stock,
//     "product_id": productId,
//     "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
//   };
// }
//
//
//
//
