import 'package:classified/controller/more_page_controller.dart';
import 'package:classified/controller/navigation_controller.dart';
import 'package:classified/utils/app_color.dart';
import 'package:classified/utils/app_fonts.dart';
import 'package:classified/utils/app_text.dart';
import 'package:classified/widget/custom_app_bar.dart';
import 'package:classified/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controller/home_controller.dart';
import '../../controller/user_data_controller.dart';
import '../../controller/user_status_controller.dart';
import '../../helper/date_converter_helper.dart';
import '../../routes/app_routes.dart';
import '../../transition/fade_transition.dart';
import '../../widget/profile_widgets/profile_items.dart';
import '../../utils/session_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late dynamic _isLoggedIn;
  late UserDataController userDataController;
  late MorePageController morePageController;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = SessionManager.getValue(kIsLOGIN, value: false);
    userDataController = Get.find<UserDataController>();
    morePageController = Get.find<MorePageController>();
    if (_isLoggedIn) userDataController.fetchUserData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppText.dashboard,
        isBackButtonExist: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (!_isLoggedIn)
              CustomButton(text: AppText.logIn, height: 56.h, onPressed: () {
                FadeScreenTransition(
                    routeName: Routes.authRoute).navigate();
              },),

            if (_isLoggedIn)SizedBox(height: 8.h,),
            if(_isLoggedIn)Container(
              padding: EdgeInsets.symmetric(vertical: 26.h),
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                  color: AppColor.buttonColor4,
                  border: Border.all(color: AppColor.buttonColor3),
                  borderRadius: BorderRadius.circular(4.r)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppText.activePlan, style: sansBold.copyWith(
                          fontSize: 24.sp,
                          height: 1.25.h,
                          color: AppColor.dark2),),
                      SizedBox(width: 6.w,),
                      Obx(() {
                        return Text(userDataController.userData.value
                            .userPackage?.packageName ?? '', style: sansBold
                            .copyWith(fontSize: 24.sp,
                            height: 1.25.h,
                            color: AppColor.buttonColor),);
                      }),

                    ],
                  ),

                  if (userDataController.userData.value.userPackage
                      ?.packageEndDate
                      ?.toString()
                      .isNotEmpty ?? false) ...[
                    SizedBox(height: 20.h,),
                    Text(
                      AppText.expirationDate,
                      style: sansMedium.copyWith(
                        fontSize: 16.sp,
                        height: 1.25.h,
                        color: AppColor.coolGray11,
                      ),
                    ),
                    SizedBox(height: 8.h,),
                    Obx(() {
                      final date = userDataController.userData.value.userPackage
                          ?.packageEndDate;
                      return Text(
                        DateConverter.formatToLongDateTwo(date.toString()),
                        style: sansBold.copyWith(
                          fontSize: 24.sp,
                          height: 1.25.h,
                          color: AppColor.buttonColor,
                        ),
                      );
                    }),
                  ]


                ],
              ),
            ),

            if (!_isLoggedIn)SizedBox(height: 24.h,),
            if (_isLoggedIn)SizedBox(height: 16.h,),
            
            // Seller Menu Section - Always shown if logged in
            if (_isLoggedIn) ...[
              // Seller Header
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: AppColor.buttonColor.withValues(alpha: 0.1),
                  border: Border(
                    top: BorderSide(color: AppColor.buttonColor, width: 2.sp),
                    bottom: BorderSide(color: AppColor.buttonColor.withValues(alpha: 0.2), width: 1.sp),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Seller",
                      style: sansBold.copyWith(
                        fontSize: 18.sp,
                        color: AppColor.buttonColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Seller Menu Items
            ProfileItems(
                title: AppText.addProduct,
              onPressed: () {
                if (_isLoggedIn) {
                    FadeScreenTransition(routeName: Routes.addProductRoute)
                      .navigate();
                } else {
                  FadeScreenTransition(routeName: Routes.authRoute).navigate();
                }
              },
            ),

            ProfileItems(
                title: "Promote Cards",
              onPressed: () {
                if (_isLoggedIn) {
                    FadeScreenTransition(routeName: Routes.promoteCardsRoute)
                        .navigate();
                } else {
                  FadeScreenTransition(routeName: Routes.authRoute).navigate();
                }
              },
            ),

            ProfileItems(
              title: AppText.myShop,
              onPressed: () {
                if (_isLoggedIn) {
                  FadeScreenTransition(
                      routeName: Routes.myShopRoute, arguments: {'type': 'my'})
                      .navigate();
                } else {
                  FadeScreenTransition(routeName: Routes.authRoute).navigate();
                }
              },
            ),

            ProfileItems(
              title: "Buyer Profiles",
              onPressed: () {
                if (_isLoggedIn) {
                  FadeScreenTransition(routeName: Routes.buyerProfilesRoute)
                      .navigate();
                } else {
                  FadeScreenTransition(routeName: Routes.authRoute).navigate();
                }
              },
            ),

            ProfileItems(
              title: AppText.wallet,
              onPressed: () {
                if (_isLoggedIn) {
                  FadeScreenTransition(routeName: Routes.walletScreenRoute).navigate();
                } else {
                  FadeScreenTransition(routeName: Routes.authRoute).navigate();
                }
              },
            ),

            ProfileItems(
                title: AppText.supportTicket,
              onPressed: () {
                if (_isLoggedIn) {
                    FadeScreenTransition(routeName: Routes.supportTicketRoute).navigate();
                } else {
                  FadeScreenTransition(routeName: Routes.authRoute).navigate();
                }
              },
            ),

            ProfileItems(
                title: AppText.profile,
                onPressed: () {
                  if (_isLoggedIn) {
                    FadeScreenTransition(routeName: Routes.dashboardRoute)
                        .navigate();
                  } else {
                    FadeScreenTransition(routeName: Routes.authRoute).navigate();
                  }
                },
              ),

            ProfileItems(
              title: "Affiliate & Referrals",
              onPressed: () {
                if (_isLoggedIn) {
                  FadeScreenTransition(routeName: Routes.affiliateRoute)
                      .navigate();
                } else {
                  FadeScreenTransition(routeName: Routes.authRoute).navigate();
                }
              },
            ),

            ProfileItems(
                title: AppText.accountSettings,
                onPressed: () {
                  if (_isLoggedIn) {
                    FadeScreenTransition(routeName: Routes.accountSettingsRoute)
                        .navigate();
                  } else {
                    FadeScreenTransition(routeName: Routes.authRoute).navigate();
                  }
                },
              ),
            ],

            // Buyer Menu Section - Only shown if user role is 'buyer'
            if (_isLoggedIn) Obx(() {
              final userRole = userDataController.userData.value.role ?? 'seller';
              final isBuyer = userRole == 'buyer';
              
              if (!isBuyer) return SizedBox.shrink();
              
              return Column(
                children: [
                  // Separator
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    height: 1.h,
                    color: AppColor.coolGray17,
                  ),
                  
                  // Buyer Header
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: AppColor.buttonColor.withValues(alpha: 0.1),
                      border: Border(
                        top: BorderSide(color: AppColor.buttonColor, width: 2.sp),
                        bottom: BorderSide(color: AppColor.buttonColor.withValues(alpha: 0.2), width: 1.sp),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Buyer",
                          style: sansBold.copyWith(
                            fontSize: 18.sp,
                            color: AppColor.buttonColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Buyer Menu Items
                  ProfileItems(
                    title: "Browse Cards",
                    onPressed: () {
                      if (_isLoggedIn) {
                        FadeScreenTransition(routeName: Routes.browseCardsRoute).navigate();
                      } else {
                        FadeScreenTransition(routeName: Routes.authRoute).navigate();
                      }
                    },
                  ),
                  
                  ProfileItems(
                    title: "Shopping Cart",
                    onPressed: () {
                      if (_isLoggedIn) {
                        FadeScreenTransition(routeName: Routes.shoppingCartRoute).navigate();
                      } else {
                        FadeScreenTransition(routeName: Routes.authRoute).navigate();
                      }
                    },
                  ),
                  
                  ProfileItems(
                    title: AppText.myOrders,
              onPressed: () {
                if (_isLoggedIn) {
                  FadeScreenTransition(routeName: Routes.customerOrderRoute,
                            arguments: {'order': 'myOrder'}).navigate();
                } else {
                  FadeScreenTransition(routeName: Routes.authRoute).navigate();
                }
              },
            ),

            ProfileItems(
              title: AppText.wishlist,
              onPressed: () {
                if (_isLoggedIn) {
                  FadeScreenTransition(routeName: Routes.wishlistScreenRoute)
                      .navigate();
                } else {
                  FadeScreenTransition(routeName: Routes.authRoute).navigate();
                }
              },
            ),

            ProfileItems(
                    title: AppText.wallet,
                    onPressed: () {
                      if (_isLoggedIn) {
                        FadeScreenTransition(routeName: Routes.walletScreenRoute).navigate();
                      } else {
                        FadeScreenTransition(routeName: Routes.authRoute).navigate();
                      }
                    },
                  ),
                  
                  ProfileItems(
                    title: "Membership Plan",
              onPressed: () {
                if (_isLoggedIn) {
                        FadeScreenTransition(routeName: Routes.premiumScreenRoute)
                      .navigate();
                } else {
                  FadeScreenTransition(routeName: Routes.authRoute).navigate();
                }
              },
            ),

            ProfileItems(
              title: AppText.supportTicket,
              onPressed: () {
                if (_isLoggedIn) {
                  FadeScreenTransition(routeName: Routes.supportTicketRoute).navigate();
                } else {
                  FadeScreenTransition(routeName: Routes.authRoute).navigate();
                }
              },
            ),

                  ProfileItems(
                    title: "Profile",
                    onPressed: () {
                      if (_isLoggedIn) {
                        FadeScreenTransition(routeName: Routes.buyerProfileRoute).navigate();
                      } else {
                        FadeScreenTransition(routeName: Routes.authRoute).navigate();
                      }
                    },
                  ),
                ],
              );
            }),

            // More Pages (Dynamic)
            Obx(() {
              return Column(
                children: [
                  for (var item in morePageController.morePageList)
                    ProfileItems(
                      title: item.title.toString(),
                      onPressed: () {
                        FadeScreenTransition(routeName: Routes.morePageScreenRoute, arguments: {"title":item.title.toString(), "value":item}).navigate();
                      },
                    ),
                ],
              );
            }),

            if (_isLoggedIn) SizedBox(height: 24.h,),

            // Logout Button
            if (_isLoggedIn)CustomButton(
              text: AppText.logOut, height: 56.h, onPressed: () async {
              // Mark user as offline before logging out
              try {
                final userStatusController = Get.find<UserStatusController>();
                await userStatusController.updateLastSeen();
                await userStatusController.markOffline();
              } catch (e) {
                print("Error marking user offline on logout: $e");
              }
              
              await SessionManager.logout();
              Get
                  .find<HomeController>()
                  .apiClient
                  .removeToken();
              Get.delete<HomeController>();
              Get.offAllNamed(Routes.splashRoute);
              Get.find<NavigationController>().setIndex(0);
            },),

            SizedBox(height: 60.h,),
          ],
        ),
      ),
    );
  }
}
