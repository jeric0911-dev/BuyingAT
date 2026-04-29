<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\admin\userType\UserTypeController;
use App\Http\Controllers\admin\auth\AdminController;

use App\Http\Controllers\PaymentInfoController;
use App\Http\Controllers\customer\auth\UserController;
use App\Http\Controllers\customer\favorite\FavoriteController;
use App\Http\Controllers\customer\conversation\ConversationThreadController;
use App\Http\Controllers\customer\conversation\MessageController;
use App\Http\Controllers\UserStatusController;
use App\Http\Controllers\ContactViolationController;
use App\Http\Controllers\CardRequestController;
use App\Http\Controllers\customer\product\ProductController;
use App\Http\Controllers\customer\productStock\ProductStockController;
use App\Http\Controllers\customer\blog\BlogCommentController;

//customer
use App\Http\Controllers\customer\blog\BlogController;
use App\Http\Controllers\customer\clickAndFavorite\ClickAndFavoriteController;
use App\Http\Controllers\customer\featured\FeatureController;
use App\Http\Controllers\customer\homepageData\HomepageDataController;
use App\Http\Controllers\customer\searchAndFilter\SearchAndFilterController;
use App\Http\Controllers\customer\testimonial\TestimonialController;
use App\Http\Controllers\customer\morePage\MorePageController;
use App\Http\Controllers\customer\userDashboard\UserDashboardDataController;
use App\Http\Controllers\customer\country\CountryController;
use App\Http\Controllers\customer\city\CityController;
use App\Http\Controllers\customer\clickFavoriteCall\ClickFavoriteCallCountController;
use App\Http\Controllers\customer\billingAndShipping\BillingAddressController;
use App\Http\Controllers\customer\billingAndShipping\ShippingAddressController;

use App\Http\Controllers\gateway\PaypalPaymentController;

use App\Http\Controllers\customer\heroSection\HeroSectionController;
use App\Http\Controllers\customer\footerSection\FooterSectionController;
use App\Http\Controllers\customer\blog\BlogCategoryController;
use App\Http\Controllers\customer\social\SocialController;
use App\Http\Controllers\SendMailController;
use App\Http\Controllers\admin\adminDashboard\AdminDashboardDataController;
use App\Http\Controllers\admin\faq\FaqController;
use App\Http\Controllers\gateway\SslCommerzController;
use App\Http\Controllers\customer\aboutUsSection\AboutUsSectionController;
use App\Http\Controllers\customer\appSettings\AppSettingController;
use App\Http\Controllers\customer\brand\BrandController;
use App\Http\Controllers\customer\childCategory\ChildCategoryController;
use App\Http\Controllers\customer\coupon\CouponController;
use App\Http\Controllers\customer\product\ProductReviewController;
use App\Http\Controllers\customer\sliderAndAds\SliderController;
use App\Http\Controllers\customer\subCategory\SubCategoryController;

use App\Http\Controllers\customer\wishlist\WishlistController;
use App\Http\Controllers\customer\shop\ShopController;

use App\Http\Controllers\ExpenseController;
use App\Http\Controllers\FeatureConfigController;
use App\Http\Controllers\FeaturedController;
use App\Http\Controllers\gateway\RazorpayPaymentController;
use App\Http\Controllers\gateway\StripePaymentController;
use App\Http\Controllers\GatewayController;
use App\Http\Controllers\GoogleLoginController;
use App\Http\Controllers\LoginsController;
use App\Http\Controllers\MailConfigController;
use App\Http\Controllers\PackageController;
use App\Http\Controllers\PusherConfigController;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\SupportTicketController;
use App\Http\Controllers\TicketMessageController;
use App\Http\Controllers\TransactionController;
use App\Http\Controllers\UserPackageController;
use App\Http\Controllers\WalletController;
use App\Http\Controllers\GoogleLoginConfigController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\CartController;
use App\Http\Controllers\PromotionCardController;
use App\Http\Controllers\AffiliateController;


//home routes
use App\Http\Controllers\customer\category\CategoryController;
use App\Http\Controllers\customer\homePage\HomepageDataController as HomePageHomepageDataController;
use App\Http\Controllers\customer\rating\RatingController;
use App\Http\Controllers\customer\sliderAndAds\AdsController;
use App\Http\Controllers\customer\sliderAndAds\AdvertiseController;
use App\Http\Controllers\customer\state\StateController;
use App\Http\Controllers\ContactUsController;

