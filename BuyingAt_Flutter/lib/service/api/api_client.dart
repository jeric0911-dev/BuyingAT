import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/route_manager.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import '../../routes/app_routes.dart';
import '../../transition/fade_transition.dart';
import '../../utils/session_manager.dart';

class ApiClient {
  final String appBaseUrl;
  static const String noInternetMessage = 'connection_to_api_server_failed';
  final int timeoutInSeconds = 30;

  String accessToken = '';
  late Map<String, String> _mainHeaders;

  ApiClient({required this.appBaseUrl}) {
    accessToken = SessionManager.getValue(kToken, value: '');
    updateHeader(token: accessToken);
  }

  void removeToken() {
    accessToken = '';
    updateHeader();
  }

  void updateHeader({String? token,bool? multipart}) async {
    if (accessToken.isEmpty && token != null) {
      accessToken = token;
    }
    if (multipart == true) {
      _mainHeaders = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };
    } else {
    _mainHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
    }
  }

  Future<Response> getData(
    String uri, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool isAutoLogout = true,
  }) async {
    try {
      Uri fullUri =
          Uri.parse('$appBaseUrl$uri').replace(queryParameters: query);
      if (kDebugMode) {
        debugPrint('====> API Call: $fullUri\nHeader: $_mainHeaders');
      }
      http.Response response = await http
          .get(
            fullUri,
            headers: headers ?? _mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(
        response,
        uri,
        isAutoLogout: isAutoLogout,
      );
    } catch (e) {
      debugPrint('====> $e');
      if (e is SocketException || e.toString().contains('No Internet')) {
        return Response(
          noInternetMessage,
          0,
        );
      } else {
        return Response(
          'Something went wrong! try again later',
          -1,
        );
      }
    }
  }

  Future<Response> putData(
      String uri,
      dynamic body, {
        Map<String, dynamic>? query,
        Map<String, String>? headers,
        bool? isConvert = true,
        String? differBaseUrl,
        bool isAutoLogout = false,
      }) async {
    try {
      Uri fullUri = Uri.parse((differBaseUrl ?? appBaseUrl) + uri)
          .replace(queryParameters: query);

      if (kDebugMode) {
        debugPrint('====> API PUT Call: $fullUri\nHeader: ${headers ?? _mainHeaders}');
        debugPrint('====> API Body: $body');
      }

      http.Response response = await http
          .put(
        fullUri,
        body: isConvert! ? jsonEncode(body) : body,
        headers: headers ?? _mainHeaders,
      )
          .timeout(Duration(seconds: timeoutInSeconds));

      //log('PUT Response: ${response.body}');

      return handleResponse(
        response,
        uri,
        isAutoLogout: isAutoLogout,
      );
    } catch (_) {
      return Response(noInternetMessage, 0);
    }
  }


  Future<Response> postData(
      String uri,
      dynamic body, {
        Map<String, dynamic>? query,
        Map<String, String>? headers,
        bool? isConvert = true,
        String? differBaseUrl,
        bool isAutoLogout = false,
      }) async {
    try {
      Uri fullUri = Uri.parse((differBaseUrl ?? appBaseUrl) + uri)
          .replace(queryParameters: query);

      if (kDebugMode) {
        debugPrint('====> API Call: $fullUri\nHeader: $_mainHeaders');
        debugPrint('====> API Body: $body');
      }

      http.Response response = await http
          .post(
        fullUri,
        body: isConvert! ? jsonEncode(body) : body,
        headers: headers ?? _mainHeaders,
      )
          .timeout(Duration(seconds: timeoutInSeconds));

      //log('message${response.body}');

      return handleResponse(
        response,
        uri,
        isAutoLogout: isAutoLogout,
      );
    } catch (_) {
      return Response(noInternetMessage, 0);
    }
  }


  Future<Response> deleteData(
      String uri, {
        dynamic body,
        Map<String, String>? headers,
        bool? isConvert = true,
        String? differBaseUrl,
        bool isAutoLogout = true,
      }) async {
    try {
      if (kDebugMode) {
        debugPrint('====> API Delete Call: $uri\nHeader: $_mainHeaders');
        debugPrint('====> API Delete Body: $body');
      }

      http.Request request = http.Request(
        'DELETE',
        Uri.parse((differBaseUrl ?? appBaseUrl) + uri),
      );

      request.headers.addAll(headers ?? _mainHeaders);
      if (body != null) {
        request.body = isConvert! ? jsonEncode(body) : body;
      }

      http.StreamedResponse streamedResponse = await request.send()
          .timeout(Duration(seconds: timeoutInSeconds));

      http.Response response = await http.Response.fromStream(streamedResponse);

      return handleResponse(
        response,
        uri,
        isAutoLogout: isAutoLogout,
      );
    } catch (e) {
      debugPrint('====> Delete Error: $e');
      if (e is SocketException || e.toString().contains('No Internet')) {
        return Response(
          noInternetMessage,
          0,
        );
      } else {
        return Response(
          'Something went wrong! try again later',
          -1,
        );
      }
    }
  }



  Response handleResponse(http.Response response, String uri,
      {bool isAutoLogout = true}) {
    dynamic body;
    Response response0;
    try {
      response0 = Response(
        response.body,
        response.statusCode,
      );
    } catch (_) {
      body = jsonDecode(response.body);
      response0 = Response(
        jsonEncode(body ?? response.body),
        response.statusCode,
      );
    }
    if (response0.statusCode != 200 && response0.statusCode != 201) {
      if (response0.statusCode == 401 &&
          Get.currentRoute != Routes.splashRoute) {
        if (isAutoLogout) {
          accessToken = '';
          //SessionManager.logout();
          const FadeScreenTransition(
            routeName: Routes.splashRoute,
            replace: true,
          ).navigate();
        }
      } else {
        response0 = Response(response0.body, response0.statusCode);
      }
    } else if (response0.statusCode != 200 &&
        response0.statusCode != 201 &&
        response0.body.isEmpty ) {
      response0 = Response(noInternetMessage, 0);
    }
    if (kDebugMode) {
      debugPrint(
          '====> API Response: [${response0.statusCode}] $uri\n${response0.body}');
    }
    return response0;
  }



  Future<Response> postMultipartData(
      String uri, Map<String, dynamic> body, List<MultipartBody> multipartBody,
      {Map<String, String>? headers, bool needWatermark = false}) async {
      updateHeader(token: accessToken, multipart: true);
    try {
      if (kDebugMode) {
        debugPrint('====> API Call: $uri\nHeader: $_mainHeaders');
        debugPrint('====> API Body: $body with ${multipartBody.length} files');
      }
      http.MultipartRequest request =
      http.MultipartRequest('POST', Uri.parse(appBaseUrl + uri));
      request.headers.addAll(headers ?? _mainHeaders);
      for (MultipartBody multipart in multipartBody) {
        if (multipart.file != null) {
          // if (!needWatermark) {
          String extension = multipart.file!.path.split('.').last;
          Uint8List list = await multipart.file!.readAsBytes();
          request.files.add(http.MultipartFile(
            multipart.key,
            multipart.file!.readAsBytes().asStream(),
            list.length,
            filename: '${DateTime.now().millisecondsSinceEpoch}.$extension',
            contentType: MediaType('image', 'webp'),
          ));
          // } else {
          //   // String extension = 'webp';
          //   // Uint8List? webpImageBytes =
          //   //     await FlutterImageCompress.compressWithFile(
          //   //   multipart.file!.path,
          //   //   format: CompressFormat.webp,
          //   //   quality: 95,
          //   // );
          //   // if (webpImageBytes != null) {
          //   //   request.files.add(http.MultipartFile(
          //   //     multipart.key,
          //   //     Stream.fromIterable([webpImageBytes]),
          //   //     webpImageBytes.length,
          //   //     filename: '${DateTime.now().millisecondsSinceEpoch}.$extension',
          //   //     contentType: MediaType('image', 'webp'),
          //   //   ));
          //   // }
          //
          //   String extension = 'png';
          //   Uint8List? originalImageBytes =
          //       await File(multipart.file!.path).readAsBytes();
          //   Uint8List? watermarkedImageBytes =
          //       await addWatermark(originalImageBytes);
          //
          //   if (watermarkedImageBytes != null) {
          //     request.files.add(http.MultipartFile(
          //       multipart.key,
          //       Stream.fromIterable([watermarkedImageBytes]),
          //       watermarkedImageBytes.length,
          //       filename: '${DateTime.now().millisecondsSinceEpoch}.$extension',
          //       contentType: MediaType('image', 'png'),
          //     ));
          //
          //     // img.Image watermarkedImage = img.decodeImage(watermarkedImageBytes)!;
          //     //
          //     // // Encode the image with quality set to 100 (highest quality)
          //     // Uint8List? highQualityImageBytes = img.encodeJpg(watermarkedImage, quality: 100);
          //
          //     // request.files.add(http.MultipartFile(
          //     //   multipart.key,
          //     //   Stream.fromIterable([highQualityImageBytes]),
          //     //   highQualityImageBytes.length,
          //     //   filename: '${DateTime.now().millisecondsSinceEpoch}.$extension',
          //     //   contentType: MediaType('image', 'png'),
          //     // ));
          //   }
          // }
        }
      }
      body.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      http.Response response =
      await http.Response.fromStream(await request.send());
      return handleResponse(response, uri);
    } catch (e) {
      return Response(
        noInternetMessage,
        0,
      );
    }
  }

  Future<Response> putMultipartData(
      String uri, Map<String, dynamic> body, List<MultipartBody> multipartBody,
      {Map<String, String>? headers, bool needWatermark = false}) async {
      updateHeader(token: accessToken, multipart: true);
    try {
      if (kDebugMode) {
        debugPrint('====> API PUT Multipart Call: $uri\nHeader: $_mainHeaders');
        debugPrint('====> API Body: $body with ${multipartBody.length} files');
      }
      http.MultipartRequest request =
      http.MultipartRequest('POST', Uri.parse(appBaseUrl + uri)); // Use POST with method override
      request.headers.addAll(headers ?? _mainHeaders);
      // Add method override header for PUT
      request.headers['X-HTTP-Method-Override'] = 'PUT';
      
      for (MultipartBody multipart in multipartBody) {
        if (multipart.file != null) {
          String extension = multipart.file!.path.split('.').last;
          Uint8List list = await multipart.file!.readAsBytes();
          request.files.add(http.MultipartFile(
            multipart.key,
            multipart.file!.readAsBytes().asStream(),
            list.length,
            filename: '${DateTime.now().millisecondsSinceEpoch}.$extension',
            contentType: MediaType('image', 'webp'),
          ));
        }
      }
      body.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      http.Response response =
      await http.Response.fromStream(await request.send());
      return handleResponse(response, uri);
    } catch (e) {
      return Response(
        noInternetMessage,
        0,
      );
    }
  }


}

class MultipartBody {
  String key;
  File? file;
  String? value;


  MultipartBody(this.key, this.file);
  MultipartBody.value(this.key, this.value);
}