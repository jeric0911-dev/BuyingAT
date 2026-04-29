import 'package:classified/controller/account_settings_controller.dart';
import 'package:classified/controller/get_country_city_controller.dart';
import 'package:classified/utils/app_color.dart';
import 'package:classified/utils/app_text.dart';
import 'package:classified/widget/custom_app_bar.dart';
import 'package:classified/widget/custom_button.dart';
import 'package:classified/widget/custom_text_field_widget.dart';
import 'package:classified/widget/custom_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../widget/custom_drop_dawn_btn.dart';

class BillingAddressScreen extends StatefulWidget {
  const BillingAddressScreen({super.key});

  @override
  State<BillingAddressScreen> createState() => _BillingAddressScreenState();
}

class _BillingAddressScreenState extends State<BillingAddressScreen> {
  late AccountSettingsController accountSettingsController;
  late GetCountryCityController getCountryCityController;

  @override
  void initState() {
    super.initState();
    accountSettingsController = Get.find<AccountSettingsController>();
    getCountryCityController = Get.find<GetCountryCityController>();
    Future.delayed(Duration.zero, () {
      accountSettingsController.fetchBillingData();
    });

    ever(accountSettingsController.billingData, (billingData) {
      fetchCityAndCountry(billingData.countryId, billingData.cityId);
      accountSettingsController.firstNameBilling.text =
          billingData.firstName ?? '';
      accountSettingsController.lastNameBilling.text =
          billingData.lastName ?? '';
      accountSettingsController.emailBilling.text = billingData.email ?? '';
      accountSettingsController.addressBilling.text = billingData.address ?? '';
      accountSettingsController.countryIdBilling.value = billingData.countryId ?? 0;
      accountSettingsController.cityIdBilling.value = billingData.cityId ?? 0;
      accountSettingsController.companyNameBilling.text =
          billingData.companyName ?? '';
      accountSettingsController.phoneNumberBilling.text =
          billingData.phone ?? '';
      accountSettingsController.zipCodeBilling.text = billingData.zipCode ?? '';
    });
  }

