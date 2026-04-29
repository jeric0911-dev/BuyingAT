// To parse this JSON data, do
//
//     final bannerModel = bannerModelFromJson(jsonString);

import 'dart:convert';

BannerModel bannerModelFromJson(String str) => BannerModel.fromJson(json.decode(str));

String bannerModelToJson(BannerModel data) => json.encode(data.toJson());

class BannerModel {
  final String? status;
  final String? message;
  final List<BannerItem>? data;

  BannerModel({
    this.status,
    this.message,
    this.data,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<BannerItem>.from(json["data"]!.map((x) => BannerItem.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class BannerItem {
  final int? id;
  final String? img;
  final String? link;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BannerItem({
    this.id,
    this.img,
    this.link,
    this.createdAt,
    this.updatedAt,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) => BannerItem(
    id: json["id"],
    img: json["img"],
    link: json["link"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "img": img,
    "link": link,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
