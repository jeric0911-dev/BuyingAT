import 'package:classified/controller/transection_controller.dart';
import 'package:classified/utils/app_fonts.dart';
import 'package:classified/widget/no_data_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../utils/app_color.dart';
import '../../controller/user_data_controller.dart';
import '../../helper/date_converter_helper.dart';
import '../../model/transection_model.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_text.dart';
import '../../widget/custom_app_bar.dart';
import '../../widget/custom_button.dart';
import '../../widget/profile_widgets/wallet_items.dart';
import '../../widget/profile_widgets/wallet_screen_history.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late UserDataController userDataController;
  late TransectionController transectionController;


  @override
  void initState() {
    super.initState();
    userDataController = Get.find<UserDataController>();
    userDataController.fetchUserData();
    transectionController = Get.find<TransectionController>();
    transectionController.transactionHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backGround,
      appBar: CustomAppBar(
        title: AppText.wallet,
        action: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              height: 30.h,
              width: 104.w,
              color: AppColor.buttonColor,
              text: AppText.recharge,
              borderRadius: 6.r,
              textStyle: sansBold.copyWith(
                  fontSize: 16.sp, color: AppColor.white),
              onPressed: () {
                 Get.toNamed(Routes.rechargeScreenRoute);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: RefreshIndicator(
          displacement: 60,
          color: AppColor.ghostWhite,
          backgroundColor: AppColor.buttonColor,
          onRefresh: () async {
            await userDataController.fetchUserData();
            await transectionController.transactionHistory(isReload: true);
          },
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() {
                    return Skeletonizer(
                      enabled: userDataController.isUserDataLoading.value,
                      child: WalletItems(
                        type: AppText.balance,
                        balance: userDataController.userData.value.wallet
                            ?.balance ?? '0',
                        color: AppColor.buttonColor,
                      ),
                    );
                  }),
                  Obx(() {
                    return Skeletonizer(
                      enabled: userDataController.isUserDataLoading.value,
                      child: WalletItems(
                        type: AppText.expense,
                        balance: userDataController.userData.value.wallet?.expense ?? '0',
                        color: AppColor.amberOrange,
                      ),
                    );
                  }),
                  Obx(() {
                    return Skeletonizer(
                      enabled: userDataController.isUserDataLoading.value,
                      child: WalletItems(
                        type: AppText.lastRecharge,
                        balance: userDataController.userData.value.wallet?.lastRecharge ?? '0',
                        color: AppColor.leafGreen,
                      ),
                    );
                  }),
                ],
              ),
              SizedBox(height: 10.h,),
              Expanded(
                child: Obx(() {
                  final isLoading = transectionController.isTransactionLoading.value;
                  if(transectionController.transactionList.isEmpty && !isLoading) {
                    return NoDataWidget(text: AppText.noTransectionHistory);
                  }
                  return Skeletonizer(
                    enabled: transectionController.isTransactionLoading.value,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsets.only(top: 10.h),
                      itemCount: isLoading ? 3 : transectionController.transactionList.length,
                      itemBuilder: (context, index) {
                        final item = isLoading ? TransactionsData() :transectionController.transactionList[index];
                        return WalletScreenHistory(
                          transId: item.transactionId.toString(),
                          initiated: calculateDuration(item.initiated.toString()) ,
                          amount: item.credits  ?? '' ,
                          conversion: item.conversion ?? '',
                          status: item.status ?? '',
                          convertAmount: "${item.amount ?? ''} ${item.currency ?? ''}",
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
