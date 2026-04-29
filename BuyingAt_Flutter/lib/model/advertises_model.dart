import 'dart:convert';

AdvertisesModel advertisesModelFromJson(String str) => AdvertisesModel.fromJson(json.decode(str));

String advertisesModelToJson(AdvertisesModel data) => json.encode(data.toJson());

class AdvertisesModel {
  final String? status;
  final String? message;
  final AdvertisesItem? data;

  AdvertisesModel({
    this.status,
    this.message,
    this.data,
  });

  factory AdvertisesModel.fromJson(Map<String, dynamic> json) => AdvertisesModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : AdvertisesItem.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class AdvertisesItem {
  final int? id;
  final String? img1;
  final String? link1;
  final String? img2;
  final String? link2;
  final String? img3;
  final String? link3;
  final String? img4;
  final String? link4;
  final String? img5;
  final String? link5;
  final String? img6;
  final String? link6;
  final String? img7;
  final String? link7;
  final String? img8;
  final String? link8;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AdvertisesItem({
    this.id,
    this.img1,
    this.link1,
    this.img2,
    this.link2,
    this.img3,
    this.link3,
    this.img4,
    this.link4,
    this.img5,
    this.link5,
    this.img6,
    this.link6,
    this.img7,
    this.link7,
    this.img8,
    this.link8,
    this.createdAt,
    this.updatedAt,
  });

  factory AdvertisesItem.fromJson(Map<String, dynamic> json) => AdvertisesItem(
    id: json["id"],
    img1: json["img_1"],
    link1: json["link_1"],
    img2: json["img_2"],
    link2: json["link_2"],
    img3: json["img_3"],
    link3: json["link_3"],
    img4: json["img_4"],
    link4: json["link_4"],
    img5: json["img_5"],
    link5: json["link_5"],
    img6: json["img_6"],
    link6: json["link_6"],
    img7: json["img_7"],
    link7: json["link_7"],
    img8: json["img_8"],
    link8: json["link_8"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "img_1": img1,
    "link_1": link1,
    "img_2": img2,
    "link_2": link2,
    "img_3": img3,
    "link_3": link3,
    "img_4": img4,
    "link_4": link4,
    "img_5": img5,
    "link_5": link5,
    "img_6": img6,
    "link_6": link6,
    "img_7": img7,
    "link_7": link7,
    "img_8": img8,
    "link_8": link8,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
