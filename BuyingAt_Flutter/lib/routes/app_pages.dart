import 'package:classified/view/add_products_view/add_property_navigation/add_product_screen.dart';
import 'package:classified/view/add_card_screen.dart';
import 'package:classified/view/auth_view/send_reset_otp.dart';
import 'package:classified/view/auth_view/otp_verify_screen.dart';
import 'package:classified/view/auth_view/reset_password_screen.dart';
import 'package:classified/view/messenger_view/chat_details_screen.dart';
import 'package:classified/view/filter_product_screen.dart';
import 'package:classified/view/product_details_screen.dart';
import 'package:classified/view/profile_view/account_settings_view/account_settings_screen.dart';
import 'package:classified/view/profile_view/account_settings_view/billing_address_screen.dart';
import 'package:classified/view/profile_view/account_settings_view/shipping_address_screen.dart';
import 'package:classified/view/browse_cards_screen.dart';
import 'package:classified/view/buyer_profiles_screen.dart';
import 'package:classified/view/buyer_profile_detail_screen.dart';
import 'package:classified/view/promote_cards_screen.dart';
import 'package:classified/view/profile_view/create_buyer_profile_screen.dart';
import 'package:classified/view/profile_view/buyer_profile_screen.dart';
import 'package:classified/view/profile_view/create_edit_buyer_profile_screen.dart';
import 'package:classified/view/profile_view/edit_profile_screen.dart';
import 'package:classified/view/search_results_screen.dart';
import 'package:classified/view/profile_view/create_shop_screen.dart';
import 'package:classified/view/profile_view/customer_order_screen.dart';
import 'package:classified/view/see_all_categories.dart';
import 'package:classified/view/splash_screen.dart';
import 'package:classified/view/wallet_and_recharge/recharge_screen.dart';
import 'package:classified/view/profile_view/dashboard_screen.dart';
import 'package:classified/view/profile_view/affiliate_screen.dart';
import 'package:classified/view/wishlist_screen.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import '../view/more_page_screen.dart';
import '../view/auth_view/auth_screen.dart';
import '../view/main_home/bottom_nav_bar.dart';
import '../view/messenger_view/messenger_screen.dart';
import '../view/messenger_view/chat_list_screen.dart';
import '../view/profile_view/my_shop_screen.dart';
import '../view/profile_view/order_details_screen.dart';
import '../view/profile_view/premium_screen.dart';
import '../view/shopping_cart_screen.dart';
import '../view/support_ticket_view/create_support_ticket.dart';
import '../view/support_ticket_view/msg_support_ticket.dart';
import '../view/support_ticket_view/reply_support_ticket.dart';
import '../view/support_ticket_view/support_ticket_screen.dart';
import '../view/wallet_and_recharge/wallet_screen.dart';
import 'app_routes.dart';

class AppPages {
  static List<GetPage> routes = [
    GetPage(
      name: Routes.authRoute,
      page: () => AuthScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 0),
    ),

    GetPage(
      name: Routes.bottomNavRoute,
      page: () => const BottomNavBar(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.getOtpRoute,
      page: () => const SendResetOtp(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.otpVerifyRoute,
      page: () => const OtpVerifyScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.resetPasswordRoute,
      page: () => const ResetPasswordScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.dashboardRoute,
      page: () => const DashboardScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.affiliateRoute,
      page: () => const AffiliateScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.splashRoute,
      page: () => const SplashScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.walletScreenRoute,
      page: () => const WalletScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.rechargeScreenRoute,
      page: () => const RechargeScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.accountSettingsRoute,
      page: () => const AccountSettingsScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.billingAddressRoute,
      page: () => const BillingAddressScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.shippingAddressRoute,
      page: () => const ShippingAddressScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.createShopRoute,
      page: () => const CreateShopScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.supportTicketRoute,
      page: () => const SupportTicketScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.createSupportTicketRoute,
      page: () => const CreateSupportTicket(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.premiumScreenRoute,
      page: () => const PremiumScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.myShopRoute,
      page: () => const MyShopScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.addProductRoute,
      page: () => const AddCardScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.customerOrderRoute,
      page: () => const CustomerOrderScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.orderDetailsRoute,
      page: () => const OrderDetailsScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.chatDetailsRoute,
      page: () => const ChatDetailsScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.postListRoute,
      page: () => const PostListScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.msgSupportTicketRoute,
      page: () => MsgSupportTicket(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    GetPage(
      name: Routes.replySupportTicketRoute,
      page: () => ReplySupportTicket(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    GetPage(
      name: Routes.replySupportTicketRoute,
      page: () => ReplySupportTicket(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    GetPage(
      name: Routes.productDtlRoute,
      page: () => ProductDetailsScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    GetPage(
      name: Routes.seeAllCategoriesRoute,
      page: () => SeeAllCategories(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    GetPage(
      name: Routes.shoppingCartRoute,
      page: () => ShoppingCartScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    GetPage(
      name: Routes.wishlistScreenRoute,
      page: () => WishlistScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    GetPage(
      name: Routes.chatListScreenRoute,
      page: () => const ChatListScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    GetPage(
      name: Routes.messengerScreenRoute,
      page: () => const MessengerScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    GetPage(
      name: Routes.morePageScreenRoute,
      page: () => MorePageScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    GetPage(
      name: Routes.createBuyerProfileRoute,
      page: () => const CreateBuyerProfileScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.browseCardsRoute,
      page: () => const BrowseCardsScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.buyerProfilesRoute,
      page: () => const BuyerProfilesScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.buyerProfileDetailRoute,
      page: () => const BuyerProfileDetailScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.editCardRoute,
      page: () => const AddCardScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.promoteCardsRoute,
      page: () => const PromoteCardsScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.buyerProfileRoute,
      page: () => const BuyerProfileScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.editBuyerProfileRoute,
      page: () {
        final args = Get.arguments ?? {};
        return CreateEditBuyerProfileScreen(
          isEditMode: args['isEditMode'] ?? false,
        );
      },
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.editProfileRoute,
      page: () => const EditProfileScreen(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.searchResultsRoute,
      page: () {
        final args = Get.arguments ?? {};
        return SearchResultsScreen(
          searchQuery: args['searchQuery'] ?? '',
        );
      },
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