//admin routes
Route::prefix('admin')->middleware(['auth:admin-api']) ->group(function () {
    // Admin panel routes`
    Route::post('/logout/admin', [AdminController::class, 'logout']);

    // Admin panel routes
    Route::post('/logout/admin', [AdminController::class, 'logout']);

    //support tickets routes
    Route::get('/tickets', [ SupportTicketController::class, 'allForAdmins'])->middleware('admin.permission:support-ticket.view');
    Route::get('/tickets/{id}', [ SupportTicketController::class, 'show'])->middleware('admin.permission:support-ticket.view');
    Route::post('/tickets', [ SupportTicketController::class, 'store'])->middleware('admin.permission:support-ticket.edit');
    Route::post('/tickets/{id}', [ SupportTicketController::class, 'update'])->middleware('admin.permission:support-ticket.view');
    Route::delete('/tickets/{id}', [ SupportTicketController::class, 'destroy'])->middleware('admin.permission:support-ticket.delete');
    Route::get('/close-tickets/{id}', [ SupportTicketController::class, 'closeTicket'])->middleware('admin.permission:support-ticket.edit');

    //ticket message routes
    Route::get('/ticket-messages/{id}', [ TicketMessageController::class, 'getMessages'])->middleware('admin.permission:support-ticket.view');
    Route::post('/ticket-messages', [ TicketMessageController::class, 'store'])->middleware('admin.permission:support-ticket.edit');

    //gateway related routes
    Route::get('/gateway', [ GatewayController::class, 'index'])->middleware('admin.permission:payment-credentials.view');
    Route::post('/gateway', [ GatewayController::class, 'store'])->middleware('admin.permission:payment-credentials.add');
    Route::get('/gateway/{alias}', [ GatewayController::class, 'show'])->middleware('admin.permission:payment-credentials.view');
    Route::post('/gateway/{alias}', [ GatewayController::class, 'update'])->middleware('admin.permission:payment-credentials.edit');

    //feature config routes
    Route::get('/feature-configs', [FeatureConfigController::class, 'index'])->middleware('admin.permission:configs.view');
    Route::get('/feature-configs/{id}', [FeatureConfigController::class, 'show'])->middleware('admin.permission:configs.view');
    Route::post('/feature-configs', [FeatureConfigController::class, 'store'])->middleware('admin.permission:configs.edit');
    Route::post('/feature-configs/{id}', [FeatureConfigController::class, 'update'])->middleware('admin.permission:configs.edit');
    Route::delete('/feature-configs/{id}', [FeatureConfigController::class, 'destroy'])->middleware('admin.permission:configs.delete');

    route::get('/logins/data/{id}', [ LoginsController::class, 'index']);

    route::get('/total-payments', [AdminDashboardDataController::class, 'totalPayments' ])->middleware('admin.permission:dashboard.view');
    route::get('/admin-dashboard-stats', [AdminDashboardDataController::class, 'getStats' ])->middleware('admin.permission:dashboard.view');

    Route::get('/monthly-report', [ TransactionController::class, 'monthlyReportWithDailyCounts'])->middleware('admin.permission:dashboard.view');
    Route::get('/weekly-report', [ TransactionController::class, 'weeklyReportWithDayNames'])->middleware('admin.permission:dashboard.view');
    Route::get('/yearly-report', [ TransactionController::class, 'yearlyReportWithMonthlyCounts'])->middleware('admin.permission:dashboard.view');

    //report
    Route::get('/reports', [ ReportController::class, 'index'])->middleware('admin.permission:reports.view');
    Route::get('/reports/{id}', [ ReportController::class, 'show'])->middleware('admin.permission:reports.view');
    Route::delete('/reports/{id}', [ ReportController::class, 'destroy'])->middleware('admin.permission:reports.delete');

    //mail config
    Route::get('/mail-config', [ MailConfigController::class, 'getFirst'])->middleware('admin.permission:configs.view');
    Route::post('/mail-config', [ MailConfigController::class, 'update'])->middleware('admin.permission:configs.edit');

    //pusher config
    Route::get('/pusher-config', [ PusherConfigController::class, 'getFirst'])->middleware('admin.permission:configs.view');
    Route::post('/pusher-config', [ PusherConfigController::class, 'update'])->middleware('admin.permission:configs.edit');

    //google login conf
    Route::get('/google-config', [ GoogleLoginConfigController::class, 'getFirst'])->middleware('admin.permission:configs.view');
    Route::post('/google-config', [ GoogleLoginConfigController::class, 'update'])->middleware('admin.permission:configs.edit');

    //manage admin routes
    Route::get('/adminsinfo', [AdminController::class, 'protectedAction'])->middleware('admin.permission:admins.view');
    Route::get('/admins', [AdminController::class, 'index'])->middleware('admin.permission:admins.view');
    Route::get('/admins/{id}', [AdminController::class, 'show'])->middleware('admin.permission:admins.view');
    Route::post('/admins', [AdminController::class, 'store'])->middleware('admin.permission:admins.edit');
    Route::post('/admins/{id}', [AdminController::class, 'update'])->middleware('admin.permission:admins.edit');
    Route::delete('/admins/{id}', [AdminController::class, 'destroy'])->middleware('admin.permission:admins.delete');
    Route::post('/admins/logout', [AdminController::class, 'logout']);

    Route::group([], __DIR__ . '/admin/listingType.php');
    Route::group([], __DIR__ . '/admin/category.php');
    Route::group([], __DIR__ . '/admin/subCategory.php');
    Route::group([], __DIR__ . '/admin/childCategory.php');
    Route::group([], __DIR__ . '/admin/blog.php');
    Route::group([], __DIR__ . '/admin/country.php');
    Route::group([], __DIR__ . '/admin/city.php');
    Route::group([], __DIR__ . '/admin/language.php');
    Route::group([], __DIR__ . '/admin/faqs.php');
    Route::group([], __DIR__ . '/admin/aboutUs.php');
    Route::group([], __DIR__ . '/admin/privacyPolicy.php');
    Route::group([], __DIR__ . '/admin/termsConditions.php');
    Route::group([], __DIR__ . '/admin/adminType.php');
    Route::group([], __DIR__ . '/admin/adminTypeSpatie.php');
    Route::group([], __DIR__ . '/admin/admin.php');
    Route::group([], __DIR__ . '/admin/paymentProvider.php');
    Route::group([], __DIR__ . '/admin/testimonial.php');
    Route::group([], __DIR__ . '/admin/morePage.php');

    //added later
    Route::group([], __DIR__ . '/admin/user.php');
    Route::group([], __DIR__ . '/admin/state.php');
    Route::group([], __DIR__ . '/admin/heroSection.php');
    Route::group([], __DIR__ . '/admin/footerSection.php');
    Route::group([], __DIR__ . '/admin/social.php');
    Route::group([], __DIR__ . '/admin/packageCategory.php');
    Route::group([], __DIR__ . '/admin/package.php');
    Route::group([], __DIR__ . '/admin/currency.php');
    Route::group([], __DIR__ . '/admin/appSettings.php');
    Route::group([], __DIR__ . '/admin/slider.php');
    Route::group([], __DIR__ . '/admin/ads.php');
    Route::group([], __DIR__ . '/admin/advertise.php');
    Route::group([], __DIR__ . '/admin/brand.php');

    Route::group([], __DIR__ . '/admin/coupon.php');
    Route::group([], __DIR__ . '/admin/shop.php');
    Route::group([], __DIR__ . '/admin/product.php');
    Route::group([], __DIR__ . '/admin/contactUs.php');
});

