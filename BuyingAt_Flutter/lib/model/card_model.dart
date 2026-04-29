import 'dart:convert';

BrowseCardsModel browseCardsModelFromJson(String str) => BrowseCardsModel.fromJson(json.decode(str));
String browseCardsModelToJson(BrowseCardsModel data) => json.encode(data.toJson());

class BrowseCardsModel {
  final String? status;
  final String? message;
  final BrowseCardsData? data;

  BrowseCardsModel({
    this.status,
    this.message,
    this.data,
  });

  factory BrowseCardsModel.fromJson(Map<String, dynamic> json) => BrowseCardsModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : BrowseCardsData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class BrowseCardsData {
  final List<CardItem>? data;
  final Pagination? pagination;

  BrowseCardsData({
    this.data,
    this.pagination,
  });

  factory BrowseCardsData.fromJson(Map<String, dynamic> json) => BrowseCardsData(
    data: json["data"] == null ? null : List<CardItem>.from(json["data"].map((x) => CardItem.fromJson(x))),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? null : List<dynamic>.from(data!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class CardItem {
  final int? id;
  final int? cardRequestId;
  final int? sellerInventoryId;
  final int? cardId;
  final String? requestStatus;
  final String? cardTitle;
  final String? description;
  final String? price;
  final String? priceType;
  final String? condition;
  final String? grade;
  final String? sportType;
  final String? weight;
  final dynamic images; // Can be String, List, or null
  final CardSeller? seller;
  final bool? isPromoted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CardItem({
    this.id,
    this.cardRequestId,
    this.sellerInventoryId,
    this.cardId,
    this.requestStatus,
    this.cardTitle,
    this.description,
    this.price,
    this.priceType,
    this.condition,
    this.grade,
    this.sportType,
    this.weight,
    this.images,
    this.seller,
    this.isPromoted,
    this.createdAt,
    this.updatedAt,
  });

  factory CardItem.fromJson(Map<String, dynamic> json) => CardItem(
    id: json["id"],
    cardRequestId: json["card_request_id"],
    sellerInventoryId: json["seller_inventory_id"],
    cardId: json["card_id"],
    requestStatus: json["request_status"],
    cardTitle: json["card_title"],
    description: json["description"],
    price: json["price"],
    priceType: json["price_type"],
    condition: json["condition"],
    grade: json["grade"],
    sportType: json["sport_type"],
    weight: json["weight"],
    images: json["images"] is String 
        ? json["images"] 
        : (json["images"] is List 
            ? jsonEncode(json["images"]) 
            : json["images"]?.toString()),
    seller: json["seller"] == null ? null : CardSeller.fromJson(json["seller"]),
    isPromoted: json["is_promoted"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "card_request_id": cardRequestId,
    "seller_inventory_id": sellerInventoryId,
    "card_id": cardId,
    "request_status": requestStatus,
    "card_title": cardTitle,
    "description": description,
    "price": price,
    "price_type": priceType,
    "condition": condition,
    "grade": grade,
    "sport_type": sportType,
    "weight": weight,
    "images": images,
    "seller": seller?.toJson(),
    "is_promoted": isPromoted,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class CardSeller {
  final int? id;
  final String? name;
  final String? email;

  CardSeller({
    this.id,
    this.name,
    this.email,
  });

  factory CardSeller.fromJson(Map<String, dynamic> json) => CardSeller(
    id: json["id"],
    name: json["name"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
  };
}

class Pagination {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;

  Pagination({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"],
    lastPage: json["last_page"],
    perPage: json["per_page"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "last_page": lastPage,
    "per_page": perPage,
    "total": total,
  };
}

