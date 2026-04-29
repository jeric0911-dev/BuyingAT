import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  var index = 0.obs;
  PageController? _pageController;

  PageController get pageController {
    // Lazy initialization: create PageController with current index value
    // This ensures the initialPage matches the current index when first accessed
    _pageController ??= PageController(initialPage: index.value);
    return _pageController!;
  }

  void setIndex(int i) {
    index.value = i;
    // Only jump to page if PageController is attached to a PageView
    if (_pageController != null && _pageController!.hasClients) {
      _pageController!.jumpToPage(i);
    }
  }

  @override
  void onClose() {
    _pageController?.dispose();
    super.onClose();
  }
}