//user routes
Route::prefix('user')->middleware(['auth:sanctum', 'track.user.status'])->group(function () {
    //blog comment routes
    Route::post('/blog-comments', [ BlogCommentController::class, 'store']);

    // user
    Route::post('/update_me', [UserController::class, 'updateMe']);
    Route::post('/change_password', [UserController::class, 'changePassword']);
    Route::get('/logout', [UserController::class, 'logout']);
    Route::get('/get_me', [UserController::class, 'getMe']);

    // user status routes
    Route::post('/status/online', [UserStatusController::class, 'markOnline']);
    Route::post('/status/offline', [UserStatusController::class, 'markOffline']);
    Route::post('/status/last-seen', [UserStatusController::class, 'updateLastSeen']);
    Route::get('/status', [UserStatusController::class, 'getStatus']);
    Route::get('/status/user/{userId}', [UserStatusController::class, 'getUserStatusById']);
    Route::get('/status/online-users', [UserStatusController::class, 'getOnlineUsers']);

    // contact violation tracking
    Route::post('/violations/track', [ContactViolationController::class, 'trackViolation']);
    Route::get('/violations/stats', [ContactViolationController::class, 'getUserViolations']);

    //rating
    Route::post('/products/rating', [ RatingController::class, 'store']);
    // user billing address
    Route::get('/billing-address', [BillingAddressController::class, 'index']);
    Route::post('/billing-address', [BillingAddressController::class, 'createOrUpdate']);

    // user billing address
    Route::get('/shipping-address', [ShippingAddressController::class, 'index']);
    Route::post('/shipping-address', [ShippingAddressController::class, 'createOrUpdate']);

    //added later
    Route::get('/gateway', [ GatewayController::class, 'index']);
    Route::get('/gateway/{alias}', [ GatewayController::class, 'show']);

    //mail config
    Route::get('/mail-config', [ MailConfigController::class, 'getFirst']);
    Route::post('/mail-config', [ MailConfigController::class, 'update']);

    //pusher config
    Route::get('/pusher-config', [ PusherConfigController::class, 'getFirst']);
    Route::post('/pusher-config', [ PusherConfigController::class, 'update']);

    //google login conf
    Route::get('/google-config', [ GoogleLoginConfigController::class, 'getFirst']);
    Route::post('/google-config', [ GoogleLoginConfigController::class, 'update']);

    Route::post('/subscribe', [ UserPackageController::class, 'subscribe']);
    Route::get('/current-package', [ UserPackageController::class, 'current']);

    //transactions
    Route::get('/get-transactions', [ TransactionController::class, 'getUserTransactions']);
    Route::post('/store-transactions', [ TransactionController::class, 'store']);

    //get all from gateway frontend
    Route::get('/get-all-from-frontend', [ GatewayController::class, 'getAllFromFrontend']);

    //get wallet
    Route::get('/get-wallet', [ WalletController::class, 'getWallet' ]);
    //feature route
    Route::post('/feature', [FeatureController::class, 'feature']);

    //expense routes
    Route::get('/expenses', [ ExpenseController::class, 'index']);

    //products
    Route::get('/products', [ProductController::class, 'index']);
    Route::get('/products/{id}', [ProductController::class, 'show']);
    Route::post('/products', [ProductController::class, 'store']);
    Route::post('/products/{id}', [ProductController::class, 'update']);
    Route::delete('/products/{id}', [ProductController::class, 'destroy']);

    Route::post('/unpublish-product', [ProductController::class, 'unpublish']);

    //product stock routes
    Route::get('/product-stocks', [ProductStockController::class, 'getAllProductStocks']);
    Route::get('/product-stocks/{id}', [ProductStockController::class, 'getSingleProductStock']);
    Route::post('/product-stocks', [ProductStockController::class, 'createProductStock']);
    Route::post('/product-stocks-multiple', [ProductStockController::class, 'createOrUpdateMultipleProductStocks']);
    Route::post('/product-stocks/{id}', [ProductStockController::class, 'updateProductStock']);
    Route::post('/product-stocks-multiple/{id}', [ProductStockController::class, 'updateMultipleProductStocks']);
    Route::delete('/product-stocks/{id}', [ProductStockController::class, 'deleteProductStock']);

    //cart routes
    Route::post('/add-to-cart', [ CartController::class, 'addProductToCart']);
    Route::post('/increase-cart-count', [ CartController::class, 'increaseCartItemQuantity']);
    Route::post('/decrease-cart-count', [ CartController::class, 'decreaseCartItemQuantity']);
    Route::get('/get-cart-items', [ CartController::class, 'cartItems']);
    Route::post('/remove-cart-item', [ CartController::class, 'removeCartItem']);
    Route::get('/clear-cart-items', [ CartController::class, 'clearCart']);
    Route::get('/cart-details', [ CartController::class, 'getCartDetails']);
    Route::post('/apply-coupon', [ CartController::class, 'applyCoupon']);

    Route::post('/order-from-cart', [ OrderController::class, 'createOrderFromCart']);
    Route::post('/checkout', [ OrderController::class, 'createOrderFromCart']);
    Route::post('/buy-now', [ OrderController::class, 'createOrder']);
    Route::get('/vendor-or-user-order-list', [ OrderController::class, 'getVendorOrUserOrderList']);
    Route::get('/user-order-list', [ OrderController::class, 'getUsersOwnOrderList']);
    Route::get('/user-order-data', [ OrderController::class, 'getUsersOwnOrderData']);
    Route::get('/order-details/{id}', [ OrderController::class, 'getOrderDetails']);
    Route::get('/cancel-order/{id}', [ OrderController::class, 'cancelOrder']);
    Route::get('/return-order/{id}', [ OrderController::class, 'returnOrder']);
    Route::get('/order-status/{id}', [ OrderController::class, 'getOrderStatus']);
    Route::get('/order-tracking/{id}', [ OrderController::class, 'getOrderTracking']);

    Route::post('/product-review', [ ProductReviewController::class, 'store']);
    Route::post('/product-review/{id}', [ ProductReviewController::class, 'update']);

    // Affiliate routes
    Route::get('/affiliate/stats', [AffiliateController::class, 'getMyAffiliateStats']);

    // Admin panel routes
    Route::post('/logout/admin', [AdminController::class, 'logout']);

    Route::post('/logout/user', [UserController::class, 'logout']);
    Route::get('/products-by-user', [ UserDashboardDataController::class, 'getCarByUser']);

    Route::post('/create-blog-comment', [ BlogCommentController::class, 'store']);

    //user favorite routes
    Route::post('/favorites', [FavoriteController::class, 'store']);
    Route::get('/favorites', [FavoriteController::class, 'index']);
    Route::delete('/user-favorites/delete', [FavoriteController::class, 'destroy']);
    Route::get('/favorites/{id}', [FavoriteController::class, 'show']);
    Route::post('/favorites/{id}', [FavoriteController::class, 'update']);
    Route::get('/user-favorite', [FavoriteController::class, 'getUserFavorite']);

    //Messaging-conversation Routes
    Route::get('/all-conversation-thread', [ ConversationThreadController::class, 'index']);
    Route::post('/conversation-thread', [ ConversationThreadController::class, 'create']);
    Route::get('/conversation-threads/get-all', [ ConversationThreadController::class,'getUserConversationThreads']);
    Route::get('/conversation-threads/{userId}/{conversationId}', [ ConversationThreadController::class, 'getUserConversationThreadSingle']);
    Route::post('/conversation-threads/{conversationId}/mark-read', [ ConversationThreadController::class, 'markAsRead']);

    //Message sending and Getting Routes
    Route::post('/message', [MessageController::class, 'createMessage']);
    Route::get('/get-message/{id}', [MessageController::class, 'getMessages']);


    //support tickets routes
    Route::get('/tickets', [ SupportTicketController::class, 'index']);
    Route::get('/tickets/{id}', [ SupportTicketController::class, 'show']);
    Route::post('/tickets', [ SupportTicketController::class, 'store']);
    Route::post('/tickets/{id}', [ SupportTicketController::class, 'update']);
    Route::delete('/tickets/{id}', [ SupportTicketController::class, 'destroy']);
    Route::get('/close-tickets/{id}', [ SupportTicketController::class, 'closeTicket']);

    //ticket message routes
    Route::get('/ticket-messages/{id}', [ TicketMessageController::class, 'getMessages']);
    Route::post('/ticket-messages', [ TicketMessageController::class, 'store']);

    //report
    Route::get('/reports', [ ReportController::class, 'index']);
    Route::get('/reports/{id}', [ ReportController::class, 'show']);
    Route::post('/reports', [ ReportController::class, 'store']);
    Route::post('/reports/{id}', [ ReportController::class, 'update']);
    Route::delete('/reports/{id}', [ ReportController::class, 'destroy']);

    //stripe
    //Route::post('/stripe/payment-intent', [ StripePaymentController::class, 'createPaymentIntent']);
    Route::post('/stripe/create-checkout-session', [StripePaymentController::class, 'createCheckoutSession']);




    // SSLCOMMERZ Routes
    Route::post('/sslcommerz/pay', [SslCommerzController::class, 'payViaAjax']);
    //Route::post('/sslcommerz/pay', [SslCommerzController::class, 'index']);
    //Route::post('/sslcommerz/pay-via-ajax', [SslCommerzController::class, 'payViaAjax']);

    Route::post('/sslcommerz/ipn', [SslCommerzController::class, 'ipn']);

    Route::post('/paypal/initiate-payment', [PaypalPaymentController::class, 'initiatePayment']);


    //Razorpay Routes
    Route::post('/razorpay/payment', [RazorpayPaymentController::class, 'payment']);
    Route::post('/razorpay/pay', [RazorpayPaymentController::class, 'pay']);

    route::get('/logins', [ LoginsController::class, 'logins']);

    //Coupon Routes
    Route::get('/coupons', [ CouponController::class, 'index']);
    Route::get('/coupons/{id}', [ CouponController::class, 'show']);

    //added later
    Route::post('/activate-package', [UserPackageController::class, 'subscribe']);

    //Route::post('/convert-currency', [ CurrencyConverterController::class, 'convertCurrency']);

    //newly added
    Route::get('/product/wishlists', [WishlistController::class, 'index']);
    Route::get('/product/wishlists/{id}', [WishlistController::class, 'show']);
    Route::post('/product/wishlists', [WishlistController::class, 'store']);
    Route::post('/product/wishlists/{id}', [WishlistController::class, 'update']);
    Route::delete('/product/wishlists/{id}', [WishlistController::class, 'destroy']);

    Route::get('/shops', [ShopController::class, 'index']);
    Route::get('/shops-user-products', [ShopController::class, 'listUserProducts']);
    Route::get('/shops-shop-products', [ShopController::class, 'listShopProducts']);
    Route::get('/shops/{id}', [ShopController::class, 'show']);
    Route::post('/shops', [ShopController::class, 'store']);
    Route::post('/shops/update', [ShopController::class, 'update']);
    Route::delete('/shops/{id}', [ShopController::class, 'delete']);

    //boostin routes
    Route::post('/features', [ FeatureController::class, 'feature' ]);

    //product and shop related vendor routes
    Route::post('/product/manage-stocks', [ProductController::class, 'stockManagement']);
    Route::post('/product/unpublish', [ProductController::class, 'unpublish']);
    Route::post('/update-order-status/{id}', [ OrderController::class, 'updateOrderStatus']);
    Route::post('/order/{id}/pay-with-wallet', [ OrderController::class, 'payWithWallet']);

    Route::get('/shop-by-vendor', [ShopController::class, 'shopByVendor']);
    Route::get('/products-by-vendor', [ShopController::class, 'shopProducts']);
});

