import 'package:classified/controller/account_settings_controller.dart';
import 'package:classified/controller/add_products_controller.dart';
import 'package:classified/controller/auth_controller.dart';
import 'package:classified/controller/create_shop_controller.dart';
import 'package:classified/controller/customer_order_controller.dart';
import 'package:classified/controller/dashboard_controller.dart';
import 'package:classified/controller/fetch_product_info_controller.dart';
import 'package:classified/controller/get_country_city_controller.dart';
import 'package:classified/controller/home_controller.dart';
import 'package:classified/controller/message_controller.dart';
import 'package:classified/controller/more_page_controller.dart';
import 'package:classified/controller/navigation_controller.dart';
import 'package:classified/controller/filter_search_controller.dart';
import 'package:classified/controller/premium_controller.dart';
import 'package:classified/controller/product_details_controller.dart';
import 'package:classified/controller/recharge_controller.dart';
import 'package:classified/controller/see_all_controller.dart';
import 'package:classified/controller/shopping_cart_controller.dart';
import 'package:classified/controller/support_ticket_controller.dart';
import 'package:classified/controller/transection_controller.dart';
import 'package:classified/controller/user_data_controller.dart';
import 'package:classified/controller/user_status_controller.dart';
import 'package:classified/routes/app_pages.dart';
import 'package:classified/routes/app_routes.dart';
import 'package:classified/service/api/api_client.dart';
import 'package:classified/utils/_constant.dart';
import 'package:classified/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';


import 'language/languages_translations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  /// Make status bar transparent
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  await GetStorage.init();
  await SessionManager.init();
  Locale? savedLocale = SessionManager.getLocale();

  ApiClient apiClient = ApiClient(appBaseUrl: '${Constant.baseUrl}${Constant.subUrl}');
  Get.put<ApiClient>(apiClient, permanent: true);
  Get.lazyPut<NavigationController>(() => NavigationController(), fenix: true);
  Get.lazyPut<HomeController>(() => HomeController(apiClient: apiClient), fenix: true);
  Get.lazyPut<AuthController>(() => AuthController(apiClient: apiClient), fenix: true);
  Get.lazyPut<UserDataController>(() => UserDataController(apiClient: apiClient), fenix: true);
  Get.lazyPut<RechargeController>(() => RechargeController(apiClient: apiClient), fenix: true);
  Get.lazyPut<TransectionController>(() => TransectionController(apiClient: apiClient), fenix: true);
  Get.lazyPut<AccountSettingsController>(() => AccountSettingsController(apiClient: apiClient), fenix: true);
  Get.lazyPut<GetCountryCityController>(() => GetCountryCityController(apiClient: apiClient), fenix: true);
  Get.lazyPut<CreateShopController>(() => CreateShopController(apiClient: apiClient), fenix: true);
  Get.lazyPut<SupportTicketController>(() => SupportTicketController(apiClient: apiClient), fenix: true);
  Get.lazyPut<PremiumController>(() => PremiumController(apiClient: apiClient), fenix: true);
  Get.lazyPut<DashboardController>(() => DashboardController(apiClient: apiClient), fenix: true);
  Get.lazyPut<AddProductsController>(() => AddProductsController(apiClient: apiClient), fenix: true);
  Get.lazyPut<CustomerOrderController>(() => CustomerOrderController(apiClient: apiClient), fenix: true);
  Get.lazyPut<MessageController>(() => MessageController(apiClient: apiClient), fenix: true);
  Get.lazyPut<FetchProductInfoController>(() => FetchProductInfoController(apiClient: apiClient), fenix: true);
  Get.lazyPut<FilterController>(() => FilterController(apiClient: apiClient), fenix: true);
  Get.lazyPut<SeeAllController>(() => SeeAllController(apiClient: apiClient), fenix: true);
  Get.lazyPut<ProductDetailsController>(() => ProductDetailsController(apiClient: apiClient), fenix: true);
  Get.lazyPut<ShoppingCartController>(() => ShoppingCartController(apiClient: apiClient), fenix: true);
  Get.lazyPut<MorePageController>(() => MorePageController(apiClient: apiClient), fenix: true);
  Get.lazyPut<UserStatusController>(() => UserStatusController(apiClient: apiClient), fenix: true);


  //
  runApp(MyApp(savedLocale: savedLocale));
}

class MyApp extends StatefulWidget {
  final Locale? savedLocale;
  const MyApp({super.key, this.savedLocale});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateAppLifecycleState(WidgetsBinding.instance.lifecycleState);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  void _updateAppLifecycleState(AppLifecycleState? state) {
    try {
      final userStatusController = Get.find<UserStatusController>();
      final isLoggedIn = SessionManager.getValue(kIsLOGIN, value: false);
      
      if (!isLoggedIn) return;

      if (state == AppLifecycleState.resumed) {
        // App came to foreground - mark as online
        userStatusController.markOnline();
      } else if (state == AppLifecycleState.paused || 
                 state == AppLifecycleState.inactive ||
                 state == AppLifecycleState.detached) {
        // App went to background - mark as offline and update last seen
        userStatusController.updateLastSeen();
        userStatusController.markOffline();
      }
    } catch (e) {
      // Controller might not be initialized yet
      print("Error updating app lifecycle state: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith( textScaler: TextScaler.linear(1.0),),
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: Routes.splashRoute,
          getPages: AppPages.routes,
          translations: Languages(),
          locale: widget.savedLocale ?? const Locale('en', 'US'),
          fallbackLocale: const Locale('en', 'US'),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
            scaffoldBackgroundColor:  Colors.white,
            appBarTheme: AppBarTheme(color: Colors.white)
          ),
          // builder: (context, child) {
          //   return MediaQuery(
          //     data: MediaQuery.of(context).copyWith( textScaler: TextScaler.linear(1.0),),
          //
          //     child: Builder(
          //       builder: (context) {
          //         return child!;
          //       },
          //     ),
          //   );
          // },

        ),
      ),
    );
  }
  bool _isBackgrounded = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Update user status based on app lifecycle
    _updateAppLifecycleState(state);
    
    // Handle app background/restart logic
    if (state == AppLifecycleState.paused) {
      _isBackgrounded = true;
    } else if (state == AppLifecycleState.detached) {
      if (_isBackgrounded) {
        _restartApp();
      }
      _isBackgrounded = false;
    }
  }

  Future<void> _restartApp() async {
    Locale? savedLocale = SessionManager.getLocale();
    runApp(MyApp(savedLocale: savedLocale));
  }
}