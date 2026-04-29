import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controller/recharge_controller.dart';
import '../../utils/app_color.dart';
import '../../utils/app_text.dart';
import '../../widget/custom_app_bar.dart';
import '../../widget/custom_button.dart';
import '../../widget/custom_drop_dawn_btn.dart';
import '../../widget/custom_dropdown_widget.dart';
import '../../widget/custom_text_field_widget.dart';
import '../../widget/custom_title_bar.dart';

class RechargeScreen extends StatefulWidget {
  const RechargeScreen({super.key});

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  late RechargeController rechargeController;

  List<DropdownItem<int>> identityTypeList = [];

  @override
  void initState() {
    super.initState();
    rechargeController = Get.find<RechargeController>();
    rechargeController.gateway();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(title: AppText.recharge),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              CustomTitleBar(title: AppText.selectGateway),
              SizedBox(height: 3.h),
              Obx(() {
                return CustomDropDawnBtn(
                  items: rechargeController.paymentGatewayList.value,
                  onChange: (int? value, int index) {
                    rechargeController.paymentCurrencyList.clear();
                    rechargeController.filterCurrencyByGateway(value!);
                    rechargeController.getGatewayNameByGateway(value);
                  },
                  title: 'Select Gateway',
                  btnHeight: 48.h,
                  isIndexValue: true,
                );
              }),


              SizedBox(height: 24.h),
              CustomTitleBar(title: AppText.selectCurrency),
              SizedBox(height: 3.h),
              Obx(() {
                return CustomDropDawnBtn(
                  items: rechargeController.paymentCurrencyList.value,
                  onChange: (int? value, int index) {
                    final selectedItem = rechargeController
                        .paymentCurrencyList[index];
                    final paddingWidget = selectedItem.child as Padding;
                    final textWidget = paddingWidget.child as Text;
                    rechargeController.currencyName.value =
                        textWidget.data ?? '';
                  },
                  title: 'Select Gateway',
                  btnHeight: 48.h,
                  isIndexValue: true,
                );
              }),

              SizedBox(height: 24.h),
              CustomTextFieldWidget(
                showTitle: true,
                hintText: AppText.enterAmount,
                titleText: AppText.enterAmount,
                controller: rechargeController.amount,
                inputType: TextInputType.number,
                focusNode: rechargeController.fAmountNode,
              ),

          Obx(() {
            if (rechargeController.gatewayName.value == 'SSLCommerz') {
              return Column(
                children: [
                  SizedBox(height: 24.h),
                  CustomTextFieldWidget(
                    showTitle: true,
                    titleText: AppText.phone,
                    hintText: AppText.phone,
                    controller: rechargeController.phoneNumber,
                    inputType: TextInputType.number,
                    focusNode: rechargeController.fPhone,
                  ),
                ],
              );
            } else {
              return SizedBox(); // or Container() if you prefer
            }
          }),


              SizedBox(height: 32.h,),
              Obx(() {
                return CustomButton(
                    height: 48.h,
                    marginRight: 0,
                    marginLeft: 0,
                    isLoading: rechargeController.isPaymentLoading.value,
                    text: AppText.recharge,
                    onPressed: () {
                      if (rechargeController.gatewayName.value == 'SSLCommerz') {
                        rechargeController.sslCommerce();
                      }
                      else if (rechargeController.gatewayName.value == 'Stripe') {
                        rechargeController.stripe();
                      }
                      else if (rechargeController.gatewayName.value == 'Paypal') {
                        rechargeController.paypalPayment();
                      }
                      else if (rechargeController.gatewayName.value == 'Razorpay') {
                        rechargeController.razorpayPayment();
                      }
                    }
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