Route::post('/sslcommerz/success', [SslCommerzController::class, 'success']);
Route::post('/sslcommerz/fail', [SslCommerzController::class, 'fail']);
Route::post('/sslcommerz/cancel', [SslCommerzController::class, 'cancel']);

//stripe payment success
Route::get('/stripe/payment-success', [StripePaymentController::class, 'paymentSuccess']);
Route::get('/stripe/payment-cancel', [StripePaymentController::class, 'paymentCancel']);

Route::get('/paypal/success', [PaypalPaymentController::class, 'success']);
Route::get('/paypal/cancel', [PaypalPaymentController::class, 'cancel']);

//home routes
Route::prefix('home')->group(function () {
    Route::get('/google-config', [ GoogleLoginConfigController::class, 'getFirst']);
    Route::get('/shop-with-categories', [HomePageHomepageDataController::class, 'shopWithCategories']);
    Route::get('/best-deals', [HomePageHomepageDataController::class, 'bestDeals']);
    Route::get('/featured-products', [HomePageHomepageDataController::class, 'featuredProducts']);
    Route::get('/electronics-accessories', [HomePageHomepageDataController::class, 'electronicsAccessories']);
    Route::get('/random-category-products', [HomePageHomepageDataController::class, 'randomCategoryProducts']);
    Route::get('/top-rated', [HomePageHomepageDataController::class, 'topRated']);
    Route::get('/new-arrivals', [HomePageHomepageDataController::class, 'newArrivals']);

    Route::post('/login', [UserController::class, 'login']);
    Route::post('/users', [UserController::class, 'store']);
    Route::post('/signup', [UserController::class, 'signup']);

    Route::post('/send-reset-otp', [UserController::class, 'sendResetOtp']);
    Route::post('/verify-otp', [UserController::class, 'verifyOtp']);
    Route::post('/reset-password', [UserController::class, 'resetPasswordWithOtp']);

    //get all categories
    Route::get('/categories', [ CategoryController::class, 'index']);
    Route::get('/top-categories', [ CategoryController::class, 'topCategories']);
    Route::get('/categories/{id}', [ CategoryController::class, 'show']);

    //get sub categories
    Route::get('/sub-categories', [ SubCategoryController::class, 'index']);
    Route::get('/sub-categories/{id}', [ SubCategoryController::class, 'show']);

    //brands
    Route::get('/brands', [ BrandController::class, 'index']);


    //get child category
    Route::get('/child-categories', [ ChildCategoryController::class, 'index']);
    Route::get('/child-categories/{id}', [ ChildCategoryController::class, 'show']);

    //blog Category Routes
    Route::get('/blog-categories', [ BlogCategoryController::class, 'index']);
    Route::get('/blog-categories/{name}', [ BlogCategoryController::class, 'show']);

    //blog Routes
    Route::get('/blogs', [BlogController::class, 'index']);
    Route::get('/blogs/search', [BlogController::class, 'search']);
    Route::get('/blogs/{slug}', [BlogController::class, 'show']);
    Route::get('/blogs/category/{id}', [BlogController::class, 'getByCategory']);

    //product routes
    Route::get('/products/filter', [ProductController::class, 'filter']);
    Route::get('/products', [ProductController::class, 'index']);
    Route::get('/products/{id}', [ProductController::class, 'show']);

    //cards routes
    Route::get('/cards/filter', [CardRequestController::class, 'browseActiveCards']);
    Route::get('/cards/{id}', [CardRequestController::class, 'showActiveCard']);

    //get shop by slug
    Route::get('/shops/{slug}', [ShopController::class, 'shopBySlug']);
    Route::get('/shops-slugs', [ShopController::class, 'getShopSlugs']);

    Route::get('/user-products/{user_id}', [ShopController::class, 'listUserProducts']);


    //country and city routes
    Route::get('/cities', [CityController::class, 'index']);
    Route::get('/countries', [ CountryController::class, 'index']);
    Route::get('/states', [StateController::class, 'index']);

    //slider routes
    Route::get('/sliders', [ SliderController::class , 'index']);
    Route::get('/sliders/{id}', [ SliderController::class , 'show']);

    //get ads
    Route::get('/ads', [ AdsController::class, 'index']);
    Route::get('/ads/{id}', [ AdsController::class, 'show']);

    //advertise
    Route::get('/advertise', [AdvertiseController::class, 'index']);
    Route::get('/advertise/{id}', [AdvertiseController::class, 'show']);

    Route::get('/about-section', [AboutUsSectionController::class, 'show']);

    //Testimonial Routes
    Route::get('/testimonials', [TestimonialController::class, 'index']);
    Route::get('/testimonials/{id}', [TestimonialController::class, 'show']);

    //search and filter routes
    Route::post('/filter', [SearchAndFilterController::class, 'filter']);
    Route::post('/featured-product', [ SearchAndFilterController::class, 'featuredCarFilter']);

    //Favorite And like count Routes
    Route::put('/clicks/{id}', [ClickFavoriteCallCountController::class, 'clickCount']);

    Route::put('/calls/{id}', [ClickFavoriteCallCountController::class, 'storeCallCount']);

    Route::put('/favorite/{id}', [ClickFavoriteCallCountController::class, 'favoriteCount']);
    Route::put('/favorite/decrement/{id}', [ClickFavoriteCallCountController::class, 'decrementFavoriteCount']);


    //favorite related routes
    Route::post('/favorites', [FavoriteController::class, 'store']);
    Route::post('/user-favorite', [FavoriteController::class, 'getUserFavorite']);
    Route::delete('/user-favorites/delete', [FavoriteController::class, 'destroy']);

    //more page routes
    Route::get('/more-pages', [MorePageController::class, 'index']);
    Route::get('/more-pages/{slug}', [MorePageController::class, 'show']);

    Route::get('/hero-section', [ HeroSectionController::class, 'show']);
    Route::get('/footer-section', [ FooterSectionController::class, 'show']);
    Route::get('/socials', [ SocialController::class, 'index']);

    Route::get('/packages', [ PackageController::class, 'getAllPackagesByCategory']);

    Route::post('contact-us', [ContactUsController::class, 'store']);
    Route::get('faqs', [FaqController::class, 'index']);

});