  void fetchCityAndCountry(int? countryIdBilling, int? cityIdBilling) async {
     await getCountryCityController.fetchCountry();
     await getCountryCityController.fetchCity();
    getCountryCityController.filterCountryByCountryIdBilling(
        countryIdBilling ?? 0);
    getCountryCityController.filterCityByCityIdBilling(cityIdBilling ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            title: AppText.billingAddress,
          ),
          body: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            children: [
              SizedBox(height: 16.h,),
              CustomTextFieldWidget(
                controller: accountSettingsController.firstNameBilling,
                focusNode: accountSettingsController.fFirstNameBilling,
                nextFocus: accountSettingsController.fLastNameBilling,
                titleText: AppText.firstName,
                hintText: AppText.firstName,
                showTitle: true,
                inputType: TextInputType.text,
              ),

              SizedBox(height: 16.h,),
              CustomTextFieldWidget(
                controller: accountSettingsController.lastNameBilling,
                focusNode: accountSettingsController.fLastNameBilling,
                nextFocus: accountSettingsController.fCompanyNameBilling,
                titleText: AppText.lastName,
                hintText: AppText.lastName,
                showTitle: true,
                inputType: TextInputType.text,
              ),


              SizedBox(height: 16.h,),
              CustomTextFieldWidget(
                controller: accountSettingsController.companyNameBilling,
                focusNode: accountSettingsController.fCompanyNameBilling,
                nextFocus: accountSettingsController.fEmailBilling,
                titleText: AppText.companyName,
                hintText: AppText.companyName,
                showTitle: true,
                inputType: TextInputType.text,
              ),

              SizedBox(height: 16.h,),
              CustomTextFieldWidget(
                controller: accountSettingsController.emailBilling,
                focusNode: accountSettingsController.fEmailBilling,
                nextFocus: accountSettingsController.fAddressBillingBilling,
                titleText: AppText.email,
                hintText: AppText.demoGmail,
                showTitle: true,
                inputType: TextInputType.emailAddress,
              ),

              SizedBox(height: 16.h,),
              CustomTextFieldWidget(
                controller: accountSettingsController.addressBilling,
                focusNode: accountSettingsController.fAddressBillingBilling,
                nextFocus: accountSettingsController.fPhoneNumberBilling,
                titleText: AppText.address,
                hintText: AppText.address,
                showTitle: true,
                inputType: TextInputType.text,
              ),

              SizedBox(height: 16.h,),
              CustomTextFieldWidget(
                controller: accountSettingsController.phoneNumberBilling,
                focusNode: accountSettingsController.fPhoneNumberBilling,
                nextFocus: accountSettingsController.fZipCodeBilling,
                titleText: AppText.phoneNumber,
                hintText: AppText.phoneNumber,
                showTitle: true,
                inputType: TextInputType.number,
              ),

              SizedBox(height: 16.h,),
              CustomTitleBar(title: AppText.countryRegion),
              SizedBox(height: 3.h),
              Obx(() {
                return CustomDropDawnBtn(
                  items: getCountryCityController.countrySelectedList.value,
                  onChange: (int? value, int index) {
                    getCountryCityController.filterCountryByCountryIdBilling(
                        value!);
                    getCountryCityController.filterCitiesByCountryBilling(
                        value);
                    accountSettingsController.countryIdBilling.value = value;
                    // rechargeController.filterCurrencyByGateway(value!);
                    // rechargeController.getGatewayNameByGateway(value);
                  },
                  title: accountSettingsController.countryNameBilling.value
                      .isEmpty
                      ? 'Select Country'
                      : accountSettingsController.countryNameBilling.value,
                  btnHeight: 50.h,
                  isSelected: accountSettingsController.countryNameBilling.value
                      .isEmpty ? false : true,
                );
              }),


              SizedBox(height: 16.h,),
              CustomTitleBar(title: AppText.city),
              SizedBox(height: 3.h),
              Obx(() {
                return CustomDropDawnBtn(
                  items: getCountryCityController.citySelectedList.value,
                  onChange: (int? value, int index) {
                    // getCountryCityController.filterCountryByCountryId(value!);
                    // getCountryCityController.filterCitiesByCountry(value);
                    // accountSettingsController.countryId.value = value;
                    // rechargeController.filterCurrencyByGateway(value!);
                    // rechargeController.getGatewayNameByGateway(value);
                  },
                  title: accountSettingsController.cityNameBilling.value.isEmpty
                      ? 'Select Country'
                      : accountSettingsController.cityNameBilling.value,
                  btnHeight: 50.h,
                  isSelected: accountSettingsController.cityNameBilling.value
                      .isEmpty
                      ? false
                      : true,
                );
              }),

              SizedBox(height: 16.h,),
              CustomTextFieldWidget(
                controller: accountSettingsController.zipCodeBilling,
                focusNode: accountSettingsController.fZipCodeBilling,
                titleText: AppText.zipCode,
                hintText: AppText.zipCode,
                showTitle: true,
                inputType: TextInputType.number,
              ),

              SizedBox(height: 25.h,),
              Obx(() {
                return CustomButton(
                  isLoading: accountSettingsController.isUpdateBillingLoading.value,
                  marginLeft: 0,
                  marginRight: 0,
                  onPressed: (){
                    accountSettingsController.updateBilling();
                  },
                  text: AppText.saveChanges,
                );
              }),

              SizedBox(height: 42.h,),
            ],
          ),
        ),
        Obx(() =>
        (accountSettingsController.isBillingLoading.value)
            ? CircularProgressIndicator(
          color: AppColor.buttonColor,
          strokeWidth: 3,
        )
            : SizedBox.shrink(),
        )

      ],
    );
  }
}
