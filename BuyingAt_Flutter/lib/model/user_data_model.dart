import 'dart:convert';

UserdataModel userdataModelFromJson(String str) => UserdataModel.fromJson(json.decode(str));
String userdataModelToJson(UserdataModel data) => json.encode(data.toJson());

class UserdataModel {
  final String? status;
  final String? message;
  final UserData? data;

  UserdataModel({
    this.status,
    this.message,
    this.data,
  });

  factory UserdataModel.fromJson(Map<String, dynamic> json) => UserdataModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : UserData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class UserData {
  final int? id;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? companyName;
  final String? address;
  final dynamic userName;
  final String? email;
  final String? seconderyEmail;
  final String? phone;
  final dynamic emailVerifiedAt;
  final dynamic isNumberVerified;
  final String? userType;
  final int? countryId;
  final int? stateId;
  final int? cityId;
  final String? zipCode;
  final String? profileImg;
  final dynamic googleId;
  final dynamic facebookId;
  final dynamic locationLat;
  final dynamic locationLong;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? status;
  final String? passwordResetOtp;
  final DateTime? passwordResetExpiresAt;
  final Shop? shop;
  final UserPackage? userPackage;
  final Wallet? wallet;
  final int? totalOrders;
  final int? completedOrders;
  final int? pendingOrders;
  final String? role;

  UserData({
    this.id,
    this.name,
    this.firstName,
    this.lastName,
    this.companyName,
    this.address,
    this.userName,
    this.email,
    this.seconderyEmail,
    this.phone,
    this.emailVerifiedAt,
    this.isNumberVerified,
    this.userType,
    this.countryId,
    this.stateId,
    this.cityId,
    this.zipCode,
    this.profileImg,
    this.googleId,
    this.facebookId,
    this.locationLat,
    this.locationLong,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.passwordResetOtp,
    this.passwordResetExpiresAt,
    this.shop,
    this.userPackage,
    this.wallet,
    this.totalOrders,
    this.completedOrders,
    this.pendingOrders,
    this.role,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    id: json["id"],
    name: json["name"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    companyName: json["company_name"],
    address: json["address"],
    userName: json["user_name"],
    email: json["email"],
    seconderyEmail: json["secondery_email"],
    phone: json["phone"],
    emailVerifiedAt: json["email_verified_at"],
    isNumberVerified: json["is_number_verified"],
    userType: json["user_type"],
    countryId: json["country_id"],
    stateId: json["state_id"],
    cityId: json["city_id"],
    zipCode: json["zip_code"],
    profileImg: json["profile_img"],
    googleId: json["google_id"],
    facebookId: json["facebook_id"],
    locationLat: json["location_lat"],
    locationLong: json["location_long"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    status: json["status"],
    passwordResetOtp: json["password_reset_otp"],
    passwordResetExpiresAt: json["password_reset_expires_at"] == null ? null : DateTime.parse(json["password_reset_expires_at"]),
    shop: json["shop"] == null ? null : Shop.fromJson(json["shop"]),
    userPackage: json["user_package"] == null ? null : UserPackage.fromJson(json["user_package"]),
    wallet: json["wallet"] == null ? null : Wallet.fromJson(json["wallet"]),
    totalOrders: json["total_orders"],
    completedOrders: json["completed_orders"],
    pendingOrders: json["pending_orders"],
    role: json["role"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "first_name": firstName,
    "last_name": lastName,
    "company_name": companyName,
    "address": address,
    "user_name": userName,
    "email": email,
    "secondery_email": seconderyEmail,
    "phone": phone,
    "email_verified_at": emailVerifiedAt,
    "is_number_verified": isNumberVerified,
    "user_type": userType,
    "country_id": countryId,
    "state_id": stateId,
    "city_id": cityId,
    "zip_code": zipCode,
    "profile_img": profileImg,
    "google_id": googleId,
    "facebook_id": facebookId,
    "location_lat": locationLat,
    "location_long": locationLong,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "status": status,
    "password_reset_otp": passwordResetOtp,
    "password_reset_expires_at": passwordResetExpiresAt?.toIso8601String(),
    "shop": shop?.toJson(),
    "user_package": userPackage?.toJson(),
    "wallet": wallet?.toJson(),
    "total_orders": totalOrders,
    "completed_orders": completedOrders,
    "pending_orders": pendingOrders,
    "role": role,
  };
}

class Shop {
  final int? id;
  final int? userId;
  final String? name;
  final String? slug;
  final String? description;
  final String? banner;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Shop({
    this.id,
    this.userId,
    this.name,
    this.slug,
    this.description,
    this.banner,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
    id: json["id"],
    userId: json["user_id"],
    name: json["name"],
    slug: json["slug"],
    description: json["description"],
    banner: json["banner"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "name": name,
    "slug": slug,
    "description": description,
    "banner": banner,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class UserPackage {
  final int? id;
  final int? userId;
  final int? packageId;
  final String? price;
  final String? packageName;
  final int? duration;
  final int? productCount;
  final DateTime? packageStartDate;
  final DateTime? packageEndDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserPackage({
    this.id,
    this.userId,
    this.packageId,
    this.price,
    this.packageName,
    this.duration,
    this.productCount,
    this.packageStartDate,
    this.packageEndDate,
    this.createdAt,
    this.updatedAt,
  });

  factory UserPackage.fromJson(Map<String, dynamic> json) => UserPackage(
    id: json["id"],
    userId: json["user_id"],
    packageId: json["package_id"],
    price: json["price"],
    packageName: json["package_name"],
    duration: json["duration"],
    productCount: json["product_count"],
    packageStartDate: json["package_start_date"] == null ? null : DateTime.parse(json["package_start_date"]),
    packageEndDate: json["package_end_date"] == null ? null : DateTime.parse(json["package_end_date"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "package_id": packageId,
    "price": price,
    "package_name": packageName,
    "duration": duration,
    "product_count": productCount,
    "package_start_date": "${packageStartDate!.year.toString().padLeft(4, '0')}-${packageStartDate!.month.toString().padLeft(2, '0')}-${packageStartDate!.day.toString().padLeft(2, '0')}",
    "package_end_date": "${packageEndDate!.year.toString().padLeft(4, '0')}-${packageEndDate!.month.toString().padLeft(2, '0')}-${packageEndDate!.day.toString().padLeft(2, '0')}",
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class Wallet {
  final int? id;
  final int? userId;
  final String? balance;
  final String? expense;
  final String? lastRecharge;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Wallet({
    this.id,
    this.userId,
    this.balance,
    this.expense,
    this.lastRecharge,
    this.createdAt,
    this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
    id: json["id"],
    userId: json["user_id"],
    balance: json["balance"],
    expense: json["expense"],
    lastRecharge: json["last_recharge"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "balance": balance,
    "expense": expense,
    "last_recharge": lastRecharge,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
