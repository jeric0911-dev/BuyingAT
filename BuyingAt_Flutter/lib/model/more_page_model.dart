import 'dart:convert';

MorePageModel morePageModelFromJson(String str) => MorePageModel.fromJson(json.decode(str));

String morePageModelToJson(MorePageModel data) => json.encode(data.toJson());

class MorePageModel {
  final String? status;
  final String? message;
  final List<MorePageData>? data;

  MorePageModel({
    this.status,
    this.message,
    this.data,
  });

  factory MorePageModel.fromJson(Map<String, dynamic> json) => MorePageModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<MorePageData>.from(json["data"]!.map((x) => MorePageData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class MorePageData {
  final int? id;
  final String? title;
  final dynamic banner;
  final String? content;
  final String? slug;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MorePageData({
    this.id,
    this.title,
    this.banner,
    this.content,
    this.slug,
    this.createdAt,
    this.updatedAt,
  });

  factory MorePageData.fromJson(Map<String, dynamic> json) => MorePageData(
    id: json["id"],
    title: json["title"],
    banner: json["banner"],
    content: json["content"],
    slug: json["slug"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "banner": banner,
    "content": content,
    "slug": slug,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
