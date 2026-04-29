import 'dart:convert';

import 'package:classified/controller/cart_dtl_model.dart';
import 'package:classified/controller/home_controller.dart';
import 'package:classified/controller/user_data_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../model/cart_card_model.dart';
import '../model/cart_product_model.dart';
import '../model/wish_list_model.dart';
import '../model/card_model.dart';
import '../routes/app_routes.dart';
import '../service/api/api_client.dart';
import 'package:http/http.dart' as http;

import '../service/api/api_retry_manager.dart';
import '../transition/fade_transition.dart';
import '../utils/_constant.dart';
import '../utils/app_color.dart';
import '../utils/app_fonts.dart';

class ShoppingCartController extends GetxController {
  ApiClient apiClient;

  ShoppingCartController({required this.apiClient});

  var selectAll = false.obs;
  void toggleSelectAll() {
    selectAll.value = !selectAll.value;
  }


  var cartQuantities = <dynamic, int>{}.obs;



  var cartList = <CartProduct>[].obs;
  var cardCartList = <CartCardItem>[].obs;
  var isCartListLoading = true.obs;

  int get totalCartItems => cartList.length + cardCartList.length;

  void _updateCartCount() {
    try {
      final total = totalCartItems;
      Get.find<HomeController>().totalProduct.value = total;
    } catch (_) {}
  }

