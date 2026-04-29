import 'dart:convert';
import 'package:classified/model/card_model.dart';
import 'package:classified/model/product_model.dart';
import 'package:classified/model/user_data_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../service/api/api_client.dart';
import '../../../service/api/api_retry_manager.dart';
import '../../../utils/_constant.dart';
import 'package:http/http.dart' as http;

import '../../widget/custom_snackbar_widget.dart';
import '../helper/drop_down_helper.dart';
import '../model/products_model.dart';
import '../widget/custom_dropdown_widget.dart';

class DashboardController extends GetxController {
  ApiClient apiClient;

  DashboardController({required this.apiClient});

  final List<String> statusOptions = [
    'All',
    'Active',
    'Pending',
    'Rejected',
  ];

  String? get apiStatusValue {
    switch (selectedStatus.value) {
      case 'All':
        return null; // Return null for "All" to fetch all statuses
      case 'Active':
        return 'active';
      case 'Pending':
        return 'pending';
      case 'Rejected':
        return 'reject';
      default:
        return 'active';
    }
  }
  RxString selectedStatus = 'Active'.obs;

  void setStatus(String status) {
    selectedStatus.value = status;
    myProperty();
    fetchMyCards(isReload: true);
  }

  /// my property
  var isLoading = false.obs;
  var myProductsList = <ProductsItem>[].obs;
  
  /// my cards (seller inventory)
  var isCardsLoading = false.obs;
  var myCardsList = <dynamic>[].obs;
  var cardPromotionStatus = <int, bool>{}.obs; // Map of cardId -> isPromoted
  var sizeSelectedList = <DropdownItem<int>>[].obs;
  var variantSelectedList = <DropdownItem<int>>[].obs;
  var colorSelectedList = <DropdownItem<int>>[].obs;

  var productStockList = <ProductStock>[].obs;

  Future<void> myProperty({bool isReload = false}) async {
    if (isReload) {}
    isLoading.value =true;
    try {
      Map<String, dynamic>? query;
      if (apiStatusValue != null) {
        query = {"status": apiStatusValue};
      }
      http.Response? response= await apiClient.getData(Constant.myProductsUrl,query: query);
      if (response.statusCode == 200) {
        ProductsModel productsModel = productsModelFromJson(response.body);
        myProductsList.value = productsModel.data ?? [];
      }
    } catch (_) {
      apiRetryManager.addRequest(() {});
    } finally {

      isLoading.value =false;
    }
  }

