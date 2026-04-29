import 'dart:convert';
import 'dart:io';
import '../model/product_model.dart';
import '../service/api/api_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../service/api/api_retry_manager.dart';
import '../utils/_constant.dart';
import '../view/dialog/post_added_dialog.dart';
import '../widget/custom_snackbar_widget.dart';

class AddProductsController extends GetxController {
  ApiClient apiClient;
  AddProductsController({required this.apiClient});
  var carId = 0.obs;
  late dynamic routeType;
  late dynamic pId;


  @override
  void onInit() async {
    super.onInit();
    routeType = Get.arguments?['routeType'] ?? '';
    pId = Get.arguments?['pId'] ?? 0;
    if (routeType == 'editRoute')   {
      await getSingleProduct(productId: pId);

      if (product.value != null) {
        title.text = product.value.productTitle ?? '';
        description.text = product.value.productDescription ?? '';
        categoryName.value = product.value.getCategory?.categoryName ?? '';
        categoryId.value = product.value.categoryId ?? 0;
        subCategoryName.value = product.value.getSubCategory?.subCategoryName ?? '';
        subCategoryId.value = product.value.subCategoryId ?? 0;
        brandName.value = product.value.getBrand?.brandName ?? '';
        brandId.value = product.value.brandId ?? 0;
        carId.value = product.value.id ?? 0;
        originalPrice.text = product.value.price ?? '';
        discountPrice.text = product.value.discountedPrice ?? '';
        pickedProductImages.addAll(product.value.getGalleryImages?.map((img) => File('${Constant.imageBaseUrl}${img.img}')).toList() ?? []);
        isFormValidPageOne.value = true;


        colorItems.clear();
        for (final c in (product.value.colors ?? [])) {
          Color parsed = const Color(0xFF000000);
          final rawHex = (c.color ?? '').replaceAll('#', '').trim();
          if (rawHex.length == 6 || rawHex.length == 8) {
            final withAlpha = rawHex.length == 8 ? rawHex : 'FF$rawHex';
            try { parsed = Color(int.parse('0x$withAlpha')); } catch (_) {}
          }
          final List<File> images = [];
          for (final img in (c.images ?? [])) {
            if (img is String) {
              images.add(File('${Constant.imageBaseUrl}$img'));
            } else if (img is Map && img['color_image'] != null) {
              images.add(File('${Constant.imageBaseUrl}${img['color_image']}'));
            }
          }
          colorItems.add(ColorItemModel(
            colorName: c.colorName ?? '',
            selectedColor: parsed,
            pickedImages: images,
          ));
        }

        // Sizes -> sizeItems
        sizeItems.clear();
        for (final s in (product.value.sizes ?? [])) {
          final name = (s.size ?? '').toUpperCase();
          if (name.isNotEmpty) {
            sizeItems.add(SizeModel(sizeName: name));
          }
        }

        // Specification -> specificationItems (key/value list from JSON string)
        specificationItems.clear();
        try {
          final specRaw = product.value.additionalInfo?.specification;
          if (specRaw != null && specRaw.toString().trim().isNotEmpty) {
            dynamic parsed = specRaw;
            if (parsed is String) {
              parsed = jsonDecode(parsed);
            }
            if (parsed is String) {
              parsed = jsonDecode(parsed);
            }
            if (parsed is List) {
              for (final entry in parsed) {
                if (entry is Map && entry.isNotEmpty) {
                  final key = entry.keys.first.toString();
                  final value = entry[key]?.toString() ?? '';
                  specificationItems.add(SizeModel(specificationKey: key, specificationValue: value));
                }
              }
            }
          }
        } catch (_) {}

        // Additional Info -> additionalInfoItems
        additionalInfoItems.clear();
        try {
          final addRaw = product.value.additionalInfo?.additionalInfo;
          if (addRaw != null && addRaw.toString().trim().isNotEmpty) {
            dynamic parsed = addRaw;
            if (parsed is String) {
              parsed = jsonDecode(parsed);
            }
            if (parsed is String) {
              parsed = jsonDecode(parsed);
            }
            if (parsed is List) {
              for (final entry in parsed) {
                if (entry is Map && entry.isNotEmpty) {
                  final key = entry.keys.first.toString();
                  final value = entry[key]?.toString() ?? '';
                  additionalInfoItems.add(SizeModel(specificationKey: key, specificationValue: value));
                }
              }
            }
          }
        } catch (_) {}

        // Variants -> variantItems
        variantItems.clear();
        for (final v in (product.value.variants ?? [])) {
          variantItems.add(VariantModel(
            variantInfo: v.variantName ?? '',
            originalPrice: v.price ?? '',
            discountedPrice: v.discountedPrice ?? '',
          ));
        }
      }
    }
    checkBtnOne();
  }

