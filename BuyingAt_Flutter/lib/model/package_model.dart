import 'dart:convert';

PackageModel packageModelFromJson(String str) => PackageModel.fromJson(json.decode(str));

String packageModelToJson(PackageModel data) => json.encode(data.toJson());

class PackageModel {
  final String? status;
  final String? message;
  final List<PackageData>? data;

  PackageModel({
    this.status,
    this.message,
    this.data,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) => PackageModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<PackageData>.from(json["data"]!.map((x) => PackageData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class PackageData {
  final int? id;
  final String? title;
  final int? duration;
  final int? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Package>? packages;

  PackageData({
    this.id,
    this.title,
    this.duration,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.packages,
  });

  factory PackageData.fromJson(Map<String, dynamic> json) => PackageData(
    id: json["id"],
    title: json["title"],
    duration: json["duration"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    packages: json["packages"] == null ? [] : List<Package>.from(json["packages"]!.map((x) => Package.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "duration": duration,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "packages": packages == null ? [] : List<dynamic>.from(packages!.map((x) => x.toJson())),
  };
}

class Package {
  final int? id;
  final int? packageCategoryId;
  final String? title;
  final String? price;
  final String? productCount;
  final String? advertCount;
  final int? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<PackageAdvantage>? packageAdvantage;

  Package({
    this.id,
    this.packageCategoryId,
    this.title,
    this.price,
    this.productCount,
    this.advertCount,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.packageAdvantage,
  });

  factory Package.fromJson(Map<String, dynamic> json) => Package(
    id: json["id"],
    packageCategoryId: json["package_category_id"],
    title: json["title"],
    price: json["price"],
    productCount: json["product_count"],
    advertCount: json["advert_count"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    packageAdvantage: json["package_advantage"] == null ? [] : List<PackageAdvantage>.from(json["package_advantage"]!.map((x) => PackageAdvantage.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "package_category_id": packageCategoryId,
    "title": title,
    "price": price,
    "product_count": productCount,
    "advert_count": advertCount,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "package_advantage": packageAdvantage == null ? [] : List<dynamic>.from(packageAdvantage!.map((x) => x.toJson())),
  };
}

class PackageAdvantage {
  final int? id;
  final int? packageId;
  final String? title;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PackageAdvantage({
    this.id,
    this.packageId,
    this.title,
    this.createdAt,
    this.updatedAt,
  });

  factory PackageAdvantage.fromJson(Map<String, dynamic> json) => PackageAdvantage(
    id: json["id"],
    packageId: json["package_id"],
    title: json["title"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "package_id": packageId,
    "title": title,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
