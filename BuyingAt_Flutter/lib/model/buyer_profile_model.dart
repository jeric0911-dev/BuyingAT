import 'dart:convert';

BuyerProfileModel buyerProfileModelFromJson(String str) => BuyerProfileModel.fromJson(json.decode(str));
String buyerProfileModelToJson(BuyerProfileModel data) => json.encode(data.toJson());

class BuyerProfileModel {
  final String? status;
  final String? message;
  final List<BuyerProfile>? data;

  BuyerProfileModel({
    this.status,
    this.message,
    this.data,
  });

  factory BuyerProfileModel.fromJson(Map<String, dynamic> json) => BuyerProfileModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null 
        ? null 
        : List<BuyerProfile>.from(json["data"].map((x) => BuyerProfile.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? null : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class BuyerProfile {
  final int? id;
  final int? userId;
  final List<String>? categories;
  final String? preferences;
  final double? budgetMin;
  final double? budgetMax;
  final String? profileLink;
  final List<BuyerTag>? buyerTags;
  final BuyerProfileUser? user;
  final bool? isVerifiedBuyer;
  final bool? isExempt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BuyerProfile({
    this.id,
    this.userId,
    this.categories,
    this.preferences,
    this.budgetMin,
    this.budgetMax,
    this.profileLink,
    this.buyerTags,
    this.user,
    this.isVerifiedBuyer,
    this.isExempt,
    this.createdAt,
    this.updatedAt,
  });

  factory BuyerProfile.fromJson(Map<String, dynamic> json) => BuyerProfile(
    id: json["id"],
    userId: json["user_id"],
    categories: json["categories"] == null 
        ? null 
        : List<String>.from(json["categories"].map((x) => x)),
    preferences: json["preferences"],
    budgetMin: json["budget_min"] == null 
        ? null 
        : (json["budget_min"] is String 
            ? double.tryParse(json["budget_min"]) 
            : (json["budget_min"] is num 
                ? json["budget_min"].toDouble() 
                : null)),
    budgetMax: json["budget_max"] == null 
        ? null 
        : (json["budget_max"] is String 
            ? double.tryParse(json["budget_max"]) 
            : (json["budget_max"] is num 
                ? json["budget_max"].toDouble() 
                : null)),
    profileLink: json["profile_link"],
    buyerTags: json["buyer_tags"] == null 
        ? null 
        : List<BuyerTag>.from(json["buyer_tags"].map((x) => BuyerTag.fromJson(x))),
    user: json["user"] == null ? null : BuyerProfileUser.fromJson(json["user"]),
    isVerifiedBuyer: json["is_verified_buyer"],
    isExempt: json["is_exempt"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "categories": categories == null ? null : List<dynamic>.from(categories!.map((x) => x)),
    "preferences": preferences,
    "budget_min": budgetMin,
    "budget_max": budgetMax,
    "profile_link": profileLink,
    "buyer_tags": buyerTags == null ? null : List<dynamic>.from(buyerTags!.map((x) => x.toJson())),
    "user": user?.toJson(),
    "is_verified_buyer": isVerifiedBuyer,
    "is_exempt": isExempt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class BuyerTag {
  final int? id;
  final int? buyerProfileId;
  final String? tagName;
  final String? tagType;
  final String? cardCondition;
  final int? purchaseVolume;
  final String? budgetTier;

  BuyerTag({
    this.id,
    this.buyerProfileId,
    this.tagName,
    this.tagType,
    this.cardCondition,
    this.purchaseVolume,
    this.budgetTier,
  });

  factory BuyerTag.fromJson(Map<String, dynamic> json) => BuyerTag(
    id: json["id"],
    buyerProfileId: json["buyer_profile_id"],
    tagName: json["tag_name"],
    tagType: json["tag_type"],
    cardCondition: json["card_condition"],
    purchaseVolume: json["purchase_volume"],
    budgetTier: json["budget_tier"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "buyer_profile_id": buyerProfileId,
    "tag_name": tagName,
    "tag_type": tagType,
    "card_condition": cardCondition,
    "purchase_volume": purchaseVolume,
    "budget_tier": budgetTier,
  };
}

class BuyerProfileUser {
  final int? id;
  final String? name;
  final String? email;
  final BuyerProfileUserProfile? profile;

  BuyerProfileUser({
    this.id,
    this.name,
    this.email,
    this.profile,
  });

  factory BuyerProfileUser.fromJson(Map<String, dynamic> json) => BuyerProfileUser(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    profile: json["profile"] == null ? null : BuyerProfileUserProfile.fromJson(json["profile"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "profile": profile?.toJson(),
  };
}

class BuyerProfileUserProfile {
  final int? id;
  final int? userId;
  final String? username;
  final String? bio;
  final String? avatar;

  BuyerProfileUserProfile({
    this.id,
    this.userId,
    this.username,
    this.bio,
    this.avatar,
  });

  factory BuyerProfileUserProfile.fromJson(Map<String, dynamic> json) => BuyerProfileUserProfile(
    id: json["id"],
    userId: json["user_id"],
    username: json["username"],
    bio: json["bio"],
    avatar: json["avatar"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "username": username,
    "bio": bio,
    "avatar": avatar,
  };
}

