// import 'dart:convert';
//
// ShopDataModel shopDataModelFromJson(String str) => ShopDataModel.fromJson(json.decode(str));
//
// String shopDataModelToJson(ShopDataModel data) => json.encode(data.toJson());
//
// class ShopDataModel {
//   final String? status;
//   final String? message;
//   final List<ShopData>? data;
//
//   ShopDataModel({
//     this.status,
//     this.message,
//     this.data,
//   });
//
//   factory ShopDataModel.fromJson(Map<String, dynamic> json) => ShopDataModel(
//     status: json["status"],
//     message: json["message"],
//     data: json["data"] == null ? [] : List<ShopData>.from(json["data"]!.map((x) => ShopData.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "message": message,
//     "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
//   };
// }
//
// class ShopData {
//   final int? id;
//   final int? userId;
//   final String? name;
//   final String? slug;
//   final String? description;
//   final String? banner;
//   final String? status;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//   final String? brandName;
//   final int? categoryId;
//   final String? icon;
//
//   ShopData({
//     this.id,
//     this.userId,
//     this.name,
//     this.slug,
//     this.description,
//     this.banner,
//     this.status,
//     this.createdAt,
//     this.updatedAt,
//     this.brandName,
//     this.categoryId,
//     this.icon,
//   });
//
//   factory ShopData.fromJson(Map<String, dynamic> json) => ShopData(
//     id: json["id"],
//     userId: json["user_id"],
//     name: json["name"],
//     slug: json["slug"],
//     description: json["description"],
//     banner: json["banner"],
//     status: json["status"],
//     createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
//     updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
//     brandName: json["brand_name"],
//     categoryId: json["category_id"],
//     icon: json["icon"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "user_id": userId,
//     "name": name,
//     "slug": slug,
//     "description": description,
//     "banner": banner,
//     "status": status,
//     "brand_name": brandName,
//     "category_id": categoryId,
//     "icon": icon,
//     "created_at": createdAt?.toIso8601String(),
//     "updated_at": updatedAt?.toIso8601String(),
//   };
// }
