import 'package:classified/controller/customer_order_controller.dart';
import 'package:classified/model/customer_order_model.dart';
import 'package:classified/utils/app_text.dart';
import 'package:classified/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../utils/app_color.dart';
import '../../widget/no_data_widget.dart';
import '../../widget/order_items_widget.dart';

class CustomerOrderScreen extends StatefulWidget {
  const CustomerOrderScreen({super.key});

  @override
  State<CustomerOrderScreen> createState() => _CustomerOrderScreenState();
}

class _CustomerOrderScreenState extends State<CustomerOrderScreen> {
  late CustomerOrderController customerOrderController;
  late dynamic orderRoute;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    orderRoute =  Get.arguments['order'];
    customerOrderController = Get.find<CustomerOrderController>();
    customerOrderController.fetchCustomerOrder(orderRoute: orderRoute, isReload: true);
    _scrollController.addListener(() {
      controllerScrollListener();
    });
  }
  void controllerScrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (customerOrderController.currentPage.value <= (customerOrderController.pagination.value.lastPage ?? 0) ) {
        customerOrderController.fetchCustomerOrder(orderRoute: orderRoute);
      }}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppText.orderHistory,),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        displacement: 80,
        color: Colors.white,
        backgroundColor: AppColor.buttonColor,
        onRefresh: () async {
          customerOrderController.fetchCustomerOrder(orderRoute: orderRoute,);
        },

        child: Obx(() {
          final isLoading = customerOrderController.isOrderLoading.value;
          final orderList = customerOrderController.customerOrderList;

          if (!isLoading && orderList.isEmpty) {
            return Center(
              child: NoDataWidget(text: 'No Order History'),
            );
          }

          return Skeletonizer(
            enabled: isLoading,
            child: ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: isLoading ? 5 : orderList.length + (customerOrderController.isPaginating.value ? 1 : 0),
              itemBuilder: (context, index) {

                if (!isLoading && index == orderList.length && customerOrderController.isPaginating.value) {
                  return Padding(
                    padding:  EdgeInsets.only(bottom: 20.h),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2,color: AppColor.buttonColor,)),
                  );
                }

                final item = isLoading
                    ? CustomerOrder()
                    : orderList[index];

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: isLoading
                        ? (index == 4 ? 40 : 0)
                        : ((orderList.length - 1) == index ?customerOrderController.isPaginating.value ? 0 : 40 : 0),
                  ),
                  child: OrderItemsWidget(item: item),
                );
              },
            ),
          );
        }),

      )
    );
  }
}
