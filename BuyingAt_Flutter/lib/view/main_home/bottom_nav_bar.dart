import 'package:classified/view/messenger_view/chat_list_screen.dart';
import 'package:classified/view/profile_view/profile_screen.dart';
import 'package:classified/view/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../transition/fade_transition.dart';
import '../../utils/session_manager.dart';
import '../../widget/nav_item_card.dart';
import '../home_screen.dart';
import '/utils/app_layout.dart';
import '../../controller/navigation_controller.dart';
import '../../utils/app_color.dart';
import '../../utils/app_image.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with WidgetsBindingObserver {
  late  dynamic _isLoggedIn;
  late NavigationController navController;

  @override
  void initState() {
    super.initState();
    navController = Get.find<NavigationController>();
    _isLoggedIn = SessionManager.getValue(kIsLOGIN, value: false);
    WidgetsBinding.instance.addObserver(this);
    
    // Ensure the PageView shows the correct page based on current index
    // Use post-frame callback to ensure PageView is attached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navController.pageController.hasClients) {
        final currentIndex = navController.index.value;
        // Always jump to the current index, even if it's 0
        // This ensures the correct page is shown immediately
          navController.pageController.jumpToPage(currentIndex);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    AppLayout.systemStatusColor(colors: AppColor.ghostWhite);
    
    // Ensure PageView is at the correct page immediately
    // This prevents showing the wrong page briefly
    final currentIndex = navController.index.value;
    if (navController.pageController.hasClients) {
      // Check if we're on the wrong page and jump immediately
      final currentPage = navController.pageController.page?.round() ?? 0;
      if (currentPage != currentIndex) {
        // Use SchedulerBinding to ensure this runs synchronously
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (navController.pageController.hasClients) {
            navController.pageController.jumpToPage(currentIndex);
          }
        });
      }
    }
    
    return Obx(() => PopScope(
          canPop: false /*(navController.index.value == 0)*/,
          onPopInvokedWithResult: (bool didPop, value) async {
            if (navController.index.value == 0) {
              // await _onBackPressed(context).then((shouldPop) {
              //   if (shouldPop) {
              //     SystemNavigator.pop();
              //   }
              // });
              navController.setIndex(3); // Redirect to profile page instead of home
            } else {
             // Get.back();
              navController.setIndex(3); // Redirect to profile page instead of home
            }
          },
          child: Scaffold(
            backgroundColor: AppColor.ghostWhite,
            body: PageView(
              controller: navController.pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const HomeScreen(),
                 SearchScreen(),
                const ChatListScreen(),
               const ProfileScreen(),
              ],
            ),
            bottomNavigationBar: navController.index.value == 2 ?null :Material(
              elevation: 0,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.h),
                  topRight: Radius.circular(24.h)),
              surfaceTintColor: Colors.transparent,
              clipBehavior: Clip.none,
              color: Colors.transparent,
              child: Container(
                height: 80.h,
                decoration: BoxDecoration(
                  color: AppColor.ghostWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.h),
                    topRight: Radius.circular(24.h),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: AppColor.bottomNavBorder,
                      width: 1.04,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                    left: BorderSide(
                      color: AppColor.bottomNavBorder,
                      width: 1.04,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                    right: BorderSide(
                      color: AppColor.bottomNavBorder,
                      width: 1.04,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      offset: Offset(0, -4),
                      blurRadius: 12.48,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          if(_isLoggedIn){
                            FadeScreenTransition(
                                routeName: Routes.myShopRoute, 
                                arguments: {'type': 'my'})
                                .navigate();
                          }else{
                            FadeScreenTransition(routeName: Routes.authRoute).navigate();
                          }
                        },
                        child: Container(
                            height: MediaQuery.of(context).size.height,
                            color: Colors.transparent,
                            child: NavItemCard(
                              imagePath: AppImage.icPackage,
                              imagePathActive: AppImage.icPackage,
                              size: 30.0,
                              active: (navController.index.value == 0),
                            )),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          navController.setIndex(1);
                        },
                        child: Container(
                            height: MediaQuery.of(context).size.height,
                            color: Colors.transparent,
                            child: NavItemCard(
                              imagePath: AppImage.icSearchInactive,
                              imagePathActive: AppImage.icSearch,
                              size: 30.0,
                              active: (navController.index.value == 1),
                            )),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: (){
                          if(_isLoggedIn){
                            FadeScreenTransition(routeName: Routes.addProductRoute).navigate();
                          }else{
                            FadeScreenTransition(routeName: Routes.authRoute).navigate();
                          }
                        },
                        // onTap: () async {
                        //   await Get.find<PostSearchController>().checkPostEligibility();
                        // },
                        child: Container(
                            height: MediaQuery.of(context).size.height,
                            color: Colors.transparent,
                            child: NavItemCard(
                              imagePath: AppImage.icAdd,
                              imagePathActive: AppImage.icAdd,
                              size: 48.0,
                              isAdd: true,
                              active: (navController.index.value == 5),
                            )),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          if(_isLoggedIn){
                            navController.setIndex(2);
                          }else{
                            FadeScreenTransition(routeName: Routes.authRoute).navigate();
                          }

                        },
                        child: NavItemCard(
                          imagePath: AppImage.icChatInactive,
                          imagePathActive: AppImage.icChat,
                          size: 30.0,
                          active: (navController.index.value == 2),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          navController.setIndex(3);
                        },
                        child: Container(
                            height: MediaQuery.of(context).size.height,
                            color: Colors.transparent,
                            child: NavItemCard(
                              imagePath: AppImage.icProfileInactive,
                              size: 30.0,
                              active: (navController.index.value == 3),
                              imagePathActive: AppImage.icProfile,
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  // Future<bool> _onBackPressed(BuildContext context) async {
  //   bool? exitApp = await Get.dialog(
  //     /ExitDialog(),
  //     barrierDismissible: false,
  //     useSafeArea: false,
  //   );
  //   return exitApp ?? false;
  // }

  // bool isPaused = false;

}
