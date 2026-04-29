import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/search_controller.dart' as search_controller;
import '../model/card_model.dart';
import '../model/buyer_profile_model.dart';
import '../routes/app_routes.dart';
import '../service/api/api_client.dart';
import '../transition/fade_transition.dart';
import '../utils/_constant.dart';
import '../utils/app_color.dart';
import '../utils/app_fonts.dart';
import '../utils/image_loader.dart';
import '../widget/custom_app_bar.dart';
import '../widget/custom_snackbar_widget.dart';

class SearchResultsScreen extends StatefulWidget {
  final String searchQuery;
  
  const SearchResultsScreen({
    super.key,
    required this.searchQuery,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late search_controller.UnifiedSearchController searchController;

  @override
  void initState() {
    super.initState();
    final apiClient = Get.find<ApiClient>();
    searchController = Get.put(
      search_controller.UnifiedSearchController(apiClient: apiClient),
      tag: 'search_results',
    );
    
    // Perform search when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchController.search(widget.searchQuery);
    });
  }

  @override
  void dispose() {
    Get.delete<search_controller.UnifiedSearchController>(tag: 'search_results');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(
        title: 'Search Results',
        onTapBack: () => Get.back(),
      ),
      body: Obx(() {
        if (searchController.isLoading.value) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(40.h),
              child: CircularProgressIndicator(color: AppColor.buttonColor),
            ),
          );
        }

        final hasCards = searchController.hasCards.value;
        final hasBuyerProfiles = searchController.hasBuyerProfiles.value;

        if (!hasCards && !hasBuyerProfiles) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(40.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64.w,
                    color: AppColor.coolGray21,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No results found',
                    style: sansSemiBold.copyWith(
                      fontSize: 18.sp,
                      color: AppColor.primaryColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Try different keywords',
                    style: sansReg.copyWith(
                      fontSize: 14.sp,
                      color: AppColor.coolGray21,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Query Display
              Text(
                'Results for "${widget.searchQuery}"',
                style: sansSemiBold.copyWith(
                  fontSize: 16.sp,
                  color: AppColor.primaryColor,
                ),
              ),
              SizedBox(height: 24.h),
              
              // Cards Section
              if (hasCards) ...[
                Text(
                  'Cards',
                  style: sansSemiBold.copyWith(
                    fontSize: 18.sp,
                    color: AppColor.primaryColor,
                  ),
                ),
                SizedBox(height: 12.h),
                Obx(() => searchController.isCardsLoading.value
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.h),
                          child: CircularProgressIndicator(color: AppColor.buttonColor),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: searchController.cardsList.length,
                        itemBuilder: (context, index) {
                          final card = searchController.cardsList[index];
                          return _buildCardItem(card);
                        },
                      )),
                SizedBox(height: 32.h),
              ],
              
              // Buyer Profiles Section
              if (hasBuyerProfiles) ...[
                Text(
                  'Buyer Profiles',
                  style: sansSemiBold.copyWith(
                    fontSize: 18.sp,
                    color: AppColor.primaryColor,
                  ),
                ),
                SizedBox(height: 12.h),
                Obx(() => searchController.isBuyerProfilesLoading.value
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.h),
                          child: CircularProgressIndicator(color: AppColor.buttonColor),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: searchController.buyerProfilesList.length,
                        itemBuilder: (context, index) {
                          final profile = searchController.buyerProfilesList[index];
                          return _buildBuyerProfileItem(profile);
                        },
                      )),
              ],
              
              SizedBox(height: 40.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCardItem(CardItem card) {
    final imageUrl = card.images != null
        ? (card.images is String
            ? card.images
            : (card.images is List && (card.images as List).isNotEmpty
                ? (card.images as List)[0].toString()
                : null))
        : null;

    return GestureDetector(
      onTap: () {
        // Navigate to card details if needed
        // For now, just show a message
        showCustomSnackBar('Card: ${card.cardTitle ?? "Untitled"}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          border: Border.all(color: AppColor.coolGray17, width: 1),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Image
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColor.ghostWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.r),
                    topRight: Radius.circular(8.r),
                  ),
                ),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.r),
                          topRight: Radius.circular(8.r),
                        ),
                        child: ImageLoader(
                          url: '${Constant.imageBaseUrl}$imageUrl',
                          width: double.infinity,
                          height: double.infinity,
                          boxFit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.image,
                          size: 48.w,
                          color: AppColor.coolGray21,
                        ),
                      ),
              ),
            ),
            
            // Card Info
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.cardTitle ?? 'Untitled',
                    style: sansMedium.copyWith(
                      fontSize: 12.sp,
                      color: AppColor.primaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '\$${card.price ?? '0'}',
                    style: sansSemiBold.copyWith(
                      fontSize: 14.sp,
                      color: AppColor.buttonColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyerProfileItem(BuyerProfile profile) {
    final user = profile.user;
    final username = user?.profile?.username ?? user?.name ?? 'Buyer';
    final avatar = user?.profile?.avatar;
    final categories = profile.categories ?? [];
    
    return GestureDetector(
      onTap: () {
        FadeScreenTransition(
          routeName: Routes.buyerProfileDetailRoute,
          arguments: profile.id,
        ).navigate();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          border: Border.all(color: AppColor.coolGray17, width: 1),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar and Username
              Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.buttonColor.withOpacity(0.1),
                    ),
                    child: avatar != null && avatar.isNotEmpty
                        ? ClipOval(
                            child: ImageLoader(
                              url: '${Constant.imageBaseUrl}$avatar',
                              width: 48.w,
                              height: 48.w,
                              boxFit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Text(
                              username.isNotEmpty ? username[0].toUpperCase() : 'B',
                              style: sansSemiBold.copyWith(
                                fontSize: 20.sp,
                                color: AppColor.buttonColor,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      username,
                      style: sansMedium.copyWith(
                        fontSize: 14.sp,
                        color: AppColor.primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12.h),
              
              // Categories
              if (categories.isNotEmpty) ...[
                Text(
                  'Categories:',
                  style: sansReg.copyWith(
                    fontSize: 10.sp,
                    color: AppColor.coolGray21,
                  ),
                ),
                SizedBox(height: 4.h),
                Wrap(
                  spacing: 4.w,
                  runSpacing: 4.h,
                  children: categories.take(3).map((category) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        category,
                        style: sansReg.copyWith(
                          fontSize: 8.sp,
                          color: Colors.green.shade700,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

