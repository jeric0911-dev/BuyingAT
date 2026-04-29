import 'package:classified/controller/affiliate_controller.dart';
import 'package:classified/controller/user_data_controller.dart';
import 'package:classified/utils/app_color.dart';
import 'package:classified/utils/app_fonts.dart';
import 'package:classified/utils/_constant.dart';
import 'package:classified/widget/custom_app_bar.dart';
import 'package:classified/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AffiliateScreen extends StatefulWidget {
  const AffiliateScreen({super.key});

  @override
  State<AffiliateScreen> createState() => _AffiliateScreenState();
}

class _AffiliateScreenState extends State<AffiliateScreen> {
  late UserDataController userDataController;
  late AffiliateController affiliateController;

  @override
  void initState() {
    super.initState();
    userDataController = Get.find<UserDataController>();
    // Reuse existing AffiliateController if present, otherwise create one
    affiliateController = Get.isRegistered<AffiliateController>()
        ? Get.find<AffiliateController>()
        : Get.put(AffiliateController(apiClient: Get.find()));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      affiliateController.fetchAffiliateStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(
        title: 'Affiliate & Referrals',
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Obx(() {
          final isLoading = affiliateController.isLoading.value ||
              userDataController.isUserDataLoading.value;

          return Skeletonizer(
            enabled: isLoading,
            child: _AffiliateSection(
              userDataController: userDataController,
              affiliateController: affiliateController,
            ),
          );
        }),
      ),
    );
  }
}

class _AffiliateSection extends StatelessWidget {
  final UserDataController userDataController;
  final AffiliateController affiliateController;

  const _AffiliateSection({
    required this.userDataController,
    required this.affiliateController,
  });

  String _buildAffiliateCode() {
    final id = userDataController.userData.value.id;
    if (id == null) return '';
    final paddedId = id.toString().padLeft(6, '0');
    return 'REF$paddedId';
  }

  String _buildReferralLink() {
    final code = _buildAffiliateCode();
    if (code.isEmpty) return '';
    // Frontend login URL for referrals
    return '${Constant.shareLink}/login?ref_code=$code';
  }

  @override
  Widget build(BuildContext context) {
    final stats = affiliateController.stats.value;
    final referralLink = _buildReferralLink();
    final affiliateCode = _buildAffiliateCode();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Referral link + copy
        Text(
          'Referral link',
          style: sansReg.copyWith(
            fontSize: 13.sp,
            color: AppColor.coolGray14,
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: AppColor.coolGray12),
                ),
                child: Text(
                  referralLink.isEmpty ? 'Not available' : referralLink,
                  style: sansReg.copyWith(
                    fontSize: 13.sp,
                    color: AppColor.primaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            CustomButton(
              width: 80.w,
              height: 36.h,
              marginLeft: 0,
              marginRight: 0,
              text: 'Copy',
              textStyle: sansBold.copyWith(
                fontSize: 12.sp,
                color: Colors.white,
              ),
              onPressed: referralLink.isEmpty
                  ? null
                  : () async {
                      await Clipboard.setData(
                        ClipboardData(text: referralLink),
                      );
                    },
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // Affiliate code
        if (affiliateCode.isNotEmpty) ...[
          Text(
            'Affiliate code',
            style: sansReg.copyWith(
              fontSize: 13.sp,
              color: AppColor.coolGray14,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            affiliateCode,
            style: sansSemiBold.copyWith(
              fontSize: 15.sp,
              color: AppColor.primaryColor,
            ),
          ),
          SizedBox(height: 16.h),
        ],

        // Stats
        _statRow(
          label: 'Total referred users',
          value: (stats.totalReferredUsers ?? 0).toString(),
        ),
        SizedBox(height: 4.h),
        _statRow(
          label: 'Referred sales volume',
          value:
              '\$${(stats.totalReferredSalesVolume ?? 0).toStringAsFixed(2)}',
        ),
        SizedBox(height: 4.h),
        _statRow(
          label: 'Total commissions earned',
          value: '\$${(stats.totalCommissions ?? 0).toStringAsFixed(2)}',
        ),
        SizedBox(height: 4.h),
        _statRow(
          label: 'Pending commissions',
          value: '\$${(stats.pendingCommissions ?? 0).toStringAsFixed(2)}',
        ),
        SizedBox(height: 4.h),
        _statRow(
          label: 'Paid commissions',
          value: '\$${(stats.paidCommissions ?? 0).toStringAsFixed(2)}',
        ),
      ],
    );
  }

  Widget _statRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: sansReg.copyWith(
              fontSize: 13.sp,
              color: AppColor.coolGray14,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          value,
          style: sansSemiBold.copyWith(
            fontSize: 14.sp,
            color: AppColor.primaryColor,
          ),
        ),
      ],
    );
  }
}


