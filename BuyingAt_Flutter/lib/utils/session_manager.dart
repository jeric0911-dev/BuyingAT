import 'dart:ui';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

const kIsLOGIN = "is_login";
const kToken = 'user_token';
const kUserName = 'user_name';
const kUserPhone = 'user_phone';
const kUserEmail = 'user_email';
const kUserId = 'user_id';
const kCountryCode = 'country_code';
const kLanguageCodeTr = 'language_code_tr';
const kCountryCodeTr = 'country_code_tr';
const kUserPassword = 'user_password';
const kUserPackage = 'user_package';
const kPackageId = 'package_id';
const kUserImage = 'user_image';
const kPackageEndDate = 'package_date';

class SessionManager {
  static GetStorage _preferences = GetStorage();

  static Future init() async => _preferences = GetStorage();

  static setValue(String key, dynamic value) {
    _preferences.write(key, value);
  }

  static dynamic getValue(String key, {dynamic value}) {
    return _preferences.read(key) ?? value;
  }

  static dynamic removeValue(String key) {
    return _preferences.remove(key);
  }

  static dynamic logout() async {
    // await _preferences.erase();
    await removeValue(kIsLOGIN);
    await removeValue(kToken);
  }

  static Future<void> setLocale(String languageCode, String countryCode) async {
    await setValue(kLanguageCodeTr, languageCode);
    await setValue(kCountryCodeTr, countryCode);
    Get.updateLocale(Locale(languageCode, countryCode));
  }

  static Locale? getLocale() {
    final languageCode = getValue(kLanguageCodeTr);
    final countryCode = getValue(kCountryCodeTr);
    if (languageCode != null && countryCode != null) {
      return Locale(languageCode, countryCode);
    }
    return null;
  }
}