Route::post('/admin/admins-login', [AdminController::class, 'login']);

// Public package status by user id
Route::get('/user/package-status/{userId}', [UserPackageController::class, 'statusByUser']);

//Payments info
Route::get('/payments-info', [PaymentInfoController::class, 'index']);
Route::get('/payments-info/{id}', [PaymentInfoController::class, 'show']);
Route::post('/payments-info', [PaymentInfoController::class, 'store']);
Route::post('/payments-info/{id}', [PaymentInfoController::class, 'update']);
Route::delete('/payments-info/{id}', [PaymentInfoController::class, 'destroy']);

//Currency
Route::get('/admin/app-setting', [ AppSettingController::class, 'getOne']);
Route::get('/app-setting', [ AppSettingController::class, 'show']);

//google login logout Routes
Route::get('/google-login', [GoogleLoginController::class, 'redirectToGoogle']);
Route::get('/google-login/redirect', [GoogleLoginController::class, 'redirect']);
Route::post('/google-login/create-user', [GoogleLoginController::class, 'createUser']);
Route::post('/google-login/login', [ GoogleLoginController::class, 'login' ]);
Route::post('/google-login/logout', [GoogleLoginController::class, 'logout']);

//Frontend APIs
Route::post('/users', [UserController::class, 'store']);
Route::post('/users/{id}', [UserController::class, 'update']);
Route::delete('/users/{id}', [UserController::class, 'destroy']);

