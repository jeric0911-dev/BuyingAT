import 'dart:convert';

CountryCityModel countryCityModelFromJson(String str) => CountryCityModel.fromJson(json.decode(str));

String countryCityModelToJson(CountryCityModel data) => json.encode(data.toJson());

class CountryCityModel {
  final String? status;
  final String? message;
  final List<CountryCityData>? data;

  CountryCityModel({
    this.status,
    this.message,
    this.data,
  });

  factory CountryCityModel.fromJson(Map<String, dynamic> json) => CountryCityModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<CountryCityData>.from(json["data"]!.map((x) => CountryCityData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class CountryCityData {
  final int? id;
  final String? status;
  final String? countryName;
  final dynamic isoCode;
  final dynamic phoneCode;
  final int? countryId;
  final dynamic stateId;
  final String? cityName;
  final String? lat;
  final String? long;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CountryCityData({
    this.id,
    this.status,
    this.countryName,
    this.isoCode,
    this.phoneCode,
    this.countryId,
    this.stateId,
    this.cityName,
    this.lat,
    this.long,
    this.createdAt,
    this.updatedAt,
  });

  factory CountryCityData.fromJson(Map<String, dynamic> json) => CountryCityData(
    id: json["id"],
    status: json["status"],
    countryName: json["country_name"],
    isoCode: json["iso_code"],
    phoneCode: json["phone_code"],
    countryId: json["country_id"],
    stateId: json["state_id"],
    cityName: json["city_name"],
    lat: json["lat"],
    long: json["long"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "country_name": countryName,
    "iso_code": isoCode,
    "phone_code": phoneCode,
    "country_id": countryId,
    "state_id": stateId,
    "city_name": cityName,
    "lat": lat,
    "long": long,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
