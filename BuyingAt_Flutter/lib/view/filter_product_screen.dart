import 'package:classified/view/sort_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/instance_manager.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../controller/filter_search_controller.dart';
import '../../utils/app_color.dart';
import '../model/product_model.dart';
import '../utils/app_text.dart';
import '../widget/custom_app_bar.dart';
import '../widget/home_widgets/products_card.dart';
import '../widget/no_data_widget.dart';
import 'drawer/filter_drawer.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {


  late FilterController filterController;

  late dynamic type;
  late int? categoryId;
  late dynamic categoryName;
  late dynamic copyCName;
  late dynamic searchText;

  @override
  void initState() {
    super.initState();
    filterController = Get.find<FilterController>();
    type = Get.arguments['type'];
    categoryId = Get.arguments?['categoryId'] ?? 0;
    categoryName = Get.arguments?['categoryName'] ?? '';
    copyCName = Get.arguments?['categoryName'] ?? 'filter';
    searchText = Get.arguments?['searchText'] ?? '';


    WidgetsBinding.instance.addPostFrameCallback((_) {
      filterController.applyFilterLogic(type: type, cId: categoryId,cName: categoryName,searchTxt: searchText);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backGround,
      appBar: CustomAppBar(
        title: copyCName,
      ),
      key: filterController.scaffoldKey,
      drawer: const FilterDrawer(),
      body: PopScope(
        canPop: true,
        child: RefreshIndicator(
          onRefresh: () async {
            filterController.reset();
            return await filterController.filter(isReload: true);
          },
          backgroundColor: AppColor.white,
          color: AppColor.buttonColor,
          child: SingleChildScrollView(
            controller: filterController.scrollController.value,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    border: Border(
                      top: BorderSide(
                        color: AppColor.primaryColor.withValues(alpha: 0.10),
                        width: 1,
                      ),
                      bottom: BorderSide(
                          color: AppColor.primaryColor.withValues(alpha: 0.10),
                          width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() {
                        return Expanded(
                          flex: 12,
                          child: sortWidget(
                            context,
                            onTap: () {
                              filterController.scaffoldKey.currentState
                                  ?.openDrawer();
                            },
                            index: 0,
                            isSelect: filterController.isFilter.value,
                          ),
                        );
                      }),
                      SizedBox(
                        height: 24,
                        child: VerticalDivider(
                          width: 1,
                          color: AppColor.primaryColor.withValues(alpha: 0.4),
                        ),
                      ),
                      Obx(() {
                        return Expanded(
                          flex: 10,
                          child: sortWidget(
                            context,
                            onTap: () {
                              final RenderBox button = context
                                  .findRenderObject() as RenderBox;
                              final offset = button.localToGlobal(Offset.zero);
                              showMenu(
                                color: Colors.white,
                                context: context,
                                position: RelativeRect.fromLTRB(
                                  offset.dx + button.size.width,
                                  offset.dy + 150.h,
                                  0,
                                  0,
                                ),
                                items: [
                                  PopupMenuItem<String>(
                                    value: 'recent',
                                    child: Text('Most Recent'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'low',
                                    child: Text('Lowest Price'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'high',
                                    child: Text('Highest Price'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'rating',
                                    child: Text('Highest Rating'),
                                  ),
                                ],
                                elevation: 8.0,
                              ).then((value) {
                                if (value != null) {
                                  filterController.isSort.value = true;
                                  switch (value) {
                                    case "low":
                                      filterController.sortBy.value = "price";
                                      filterController.sortDirection.value =
                                      "asc";
                                      break;

                                    case "high":
                                      filterController.sortBy.value = '';
                                      filterController.sortDirection.value =
                                      "desc";
                                      break;

                                    case "recent":
                                      filterController.sortBy.value = '';
                                      filterController.sortDirection.value =
                                      'desc';
                                      break;

                                    case "rating":
                                      filterController.sortBy.value = 'rating';
                                      break;
                                  }

                                  filterController.filter(isReload: true);
                                }
                              });
                            },
                            index: 2,
                            isSelect: filterController.isSort.value,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                SizedBox(
                  height: 18.h,
                ),
                Obx(() {
                  final isLoading = filterController.isFilterProLoading.value;
                  if (!isLoading &&
                      filterController.filteredProductList.isEmpty) {
                    return Center(child: NoDataWidget(text: AppText.dataNotFound));
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Skeletonizer(
                      enabled: isLoading,
                      enableSwitchAnimation: true,
                      effect: PulseEffect(
                        from: Colors.grey[500]!,
                        to: Colors.grey[300]!,
                        duration: const Duration(seconds: 1),
                      ),
                      child: AlignedGridView.count(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.w,
                          mainAxisSpacing: 10.h,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: isLoading ? 6 : filterController
                              .filteredProductList.length,
                          itemBuilder: (context, index) {
                            final item = isLoading
                                ? ProductsItem()
                                : filterController.filteredProductList[index];
                            return ProductsCard(
                              item: item,
                              isRating: true,
                              isFilter: true,
                              isLoading: isLoading,
                            );
                          }

                      ),
                    ),
                  );
                }),

                  Obx(() {
                    return (filterController.isPaginating.value) ?Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 10.h, top: 5.h),
                        child: SizedBox(
                          width: 20.h,
                          height: 20.h,
                          child: CircularProgressIndicator(
                            color: AppColor.buttonColor,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ) : SizedBox.shrink();
                  }),
                SizedBox(
                  height: 30.h,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