// User Profile APIs
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user-profile', [App\Http\Controllers\UserProfileController::class, 'show']);
    Route::post('/user-profile', [App\Http\Controllers\UserProfileController::class, 'storeOrUpdate']);
    Route::delete('/user-profile', [App\Http\Controllers\UserProfileController::class, 'destroy']);
});

// Test route for profile creation (remove in production)
Route::get('/test-profile', function () {
    try {
        $user = App\Models\User::first();
        if (!$user) {
            return response()->json(['error' => 'No users found in database'], 404);
        }
        
        $profile = new App\Models\UserProfile();
        $profile->user_id = $user->id;
        $profile->username = 'test_user_' . time();
        $profile->bio = 'Test bio';
        $profile->save();
        
        return response()->json([
            'success' => true,
            'message' => 'Profile created successfully',
            'profile_id' => $profile->id,
            'user_id' => $profile->user_id,
            'username' => $profile->username
        ]);
    } catch (Exception $e) {
        return response()->json([
            'error' => 'Failed to create profile',
            'message' => $e->getMessage()
        ], 500);
    }
});

// Buyer Profile Routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/buyer-profile', [App\Http\Controllers\BuyerProfileController::class, 'store']);
    Route::get('/buyer-profile', [App\Http\Controllers\BuyerProfileController::class, 'show']);
    Route::put('/buyer-profile', [App\Http\Controllers\BuyerProfileController::class, 'update']);
});

