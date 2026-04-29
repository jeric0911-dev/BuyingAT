import 'package:classified/model/country_city_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../service/api/api_client.dart';
import '../service/api/api_retry_manager.dart';
import '../utils/_constant.dart';
import '../widget/custom_dropdown_widget.dart';
import 'account_settings_controller.dart';

class GetCountryCityController extends GetxController {
  ApiClient apiClient;

  GetCountryCityController({required this.apiClient});

  // @override
  // void onInit() {
  //
  //   super.onInit();
  // }

  /// get country
  var countryList = <CountryCityData>[].obs;
  var countrySelectedList = <DropdownItem<int>>[].obs;
  var isLoadingCountry = false.obs;

  Future<void> fetchCountry({bool isReload = false}) async {
    if (isReload) {
      countryList.clear();
    }
    isLoadingCountry.value = true;
    try {
      http.Response? response = await apiClient.getData(Constant.countriesUrl);
      if (response.statusCode == 200) {
        CountryCityModel countryCityModel = countryCityModelFromJson(
          response.body,
        );
        countryList.value = countryCityModel.data ?? [];
        countrySelectedList.value = generateDropdownItems<CountryCityData>(
          countryList,
              (country) => country.countryName,
              (country) => country.id,
        );

      }
    } catch (_) {
      apiRetryManager.addRequest(() {});
    } finally {
      isLoadingCountry.value = false;
    }
  }

  /// get city
  var cityList = <CountryCityData>[].obs;
  var citySelectedList = <DropdownItem<int>>[].obs;
  var isLoadingCity = false.obs;
  var isLoadingCategory = true.obs;
  Future<void> fetchCity({bool isReload = false}) async {
    if (isReload) {
      cityList.clear();
    }
    isLoadingCity.value = true ;
    try {
      http.Response? response = await apiClient.getData(Constant.citiesUrl);
      if (response.statusCode == 200) {
        CountryCityModel countryCityModel = countryCityModelFromJson(response.body);
        cityList.value = countryCityModel.data ?? [];
        citySelectedList.value = generateDropdownItems<CountryCityData>(
          cityList,
              (city) => city.cityName,
              (city) => city.id,
        );

      }
    } catch (_) {
      apiRetryManager.addRequest(() {});
    } finally {
      isLoadingCategory.value = false;
      isLoadingCity.value = false;
    }
  }

  /// drop dawn list


  List<DropdownItem<int>> generateDropdownItems<T>(
      List<T> list,
      String? Function(T) getName,
      int? Function(T) getId,
      ) {
    return list.map((item) {
      return DropdownItem<int>(
        value: getId(item),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(getName(item) ?? ''),
        ),
      );
    }).toList();
  }

/// Order Activity ---------------------------
  /// Filter Country Name based on selected countryId
  void filterCountryByCountryId(int countryId) {
    final match = countryList.firstWhere(
          (element) => element.id == countryId,
      orElse: () => CountryCityData(id: 0, countryName: ''),
    );
    Get.find<AccountSettingsController>().countryName.value = match.countryName!;
  }


  /// Filter cities based on selected country
  void filterCitiesByCountry(int countryId) {
    final filteredCities = cityList.where((city) => city.countryId == countryId).toList();

    citySelectedList.value = generateDropdownItems<CountryCityData>(
      filteredCities,
          (city) => city.cityName,
          (city) => city.id,
    );

    if (filteredCities.isNotEmpty) {
      Get.find<AccountSettingsController>().cityName.value = filteredCities.first.cityName ?? '';
    } else {
      Get.find<AccountSettingsController>().cityName.value = '';
    }
  }

  void filterCityByCityId(int cityId) {
    final match = cityList.firstWhere(
          (element) => element.id == cityId,
      orElse: () => CountryCityData(id: 0, cityName: ''),
    );

    Get.find<AccountSettingsController>().cityName.value = match.cityName!;
  }


  /// Billing Address -----------------------

  /// Filter CountryName based on selected  Billing countryId
  void filterCountryByCountryIdBilling(int countryIdBilling) {
    final match = countryList.firstWhere(
          (element) => element.id == countryIdBilling,
      orElse: () => CountryCityData(id: 0, countryName: ''),
    );
    Get.find<AccountSettingsController>().countryNameBilling.value = match.countryName!;
  }


  /// Filter cities based on selected country Billing Address
  void filterCitiesByCountryBilling(int countryIdBilling) {
    final filteredCities = cityList.where((city) => city.countryId == countryIdBilling).toList();

    citySelectedList.value = generateDropdownItems<CountryCityData>(
      filteredCities,
          (city) => city.cityName,
          (city) => city.id,
    );

    if (filteredCities.isNotEmpty) {
      Get.find<AccountSettingsController>().cityNameBilling.value = filteredCities.first.cityName ?? '';
    } else {
      Get.find<AccountSettingsController>().cityNameBilling.value = '';
    }
  }

  void filterCityByCityIdBilling(int cityIdBilling) {
    final match = cityList.firstWhere(
          (element) => element.id == cityIdBilling,
      orElse: () => CountryCityData(id: 0, cityName: ''),
    );

    Get.find<AccountSettingsController>().cityNameBilling.value = match.cityName!;
  }


  ///  Shipping Address -----------------------
  /// Filter CountryName based on selected  Shipping countryId
  void filterCountryByCountryIdShipping(int countryIdShipping) {
    final match = countryList.firstWhere(
          (element) => element.id == countryIdShipping,
      orElse: () => CountryCityData(id: 0, countryName: ''),
    );
    Get.find<AccountSettingsController>().countryNameShipping.value = match.countryName!;
  }


  /// Filter cities based on selected country Shipping Address
  void filterCitiesByCountryShipping(int countryIdShipping) {
    final filteredCities = cityList.where((city) => city.countryId == countryIdShipping).toList();

    citySelectedList.value = generateDropdownItems<CountryCityData>(
      filteredCities,
          (city) => city.cityName,
          (city) => city.id,
    );

    if (filteredCities.isNotEmpty) {
      Get.find<AccountSettingsController>().cityNameShipping.value = filteredCities.first.cityName ?? '';
    } else {
      Get.find<AccountSettingsController>().cityNameShipping.value = '';
    }
  }

  void filterCityByCityIdShipping(int cityIdShipping) {
    final match = cityList.firstWhere(
          (element) => element.id == cityIdShipping,
      orElse: () => CountryCityData(id: 0, cityName: ''),
    );

    Get.find<AccountSettingsController>().cityNameShipping.value = match.cityName!;
  }



// /// get phone_code selected country
  // void getPhoneCodeByCountry(int countryId) {
  //   final country = countryList.firstWhere(
  //         (country) => country.id == countryId,
  //   );
  //   authController.selectedCountryCode.value = country.phoneCode ?? '';
  //   authController.selectedCountryName.value = country.countryName ?? '';
  // }


}



