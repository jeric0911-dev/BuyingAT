import 'package:get/get.dart';
import 'bangla.dart';
import 'english.dart';

class Languages extends Translations{

  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': enUS,
    'bn_BD': bnBD,
  };
}