// Public buyer profiles routes (no authentication required)
Route::get('/buyer-profiles', [App\Http\Controllers\BuyerProfileController::class, 'index']);
Route::get('/buyer-profiles/{id}', [App\Http\Controllers\BuyerProfileController::class, 'showById']);
Route::get('/buyer-profile/{buyerId}/interests', [App\Http\Controllers\BuyerProfileController::class, 'getBuyerInterests']);

// Seller Inventory Routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/seller-inventory', [App\Http\Controllers\SellerInventoryController::class, 'store']);
    Route::get('/seller-inventory', [App\Http\Controllers\SellerInventoryController::class, 'index']);
    Route::get('/seller-inventory/{id}', [App\Http\Controllers\SellerInventoryController::class, 'show']);
    Route::put('/seller-inventory/{id}', [App\Http\Controllers\SellerInventoryController::class, 'update']);
    Route::post('/seller-inventory/{id}', [App\Http\Controllers\SellerInventoryController::class, 'update']); // For FormData with method override
    Route::delete('/seller-inventory/{id}', [App\Http\Controllers\SellerInventoryController::class, 'destroy']);
});

// Admin Buyer Approval Routes
Route::middleware('auth:sanctum')->prefix('admin')->group(function () {
    Route::get('/buyer-requests', [App\Http\Controllers\admin\BuyerApprovalController::class, 'index']);
    Route::get('/buyer-requests/all', [App\Http\Controllers\admin\BuyerApprovalController::class, 'getAll']);
    Route::post('/buyer-requests/{id}/approve', [App\Http\Controllers\admin\BuyerApprovalController::class, 'approve']);
    Route::post('/buyer-requests/{id}/reject', [App\Http\Controllers\admin\BuyerApprovalController::class, 'reject']);
    Route::get('/buyer-requests/statistics', [App\Http\Controllers\admin\BuyerApprovalController::class, 'statistics']);
    
    // Card Request Management Routes
    Route::get('/card-requests', [CardRequestController::class, 'index']);
    Route::get('/card-requests/{id}', [CardRequestController::class, 'show']);
    Route::post('/card-requests/{id}/approve', [CardRequestController::class, 'approve']);
    Route::post('/card-requests/{id}/reject', [CardRequestController::class, 'reject']);
    Route::get('/card-requests/statistics', [CardRequestController::class, 'statistics']);
});

// Promotion routes
Route::prefix('promotions')->group(function () {
    Route::get('/spotlight', [PromotionCardController::class, 'spotlight']);
    Route::get('/status', [PromotionCardController::class, 'status']);
    Route::get('/mine', [PromotionCardController::class, 'mine'])->middleware('auth:sanctum');
    Route::post('/', [PromotionCardController::class, 'create'])->middleware('auth:sanctum');
    Route::post('/{id}/view', [PromotionCardController::class, 'view']);
});