  /// screen one

  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();

  var categoryName = ''.obs;
  var subCategoryName = ''.obs;
  var subCategoryId = 0.obs;
  var brandName = ''.obs;
  var brandId = 0.obs;
  var categoryId = 0.obs;
  final FocusNode fTitleNode = FocusNode();
  final FocusNode fPriceNode = FocusNode();
  final FocusNode fDescriptionNode = FocusNode();
  RxBool isFormValidPageOne = false.obs;

  void checkBtnOne() {
    title.addListener(_validateInputsOne);
    description.addListener(_validateInputsOne);
    everAll([
      categoryName,
      subCategoryName,
      brandName,
    ], (_) => _validateInputsOne());
  }

  void _validateInputsOne() {
    final textInputs = [title.text.trim(), description.text.trim()];
    final areTextFieldsValid = textInputs.every((input) => input.isNotEmpty);
    final isCategoryValid = categoryName.value != '';
    final isSubCategoryValid = subCategoryName.value != '';


    isFormValidPageOne.value = areTextFieldsValid && isCategoryValid && isSubCategoryValid;
  }

  /// screen two

  final List<String> texts = [
    'Colours',
    'Size',
    'Specification',
    'Additional Info',
    'product Variant',
  ];
  var selectedIndex = (-1).obs;

  /// --  if not selected

  TextEditingController mainStock = TextEditingController();
  TextEditingController originalPrice = TextEditingController();
  TextEditingController discountPrice = TextEditingController();

  final FocusNode fMainStock = FocusNode();
  final FocusNode fOriginalPrice = FocusNode();
  final FocusNode fDiscountPrice = FocusNode();

  ///--------  Color ---------

  TextEditingController colorName = TextEditingController();

  final FocusNode fColorName = FocusNode();
  var selectedColor = Color(0xFF000000).obs;
  final RxList<File> pickedImages = <File>[].obs;
  final ImagePicker _picker = ImagePicker();
  var colorItems = <ColorItemModel>[].obs;

  Future<void> pickImage() async {
    final List<XFile> images = await _picker.pickMultiImage(limit: 10);

    if (images.isNotEmpty) {
      final remaining = 4 - pickedImages.length;
      final toAdd = images.take(remaining).map((x) => File(x.path)).toList();
      pickedImages.addAll(toAdd);
    }
  }

  void removeImage(int index) {
    pickedImages.removeAt(index);
  }

  void addColorItem() {
    if (colorName.text.trim().isEmpty) {
      return;
    }

    colorItems.add(
      ColorItemModel(
        colorName: colorName.text.trim(),
        selectedColor: selectedColor.value,
        pickedImages: List<File>.from(pickedImages),
      ),
    );

    // reset
    colorName.clear();
    pickedImages.clear();
    selectedColor.value = Color(0xFF000000);
  }

  ///--------  Size ---------
  TextEditingController size = TextEditingController();
  final FocusNode fSize = FocusNode();
  var sizeItems = <SizeModel>[].obs;

  void addSizeItem() {
    final input = size.text.trim().toUpperCase();

    if (input.isEmpty) return;

    final alreadyExists = sizeItems.any((item) => item.sizeName == input);

    if (!alreadyExists) {
      sizeItems.add(SizeModel(sizeName: input));
      // reset
      size.clear();
    } else {
      showCustomSnackBar("$input Already exists");
    }
  }

  ///-------- Specification ---------
  TextEditingController specificationOne = TextEditingController();
  TextEditingController specificationTwo = TextEditingController();
  final FocusNode fSpecificationOne = FocusNode();
  final FocusNode fSpecificationTwo = FocusNode();
  var specificationItems = <SizeModel>[].obs;

