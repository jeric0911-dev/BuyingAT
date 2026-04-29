import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../model/product_model.dart';
import '../utils/_constant.dart';
import 'package:http/http.dart' as http;

class DynamicLinkService {
  static Future<void> createDeepLink({
    required ProductsItem ads,
    BuildContext? context,
  }) async {
    final Uri deepLink = Uri.parse(
      'https://bechagiri.com/products/${ads.id}',
    );

    final String shareText = '''${ads.productTitle}

${deepLink.toString()}

Download the app for more information:
${Constant.shareLink}
''';
    try {
      SharePlus.instance.share(
        ShareParams(text: shareText, subject: shareText),
      );
    } catch (e) {
      debugPrint('Error sharing image: $e');
    }
  }

  static Future<String?> downloadImageAndReturnPath(
    String imageUrl,
    String id,
  ) async {
    try {
      PermissionStatus permission;

      // Request permissions
      if (Platform.isAndroid && (await _getAndroidVersion()) >= 33) {
        permission = await Permission.photos.request();
      } else {
        permission = await Permission.storage.request();
      }

      if (permission.isGranted) {
        String fileNameWithExtension = imageUrl.split('/').last;

        String fileName = fileNameWithExtension.split('.').first;

        final Directory tempDir = await getTemporaryDirectory();

        final String tempImagePath = '${tempDir.path}/$fileName'
            '_$id.jpg';

        final File tempImageFile = File(tempImagePath);
        if (tempImageFile.existsSync()) {
          debugPrint('Image already downloaded, reusing local file.');
          return tempImagePath;
        }

        final http.Response response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final File file = File(tempImagePath);
          await file.writeAsBytes(response.bodyBytes);
          debugPrint('Image successfully downloaded.');
          return file.path;
        } else {
          debugPrint('Failed to download image: ${response.statusCode}');
        }
      } else {
        debugPrint('Permission denied for downloading image.');
      }
    } catch (e) {
      debugPrint('Error downloading image: $e');
    }
    return null;
  }

  static Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt;
    }
    return 0;
  }
}