  /// Fetch my cards (seller inventory)
  Future<void> fetchMyCards({bool isReload = false}) async {
    if (isReload) {
      myCardsList.clear();
      cardPromotionStatus.clear();
    }
    isCardsLoading.value = true;
    try {
      Map<String, dynamic>? query;
      // Map status to backend format
      String? statusParam;
      switch (selectedStatus.value) {
        case 'All':
          statusParam = 'all';
          break;
        case 'Active':
          statusParam = 'approved';
          break;
        case 'Pending':
          statusParam = 'pending';
          break;
        case 'Rejected':
          statusParam = 'rejected';
          break;
        default:
          statusParam = 'all';
      }
      
      if (statusParam != 'all') {
        query = {"status": statusParam};
      }
      
      http.Response? response = await apiClient.getData(Constant.sellerInventoryUrl, query: query);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['data'] != null && json['data'] is List) {
          myCardsList.value = json['data'] as List;
          // Check promotion status for each card
          _checkPromotionStatuses();
        } else {
          myCardsList.value = [];
        }
      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        fetchMyCards();
      });
    } finally {
      isCardsLoading.value = false;
    }
  }

  /// Check promotion status for all cards
  Future<void> _checkPromotionStatuses() async {
    for (var cardData in myCardsList) {
      try {
        final card = CardItem.fromJson(cardData);
        if (card.id != null) {
          await checkPromotionStatus(card.id!);
        }
      } catch (e) {
        // Skip invalid cards
      }
    }
  }

  /// Check promotion status for a single card
  Future<void> checkPromotionStatus(int cardId) async {
    try {
      http.Response? response = await apiClient.getData(
        '${Constant.promotionsUrl}/status',
        query: {'card_id': cardId},
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success' && json['data'] != null) {
          final isActive = json['data']['active'] == true;
          cardPromotionStatus[cardId] = isActive;
        } else {
          cardPromotionStatus[cardId] = false;
        }
      } else {
        cardPromotionStatus[cardId] = false;
      }
    } catch (e) {
      cardPromotionStatus[cardId] = false;
    }
  }

  /// Check if a card is promoted
  bool isCardPromoted(int? cardId) {
    if (cardId == null) return false;
    return cardPromotionStatus[cardId] == true;
  }


  List<TextEditingController> stockControllers = [];
  final stockCtrl = TextEditingController();
  final FocusNode fStockCtrl = FocusNode();

  RxList<ProductStockRow> stockRows = <ProductStockRow>[].obs;



  /// stock management
  var isProductStockLoading = false.obs;
  void stockManagement({dynamic productId}) {
    final product = myProductsList.firstWhere((p) => p.id == productId, orElse: () => ProductsItem());
    sizeSelectedList.clear();
    variantSelectedList.clear();
    colorSelectedList.clear();
    productStockList.clear();

    ///  added sizes
    if (product.sizes?.isNotEmpty ?? false) {
      sizeSelectedList.value = generateDropdownItems<ProductSize>(
        product.sizes!,
            (sizeItem) => sizeItem.size,
            (sizeItem) => sizeItem.id,
      );
    }

    ///  added variants
    if (product.variants?.isNotEmpty ?? false) {
      variantSelectedList.value = generateDropdownItems<ProductVariant>(
        product.variants!,
            (variantItem) => variantItem.variantName,
            (variantItem) => variantItem.id,
      );
    }

    ///  added colors
    if (product.colors?.isNotEmpty ?? false) {
      colorSelectedList.value = generateDropdownItems<ProductColor>(
        product.colors!,
            (c) => c.colorName,
            (c) => c.id,
      );
    }


    /// added product Stock
    if (product.stocks?.isNotEmpty ?? false) {
      productStockList.addAll(product.stocks!,);
    }


    stockRows.clear();
    for (var stock in product.stocks!) {
      stockRows.add(
        ProductStockRow(
          colorId: stock.colorId,
          variantId: stock.variantId,
          sizeId: stock.sizeId,
          productId: stock.productId,
          stockCtrl: TextEditingController(text: stock.stock.toString()),
        ),
      );
    }
    isProductStockLoading.value = true;

  }

  Future<void> stockCreateAndUpdate({bool isReload = false,  dynamic pId, dynamic body}) async {
    try {
      http.Response? response = await apiClient.postData(
          Constant.stockManageUrl,body
      );

      if (response.statusCode == 201) {
        Get.back();
        showCustomSnackBar("Stock updated successfully",isError: false);
        myProperty(isReload: true);
      }

    } catch (_) {

      apiRetryManager.addRequest(() {stockCreateAndUpdate(pId: pId, body: body);});
    } finally {

    }
  }





  Map<String, int> statusCounts = {
    'active': 0,
    'pending': 0,
    'rejected': 0,
    'featured': 0,
  }.obs;
  int get totalPropertiesAdded {
    final keysToSum = ['active', 'pending', 'rejected'];
    return keysToSum.fold(0, (sum, key) => sum + (statusCounts[key] ?? 0));
  }








  /// delete my property
  Future<void> deleteMyProperty({required int propertyId,bool isReload = false}) async {
    if (isReload) {}

    try {
      http.Response? response= await apiClient.deleteData('${Constant.deletePropertyUrl}/$propertyId');
      if (response.statusCode == 200) {
        myProductsList.removeWhere((property) => property.id == propertyId);
        showCustomSnackBar('Property deleted successfully',isError: false);
      }
    } catch (_) {
      apiRetryManager.addRequest(() {});
    } finally {


    }
  }

  /// Delete card (seller inventory)
  Future<void> deleteCard({required int? cardId}) async {
    if (cardId == null) {
      showCustomSnackBar('Invalid card ID');
      return;
    }

    try {
      http.Response? response = await apiClient.deleteData('${Constant.sellerInventoryUrl}/$cardId');
      if (response.statusCode == 200) {
        myCardsList.removeWhere((card) {
          try {
            final cardItem = CardItem.fromJson(card);
            return cardItem.id == cardId;
          } catch (e) {
            return false;
          }
        });
        showCustomSnackBar('Card deleted successfully', isError: false);
        fetchMyCards(isReload: true);
      } else {
        final responseData = jsonDecode(response.body);
        showCustomSnackBar(responseData['message'] ?? 'Failed to delete card');
      }
    } catch (e) {
      apiRetryManager.addRequest(() {
        deleteCard(cardId: cardId);
      });
      showCustomSnackBar('Error deleting card: ${e.toString()}');
    }
  }



  /// unpublish Property
  Future<void> unpublishProperty({bool isReload = false, required dynamic carId}) async {
    if (isReload) {}

    Map<String, dynamic> body = {
      'product_id':"$carId",
    };

    try {
      http.Response? response = await apiClient.putData(
          Constant.unPublishPropertyUrl,body
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        myProductsList.removeWhere((car) => car.id == carId);
        showCustomSnackBar("Listing has been successfully unpublished.",isError: false);
      }
    } catch (e) {

      apiRetryManager.addRequest(() {});
    } finally {

    }
  }




/// create featured

  var isBoostLoading =  false.obs;
  Future<void> featureProperty({bool isReload = false,  dynamic pId, dynamic duration}) async {
    isBoostLoading.value = true;
    Map<String, dynamic> body = {
      'product_id': pId,
      'duration': duration
    };

    try {
      http.Response? response = await apiClient.postData(
          Constant.boostUrl,body
      );

      if (response.statusCode == 200) {
        Get.back();
        setStatus('Active');
        showCustomSnackBar("Boost complete!",duration: 5);
      }
      else{
        showCustomSnackBar("Something went wrong.\nPlease try again.\n Check Your Wallet",isError: false,duration: 3);
      }
    } catch (e) {

      apiRetryManager.addRequest(() {featureProperty(pId: pId, duration: duration);});
    } finally {
      isBoostLoading.value = false;
    }
  }



  ///  user order data
  var isUserOrderDataLoading = false.obs;
  var userOrderData = UserData().obs;


  Future<void> fetchUserOrderData({bool isReload = false}) async {
    if (isReload) {}
    isUserOrderDataLoading.value =true;
    try {
      http.Response? response= await apiClient.getData(Constant.userOrderDataUrl);
      if (response.statusCode == 200) {
        UserdataModel userdataModel  = userdataModelFromJson(response.body);
        userOrderData.value = userdataModel.data ?? UserData();

      }
    } catch (_) {
      apiRetryManager.addRequest(() {fetchUserOrderData();});
    } finally {

      isUserOrderDataLoading.value =false;
    }
  }

}

class ProductStockRow {
  int? colorId;
  int? variantId;
  int? sizeId;
  int? productId;
  TextEditingController stockCtrl;

  ProductStockRow({
    this.colorId,
    this.variantId,
    this.sizeId,
    this.productId,
    required this.stockCtrl,
  });
}