  void addSpecificationItem() {
    final inputOne = specificationOne.text.trim();
    final inputTwo = specificationTwo.text.trim();

    if (inputOne.isEmpty || inputTwo.isEmpty) {
      showCustomSnackBar("Please fill all fields");
    } else {
      specificationItems.add(
        SizeModel(specificationKey: inputOne, specificationValue: inputTwo),
      );
      // reset
      specificationOne.clear();
      specificationTwo.clear();
    }
  }

  ///-------- Additional Info ---------
  TextEditingController additionalInfoOne = TextEditingController();
  TextEditingController additionalInfoTwo = TextEditingController();
  final FocusNode fAdditionalInfoOne = FocusNode();
  final FocusNode fAdditionalInfoTwo = FocusNode();
  var additionalInfoItems = <SizeModel>[].obs;

  void addAdditionalInfoItem() {
    final inputOne = additionalInfoOne.text.trim();
    final inputTwo = additionalInfoTwo.text.trim();

    if (inputOne.isEmpty || inputTwo.isEmpty) {
      showCustomSnackBar("Please fill all fields");
    } else {
      additionalInfoItems.add(
        SizeModel(specificationKey: inputOne, specificationValue: inputTwo),
      );
      // reset
      additionalInfoOne.clear();
      additionalInfoTwo.clear();
    }
  }

  ///-------- Variant  ---------
  TextEditingController variantOriginalPrice = TextEditingController();
  TextEditingController variantDiscountPrice = TextEditingController();
  TextEditingController variantInfo = TextEditingController();
  final FocusNode fVariantOriginalPrice = FocusNode();
  final FocusNode fVariantDiscountPrice = FocusNode();
  final FocusNode fVariantInfo = FocusNode();

  var variantItems = <VariantModel>[].obs;
  void addVariantItem() {
    final inputOne = variantInfo.text.trim();
    final inputTwo = variantOriginalPrice.text.trim();
    final inputThree = variantDiscountPrice.text.trim();

    if (inputOne.isEmpty || inputTwo.isEmpty || inputThree.isEmpty) {
      showCustomSnackBar("Please fill all fields");
    } else {
      variantItems.add(
        VariantModel(
          variantInfo: inputOne,
          originalPrice: inputTwo,
          discountedPrice: inputThree,
        ),
      );
      // reset
      variantOriginalPrice.clear();
      variantDiscountPrice.clear();
      variantInfo.clear();
    }
  }

  ///   Screen Three
  // image picker
  RxList<File> pickedProductImages = <File>[].obs;

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> pickProductImage() async {
    final List<XFile> images = await _imagePicker.pickMultiImage(limit: 6);

    if (images.isNotEmpty) {
      final remaining = 6 - pickedProductImages.length;
      final toAdd = images.take(remaining).map((x) => File(x.path)).toList();
      pickedProductImages.addAll(toAdd);
    }
  }

  void removeProductImage(int index) {
    pickedProductImages.removeAt(index);
  }

  /// Store Products

