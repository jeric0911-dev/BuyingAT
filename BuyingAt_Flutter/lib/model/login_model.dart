
import 'dart:convert';

LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  final String? status;
  final String? message;
  final UserInfo? data;

  LoginModel({
    this.status,
    this.message,
    this.data,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : UserInfo.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class UserInfo {
  final User? user;
  final String? token;

  UserInfo({
    this.user,
    this.token,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "user": user?.toJson(),
    "token": token,
  };
}

class User {
  final int? id;
  final String? name;
  final dynamic userName;
  final String? email;
  final dynamic seconderyEmail;
  final String? phone;
  final dynamic emailVerifiedAt;
  final dynamic isNumberVerified;
  final String? userType;
  final int? countryId;
  final int? stateId;
  final int? cityId;
  final String? zipCode;
  final dynamic profileImg;
  final dynamic googleId;
  final dynamic facebookId;
  final int? status;
  final dynamic passwordResetOtp;
  final dynamic passwordResetExpiresAt;

  User({
    this.id,
    this.name,
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
    this.status,
    this.passwordResetOtp,
    this.passwordResetExpiresAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
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
    status: json["status"],
    passwordResetOtp: json["password_reset_otp"],
    passwordResetExpiresAt: json["password_reset_expires_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
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
    "status": status,
    "password_reset_otp": passwordResetOtp,
    "password_reset_expires_at": passwordResetExpiresAt,
  };
}
