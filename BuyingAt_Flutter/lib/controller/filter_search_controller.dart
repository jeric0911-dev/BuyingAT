import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import '../model/customer_order_model.dart';
import '../model/product_model.dart';
import '../model/products_model.dart';
import '../service/api/api_client.dart';
import '../service/api/api_retry_manager.dart';
import '../utils/_constant.dart';
import '../utils/app_text.dart';
import '../widget/custom_dropdown_widget.dart';
import 'package:http/http.dart' as http;

class FilterController extends GetxController {
  late final ApiClient apiClient;
  FilterController({required this.apiClient});

  @override
  void onInit() {
    super.onInit();
    scrollController.value.addListener(() {
      _onScroll();
    });

    addSortByList();
  }
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  var isFilter = false.obs;
  var isSort = false.obs;
  var selectedIndex = 0.obs;
  var categoryId = 0.obs;
  var categoryName = ''.obs;
  var subCategoryId = 0.obs;
  var subCategoryName = ''.obs;
  var sortBy = ''.obs;
  var sortDirection = ''.obs;
  var isFeatured = 0.obs;

  List<String> sortOptions = [
    AppText.mostRecent,
    AppText.highestPrice,
    AppText.lowestPrice,
    AppText.highestRatting,
  ];

  List<String> get sortByList => sortOptions;
  List<DropdownItem<int>> selectedSortByList = [];
  final minPrice = TextEditingController();
  final maxPrice = TextEditingController();


  final FocusNode fMinPrice = FocusNode();
  final FocusNode fMaxPrice = FocusNode();
  final FocusNode fSearch = FocusNode();

  var scrollController = ScrollController().obs;
  void _onScroll() {
    if (scrollController.value.position.pixels ==
        scrollController.value.position.maxScrollExtent) {
      if (currentPage.value <= (pagination.value.lastPage ?? 0) ) {
        filter();
      }

    }
  }

  /// Route logic
  void applyFilterLogic({dynamic type, dynamic cId, dynamic cName, dynamic searchTxt} ) {

    switch (type) {
      case 'bestDeal':
        sortBy.value = 'discount';
        filter(isReload: true);
        break;

      case 'Featured':
        isFeatured.value = 1;
        filter(isReload: true);
        break;

      case 'Computer':
        if (cId! > 0) {
          categoryId.value = cId!;
          filter(isReload: true);
        }
        break;

      case 'TopRated':
        sortBy.value = "rating";
        sortDirection.value = "desc";
        filter(isReload: true);
        break;

      case 'New':
        filter(isReload: true);
        break;

      case 'search':

        filter(isReload: true, search: searchTxt);
        break;

      default:
        categoryName.value = cName;
        categoryId.value = cId;
        filter(isReload: true);
        break;
    }
  }


  /// filter products
  var  pagination = Pagination().obs;
  var isFilterProLoading = true.obs;
  var currentPage = 1.obs;
  var filteredProductList = <ProductsItem>[].obs;
  var isPaginating= false.obs;


  Future<void> filter({bool isReload = false, dynamic search}) async {
    if (isReload) {
      isFilterProLoading.value = true;
      filteredProductList.clear();
      currentPage.value = 1;
      isPaginating.value = true;
      pagination.value = Pagination();
    }else{
      isPaginating.value = true;
    }


    try {
      http.Response? response = await apiClient.getData(
        Constant.filterUrl,
        query: {

          "limit": "16",
          "page": currentPage.value.toString(),
          "min_price": minPrice.text.trim(),
          "max_price": maxPrice.text.trim(),
          "category_id": categoryId.value.toString(),
          "sub_category_id": subCategoryId.value.toString(),
          "sort_by": sortBy.toString(),
          "sort_direction": sortDirection.toString(),
          "is_featured": isFeatured.value.toString(),
          if (search != null && search.isNotEmpty) "search": search.toString(),
        }
      );

      if (response.statusCode == 200) {
        ProductsModel productsModel = productsModelFromJson(response.body);
        final newProducts = productsModel.data ?? [];

          filteredProductList.addAll(newProducts);

        pagination.value = productsModel.pagination ?? Pagination();
        currentPage.value = (pagination.value.currentPage ?? 0) + 1;

      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        filter(isReload: true);
      });
    } finally {
      isFilterProLoading.value = false;
      isPaginating.value = false;
    }
  }



  addSortByList() {
    if (selectedSortByList.isEmpty) {
      for (int index = 0; index < sortByList.length; index++) {
        selectedSortByList.add(
          DropdownItem<int>(
            value: index,
            child: SizedBox(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(sortByList[index]),
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  void onClose() {
    super.onClose();
    minPrice.clear();
    maxPrice.clear();
    fMinPrice.dispose();
    fMaxPrice.dispose();
    selectedSortByList.clear();
    categoryId.value = 0;
    categoryName.value = '';
    subCategoryId.value = 0;
    subCategoryName.value = '';
    isFilter.value = false;
    isSort.value = false;
    selectedIndex.value = 0;
    sortBy.value = '';
  }

  // List<DropdownItem<int>> generateDropdownItems<T>(
  //   List<T> list,
  //   String? Function(T) getName,
  //   int? Function(T) getId,
  // ) {
  //   return list.map((item) {
  //     return DropdownItem<int>(
  //       value: getId(item),
  //       child: Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: Text(getName(item) ?? ''),
  //       ),
  //     );
  //   }).toList();
  // }

  void reset(){
    minPrice.clear();
    maxPrice.clear();
    selectedSortByList.clear();
    categoryId.value = 0;
    categoryName.value = '';
    subCategoryId.value = 0;
    subCategoryName.value = '';
    sortBy.value = '';
    isFilter.value = false;
    isSort.value = false;
    selectedIndex.value = 0;
    fMinPrice.unfocus();
    fMaxPrice.unfocus();
  }
}
