import 'dart:convert';

ShopWithCategoryModel shopWithCategoryModelFromJson(String str) => ShopWithCategoryModel.fromJson(json.decode(str));

String shopWithCategoryModelToJson(ShopWithCategoryModel data) => json.encode(data.toJson());

class ShopWithCategoryModel {
  final String? status;
  final String? message;
  final List<ShopCategoryItem>? data;

  ShopWithCategoryModel({
    this.status,
    this.message,
    this.data,
  });

  factory ShopWithCategoryModel.fromJson(Map<String, dynamic> json) => ShopWithCategoryModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<ShopCategoryItem>.from(json["data"]!.map((x) => ShopCategoryItem.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}


class ShopCategoryItem {
  final int? id;
  final int? userId;
  final String? name;
  final String? description;
  final String? categoryName;
  final dynamic status;
  final dynamic slug;
  final String? icon;
  final String? banner;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? brandName;
  final int? categoryId;
  final List<SubCategory>? subCategories;

  ShopCategoryItem( {
    this.id,
    this.categoryName,
    this.slug,
    this.icon,
    this.banner,
    this.subCategories,
    this.userId,
    this.name,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.brandName,
    this.categoryId,
  });

  factory ShopCategoryItem.fromJson(Map<String, dynamic> json) => ShopCategoryItem(
    id: json["id"],
    userId: json["user_id"],
    name: json["name"],
    categoryName: json["category_name"],
    slug: json["slug"],
    description: json["description"],
    status: json["status"],
    icon: json["icon"],
    banner: json["banner"],
    brandName: json["brand_name"],
    categoryId: json["category_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    subCategories: json["sub_categories"] == null ? [] : List<SubCategory>.from(json["sub_categories"]!.map((x) => SubCategory.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "name": name,
    "description": description,
    "status": status,
    "category_name": categoryName,
    "brand_name": brandName,
    "category_id": categoryId,
    "slug": slug,
    "icon": icon,
    "banner": banner,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "sub_categories": subCategories == null ? [] : List<dynamic>.from(subCategories!.map((x) => x.toJson())),
  };
}

class SubCategory {
  final int? id;
  final String? subCategoryName;
  final int? categoryId;
  final dynamic slug;
  final String? icon;
  final String? banner;
  final List<dynamic>? childCategories;

  SubCategory({
    this.id,
    this.subCategoryName,
    this.categoryId,
    this.slug,
    this.icon,
    this.banner,
    this.childCategories,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) => SubCategory(
    id: json["id"],
    subCategoryName: json["sub_category_name"],
    categoryId: json["category_id"],
    slug: json["slug"],
    icon: json["icon"],
    banner: json["banner"],
    childCategories: json["child_categories"] == null ? [] : List<dynamic>.from(json["child_categories"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "sub_category_name": subCategoryName,
    "category_id": categoryId,
    "slug": slug,
    "icon": icon,
    "banner": banner,
    "child_categories": childCategories == null ? [] : List<dynamic>.from(childCategories!.map((x) => x)),
  };


}