  var isStoreProductLoading = false.obs;
  var isCreateLoading = false.obs;
  Future<void> storeProduct() async {
    isCreateLoading.value = true;
    List<MultipartBody> multipartFiles = [];
    multipartFiles.addAll(
      pickedProductImages.map((file) => MultipartBody('img[]', file)),
    );

    var body = {
      'product_title': title.text.trim(),
      'category_id': categoryId.value,
      'sub_category_id': subCategoryId.value,
      if(brandId.value !=0)'brand_id': brandId.value,
      'product_description': description.text.trim(),
      'price': originalPrice.text.trim(),
      'discounted_price': discountPrice.text.trim(),
    };
    if (colorItems.isEmpty && sizeItems.isEmpty && variantItems.isEmpty) {
      if (mainStock.text.trim().isEmpty) {
        showCustomSnackBar('Main stock cannot be empty!');
        return ;
      }else{
        body.addAll({'stock': mainStock.text.trim().toString()});
      }
    
    }

    isStoreProductLoading.value = true;
    body['colors'] = [];
    body['sizes'] = [];
    body['variations'] = [];

    /// color with image
    List<Map<String, dynamic>> colorsJson = colorItems.map((item) {
      String hexColor =
          '#${item.selectedColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

      return {'color_name': item.colorName, 'color': hexColor};
    }).toList();

    body['colors'] = jsonEncode(colorsJson);

    colorItems.asMap().forEach((i, item) {
      item.pickedImages.asMap().forEach((j, file) {
        multipartFiles.add(MultipartBody('colors$i[$j]', file));
      });
    });



    /// Sizes JSON
    List<Map<String, dynamic>> sizesJson = sizeItems
        .where((item) => item.sizeName != null && item.sizeName!.isNotEmpty)
        .map((item) => {"size": item.sizeName!})
        .toList();

    body['sizes'] = jsonEncode(sizesJson);

    /// Variant string
    List<Map<String, dynamic>> variantJson = variantItems
        .where(
          (item) =>
              item.variantInfo != null &&
              item.variantInfo!.isNotEmpty &&
              item.originalPrice != null &&
              item.discountedPrice != null,
        )
        .map((item) {
          return {
            'variant_name': item.variantInfo,
            'price': item.originalPrice,
            'discounted_price': item.discountedPrice,
          };
        })
        .toList();

    body['variations'] = jsonEncode(variantJson);

    /// additional info
    List<Map<String, dynamic>> additionalInfoJson = additionalInfoItems
        .where(
          (item) =>
              item.specificationKey != null &&
              item.specificationKey!.isNotEmpty &&
              item.specificationValue != null &&
              item.specificationValue!.isNotEmpty,
        )
        .map((item) => {item.specificationKey!: item.specificationValue!})
        .toList();

    body['additional_info_json'] = jsonEncode(additionalInfoJson);

    /// specification info
    List<Map<String, dynamic>> specificationJson = specificationItems
        .where(
          (item) =>
              item.specificationKey != null &&
              item.specificationKey!.isNotEmpty &&
              item.specificationValue != null &&
              item.specificationValue!.isNotEmpty,
        )
        .map((item) => {item.specificationKey!: item.specificationValue!})
        .toList();

    body['specification'] = jsonEncode(specificationJson);

    try {
      http.Response? response = await apiClient.postMultipartData(routeType == 'editRoute'? '${Constant.storeProductUrl}/$pId' :Constant.storeProductUrl, body, multipartFiles,
      );
      if (response.statusCode == 201) {
        Get.dialog(barrierDismissible: false, PostAddedDialog());
      } else if (response.statusCode == 200 || response.statusCode == 422) {
        showCustomSnackBar("Please fill in all fields.",duration: 3);
      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        storeProduct();
      });
    } finally {
      isStoreProductLoading.value = false;
      isCreateLoading.value = false;
    }
  }


  /// fetch single product when Edit
  var isProductLoading = true.obs;
  var product = ProductsItem().obs;
  Future<void> getSingleProduct({bool isReload = false, required productId}) async {
    if (isReload) {}
    isProductLoading.value = true;
    try {
      http.Response? response = await apiClient.getData("${Constant.singleProductUrl}/$productId");
      if (response.statusCode == 200) {
        ProductModel productModel = productModelFromJson(response.body);
        product.value = productModel.data ?? ProductsItem();

      }
    } catch (_) {
      apiRetryManager.addRequest(() {getSingleProduct(productId: productId);});
    } finally {
      isProductLoading.value = false;
    }
  }

  ///  add car Nav Controller

  var activeIndex = 0.obs;

  PageController pageController = PageController(initialPage: 0);

  void setActiveIndex(int index) {
    if ((index - activeIndex.value).abs() == 0) {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      pageController.jumpToPage(index);
      pageController.dispose();
    }

    // Update the active index after the jump/animation
    activeIndex.value = index;
  }

  var clickStartTrack = 0.obs;
  // var clickPlus = false.obs;

  /// ----- ------ ---- ///

  final RxInt characterCount = 0.obs;
  var selectedCategory = 'Select category'.obs;

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class ColorItemModel {
  final String colorName;
  final Color selectedColor;
  final List<File> pickedImages;

  ColorItemModel({
    required this.colorName,
    required this.selectedColor,
    required this.pickedImages,
  });

  Map<String, dynamic> toJson() {
    return {
      'color_name': colorName,
      'color_value': selectedColor.toARGB32(),
      'images': pickedImages.map((f) => f.path).toList(),
    };
  }
}

class SizeModel {
  final String? sizeName;
  final String? specificationKey;
  final String? specificationValue;

  SizeModel({this.sizeName, this.specificationKey, this.specificationValue});
}

class VariantModel {
  final String? variantInfo;
  final String? originalPrice;
  final String? discountedPrice;

  VariantModel({this.variantInfo, this.originalPrice, this.discountedPrice});
}
