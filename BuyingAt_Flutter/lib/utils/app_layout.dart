import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_color.dart';

class AppLayout {
  static getSize() {
    WidgetsBinding? binding = WidgetsBinding.instance;
    return binding.window.physicalSize / binding.window.devicePixelRatio;
  }

  static getScreenHeight() {
    return getSize().height;
  }

  static getScreenWidth() {
    return getSize().width;
  }

  // static double getHeight(double pixels) {
  //   double height = getScreenHeight();
  //   return (pixels / 932) * height;
  // }
  //
  // static double getWidth(double pixels) {
  //   double width = getScreenWidth();
  //   return (pixels / 430) * width;
  // }

  static getStatusBarHeight(BuildContext context,[dynamic extra]) {
    dynamic extraHeight =0;
    if(extra!=null){
      extraHeight = extra;
    }
    return MediaQuery.of(context).padding.top+extraHeight;
  }

  static screenPortrait(BuildContext context,{Color? colors}) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    systemStatusColor(context:context,colors:colors??Colors.transparent);
  }

  static screenPortrait1({BuildContext? context, Color? colors}) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // systemStatusColor(context: context,colors:colors??Colors.transparent);
  }

  static screenLandscape(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    // systemStatusColor(context: context,colors:Colors.transparent);
  }

  static systemStatusColor({BuildContext? context, Color? colors,Color? bottomColor}) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: colors??AppColor.ghostWhite,
      statusBarIconBrightness: isColorLight(AppColor.ghostWhite)?Brightness.dark:Brightness.light,
      systemNavigationBarIconBrightness: isColorLight(AppColor.ghostWhite)?Brightness.dark:Brightness.light,
      systemNavigationBarColor:bottomColor??
          AppColor.ghostWhite,
    ));
  }

  static bool isColorLight(Color colors) {
    double luminance = colors.computeLuminance();
    return luminance > 0.5;
  }

}
