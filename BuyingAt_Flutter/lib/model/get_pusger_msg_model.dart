
import 'dart:convert';

import 'get_message_model.dart';

GetPusherMsgModel getPusherMsgModelFromJson(String str) => GetPusherMsgModel.fromJson(json.decode(str));

String getPusherMsgModelToJson(GetPusherMsgModel data) => json.encode(data.toJson());

class GetPusherMsgModel {
  final String? status;
  final GetMessage? data;

  GetPusherMsgModel({
    this.status,
    this.data,
  });

  factory GetPusherMsgModel.fromJson(Map<String, dynamic> json) => GetPusherMsgModel(
    status: json["status"],
    data: json["message"] == null ? null : GetMessage.fromJson(json["message"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": data?.toJson(),
  };
}