  /// Fetch all items
  Future<void> fetchCartItem({bool isReload = false}) async {
    if (isReload) {
      cartList.clear();
      cartQuantities.clear();
      cardCartList.clear();
    }
    try {
      http.Response? response = await apiClient.getData(Constant.cartItemsUrl);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded['data'];

        List<CartProduct> products = [];
        List<CartCardItem> cards = [];

        if (data is List) {
          products = data
              .map((item) {
                try {
                  return CartProduct.fromJson(item);
                } catch (_) {
                  return null;
                }
              })
              .whereType<CartProduct>()
              .toList();
        } else if (data is Map) {
          final productData = data['products'];
          if (productData is List) {
            products = productData
                .map((item) {
                  try {
                    return CartProduct.fromJson(item);
                  } catch (_) {
                    return null;
                  }
                })
                .whereType<CartProduct>()
                .toList();
          }

          final cardData = data['cards'];
          if (cardData is List) {
            cards = cardData
                .map((item) {
                  try {
                    return CartCardItem.fromJson(item);
                  } catch (_) {
                    return null;
                  }
                })
                .whereType<CartCardItem>()
                .toList();
          }

          final totalCount = data['total_count'];
          if (totalCount is int) {
            try {
              Get.find<HomeController>().totalProduct.value = totalCount;
            } catch (_) {}
          }
        }

        cartList.value = products;
        cardCartList.value = cards;

        cartQuantities.clear();
        for (var item in cartList) {
          if (item.id != null) {
          cartQuantities[item.id] = item.quantity ?? 0;
          }
        }

        _updateCartCount();
      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        fetchCartItem();
      });
    } finally {
      isCartListLoading.value = false;
    }
  }

  /// cart details
  var cartDtl = CartDtl().obs;
  Future<void> cartDetails() async {
    try {
      http.Response? response = await apiClient.getData(Constant.cartDetailsUrl);
      if (response.statusCode == 200) {
        CartDetailsModel cartDetailsModel = cartDetailsModelFromJson(response.body);
        cartDtl.value = cartDetailsModel.data ?? CartDtl();
      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        cartDetails();
      });
    }
  }

  /// Clear all cart items
  Future<void> clearAllCartItem() async {
    try {
      http.Response? response = await apiClient.getData(Constant.clearAllCartUrl);
      if (response.statusCode == 200) {
        cartList.clear();
        cardCartList.clear();
        selectAll.value = false;
        cartQuantities.clear();
        _updateCartCount();
        cartDetails(); // Refresh cart details after clearing
      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        clearAllCartItem();
      });
    }
  }

  /// Clear single cart items
  Future<void> removeSingleCartItem({dynamic productId, bool isCard = false}) async {
    var body = {
      "cart_item_id" : productId,
    };
    if (isCard) {
      body['item_type'] = 'card';
    }

    try {
      http.Response? response = await apiClient.postData(
          Constant.removeSingleCartItemUrl,body
      );
      if (response.statusCode == 200 ) {
        if (isCard) {
          cardCartList.removeWhere((r) => r.id == productId);
        } else {
        cartList.removeWhere((r) => r.id == productId);
          cartQuantities.remove(productId);
        }
        _updateCartCount();
        cartDetails(); // Refresh cart details after removing item
      }
    } catch (_) {
      apiRetryManager.addRequest(() {removeSingleCartItem(productId: productId, isCard: isCard);});
    }
  }

  /// increase product
  Future<void> increaseItem({dynamic productId}) async {
    var body = {
      "cart_item_id" : productId,
    };

    try {
      http.Response? response = await apiClient.postData(
          Constant.increaseCartCountUrl,body
      );
      if (response.statusCode == 200 ) {
        cartDetails();
        Map<String, dynamic> decodedResponse = json.decode(response.body);
        int itemCount = decodedResponse['data']['itemCount'];
        cartQuantities[productId] = itemCount;

      }
    } catch (_) {
      apiRetryManager.addRequest(() {increaseItem(productId: productId);});
    }
  }

  /// decrease product
  Future<void> decreaseItem({dynamic productId}) async {
    var body = {
      "cart_item_id" : productId,
    };

    try {
      http.Response? response = await apiClient.postData(
          Constant.decreaseCartCountUrl,body
      );
      if (response.statusCode == 200 ) {
        cartDetails();
        Map<String, dynamic> decodedResponse = json.decode(response.body);
        int itemCount = decodedResponse['data']['itemCount'];
        if (itemCount > 0) {
          cartQuantities[productId] = itemCount;
        } else {
          cartQuantities.remove(productId);
          cartList.removeWhere((element) => element.id == productId);
        }
        _updateCartCount();
      }
    } catch (_) {
      apiRetryManager.addRequest(() {increaseItem();});
    }
  }

  /// order from Cart
  var isOrder = false.obs;
  Future<void> orderFromCart({
    dynamic address,
    dynamic note,
    double? overrideTotalPrice,
  }) async {
    // Check wallet balance before placing order
    try {
      final userDataController = Get.find<UserDataController>();
      
      // Ensure we have the latest user data including wallet balance
      await userDataController.fetchUserData(isReload: true);
      
      final walletBalanceStr = userDataController.userData.value.wallet?.balance ?? '0';
      final walletBalance = double.tryParse(walletBalanceStr) ?? 0.0;
      final totalPrice = overrideTotalPrice ?? cartDtl.value.totalPrice ?? 0.0;
      
      if (walletBalance < totalPrice) {
        // Show alert dialog for insufficient balance
        Get.dialog(
          AlertDialog(
            title: Text(
              'Insufficient Balance',
              style: sansSemiBold.copyWith(
                fontSize: 18,
                color: AppColor.primaryColor,
              ),
            ),
            content: Text(
              'Your wallet balance (\$${walletBalance.toStringAsFixed(2)}) is not enough to pay for this order (\$${totalPrice.toStringAsFixed(2)}).\n\nPlease recharge your wallet to continue.',
              style: sansReg.copyWith(
                fontSize: 14,
                color: AppColor.primaryColor,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Cancel',
                  style: sansMedium.copyWith(
                    fontSize: 14,
                    color: AppColor.coolGray21,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.back(); // Close the alert
                  // Navigate to wallet screen for recharge
                  FadeScreenTransition(routeName: Routes.walletScreenRoute).navigate();
                },
                child: Text(
                  'Recharge Wallet',
                  style: sansSemiBold.copyWith(
                    fontSize: 14,
                    color: AppColor.buttonColor,
                  ),
                ),
              ),
            ],
          ),
        );
        return;
      }
    } catch (e) {
      // If we can't check balance, show error and return
      Get.snackbar(
        'Error',
        'Unable to verify wallet balance. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Proceed with order if balance is sufficient
    isOrder.value = true;
    var body = {
      "delivery_address" : address,
      "order_note" : note,
    };
    if (overrideTotalPrice != null && overrideTotalPrice > 0) {
      body['total_price'] = overrideTotalPrice;
      body['is_deal_offer'] = true;
    }

    try {
      http.Response response = await apiClient.postData(
        Constant.orderFromCartUrl,
        body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse created orders so we can pay for them immediately using wallet
        List<int> createdOrderIds = [];
        try {
          final decoded = jsonDecode(response.body);
          final data = decoded['data'];
          if (data is Map && data['orders'] is List) {
            for (final dynamic order in (data['orders'] as List)) {
              final dynamic id = (order as Map<String, dynamic>)['id'];
              if (id is int) {
                createdOrderIds.add(id);
              } else if (id != null) {
                final parsed = int.tryParse(id.toString());
                if (parsed != null) {
                  createdOrderIds.add(parsed);
                }
              }
            }
          }
        } catch (_) {
          // If parsing fails, we still proceed to clear cart and navigate
        }

        // Attempt to pay each created order with wallet
        for (final orderId in createdOrderIds) {
          await _payOrderWithWallet(orderId);
        }

        // Clear cart locally
        Get.back();
        cartList.clear();
        cardCartList.clear();
        cartQuantities.clear();
        _updateCartCount();

        // Refresh user data to update wallet balance after payment
        try {
          final userDataController = Get.find<UserDataController>();
          await userDataController.fetchUserData(isReload: true);
        } catch (_) {}

        // Navigate to my orders screen
        FadeScreenTransition(
          routeName: Routes.customerOrderRoute,
          arguments: {'order': 'myOrder'},
        ).navigate();
      } else {
        // Handle error response
        try {
          final responseBody = jsonDecode(response.body);
          final errorMessage =
              responseBody['message'] ?? 'Failed to place order';
          Get.snackbar(
            'Error',
            errorMessage.toString(),
            snackPosition: SnackPosition.BOTTOM,
          );
        } catch (_) {
          Get.snackbar(
            'Error',
            'Failed to place order. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to place order: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      apiRetryManager.addRequest(() {
        orderFromCart(
          address: address,
          note: note,
          overrideTotalPrice: overrideTotalPrice,
        );
      });
    } finally {
      isOrder.value = false;
    }
  }

  /// Pay a specific order using the user's wallet.
  /// This mirrors the existing frontend behaviour by calling:
  /// POST /user/order/{id}/pay-with-wallet
  Future<void> _payOrderWithWallet(int orderId) async {
    try {
      final url = "${Constant.payWithWalletBaseUrl}/$orderId/pay-with-wallet";
      http.Response response = await apiClient.postData(
        url,
        {}, // body not required
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Optional: we can inspect the response, but no UI needed on success
        return;
      } else {
        // Surface a lightweight error but do not block the flow
        try {
          final decoded = jsonDecode(response.body);
          final message =
              decoded['message']?.toString() ?? 'Failed to pay for order';
          Get.snackbar(
            'Payment warning',
            message,
            snackPosition: SnackPosition.BOTTOM,
          );
        } catch (_) {
          Get.snackbar(
            'Payment warning',
            'Failed to pay for order (Status: ${response.statusCode}).',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      // Network or other error – notify user but don't crash the flow
      Get.snackbar(
        'Payment warning',
        'Failed to confirm payment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }




  /// wishList
  var isWishListLoading = true.obs;
  var wishList = <WishlistData>[].obs;

  /// Card wishlist (stored locally)
  var cardWishList = <CardItem>[].obs;
  var isCardWishListLoading = false.obs;

  Future<void> fetchWishList({bool isReload = false}) async {
    if (isReload) {
      wishList.clear();
      isWishListLoading.value = true;
    }

    try {
      http.Response? response = await apiClient.getData(Constant.fetchWishListUrl);
      if (response.statusCode == 200) {
        WishListModel wishListModel = wishListModelFromJson(response.body);
        wishList.value = wishListModel.data ?? [];
      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        fetchWishList(isReload: true);
      });
    }finally{
      isWishListLoading.value = false;
    }

    // Also fetch card wishlist from local storage
    fetchCardWishList(isReload: isReload);
  }

  Future<void> fetchCardWishList({bool isReload = false}) async {
    if (isReload) {
      cardWishList.clear();
      isCardWishListLoading.value = true;
    }

    try {
      final storage = GetStorage();
      final cardWishlistIds = storage.read<List>('card_wishlist') ?? [];

      if (cardWishlistIds.isEmpty) {
        cardWishList.clear();
        isCardWishListLoading.value = false;
        return;
      }

      // Fetch all cards and filter by wishlist IDs
      try {
        http.Response? response = await apiClient.getData('${Constant.browseCardsUrl}?page=1&limit=1000');

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          if (json['data'] != null && json['data'] is List) {
            final allCards = (json['data'] as List)
                .map((item) {
                  try {
                    return CardItem.fromJson(item);
                  } catch (e) {
                    return null;
                  }
                })
                .whereType<CardItem>()
                .toList();

            // Filter cards that are in wishlist
            final cardIdSet = cardWishlistIds.map((id) => id.toString()).toSet();
            final wishlistCards = allCards
                .where((card) => card.id != null && cardIdSet.contains(card.id.toString()))
                .toList();

            cardWishList.value = wishlistCards;
          }
        }
      } catch (e) {
        // Silently fail
      }
    } catch (e) {
      // Silently fail
    } finally {
      isCardWishListLoading.value = false;
    }
  }

  void deleteToWishCard({dynamic productId}) {
    wishList.removeWhere((item) => item.productId == productId);
  }

  void deleteCardFromWishlist({dynamic cardId}) {
    cardWishList.removeWhere((item) => item.id?.toString() == cardId.toString());

    // Also remove from local storage
    try {
      final storage = GetStorage();
      List<dynamic> cardWishlist = storage.read<List>('card_wishlist') ?? [];
      cardWishlist.removeWhere((id) => id.toString() == cardId.toString());
      storage.write('card_wishlist', cardWishlist);
    } catch (e) {
      // Silently fail
    }
  }
}
