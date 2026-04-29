import 'package:classified/controller/dashboard_controller.dart';
import 'package:classified/model/product_model.dart';
import 'package:classified/utils/app_fonts.dart';
import 'package:classified/utils/app_image.dart';
import 'package:classified/utils/app_text.dart';
import 'package:classified/widget/custom_button.dart';
import 'package:classified/widget/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../utils/app_color.dart';
import '../../widget/custom_drop_dawn_btn.dart';

class StockManageBottomSheet extends StatefulWidget {
  final dynamic productId;
  final ProductsItem productsItem;
  final DashboardController dashboardController;

  const StockManageBottomSheet({
    super.key,
    this.productId,
    required this.dashboardController,
    required this.productsItem,
  });

  @override
  State<StockManageBottomSheet> createState() => _StockManageBottomSheetState();
}

class _StockManageBottomSheetState extends State<StockManageBottomSheet> {
  @override
  void initState() {
    super.initState();
    widget.dashboardController.stockManagement(productId: widget.productId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.dashboardController.stockControllers = [];
      for (var i = 0; i <
          widget.dashboardController.productStockList.length; i++) {
        widget.dashboardController.stockControllers.add(
          TextEditingController(
            text: widget.dashboardController.productStockList[i].stock
                .toString(),
          ),
        );
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 16.h),
            child: Column(
              children: [
                Container(
                  height: 3.h,
                  width: 35.w,
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withValues(alpha: .20),
                    borderRadius: BorderRadius.circular(.3),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  widget.productsItem.productTitle.toString(),
                  style: sansBold.copyWith(
                    fontSize: 20.sp,
                    height: 1.25.h,
                    color: AppColor.primaryColor,
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),


           Expanded(
             child: Column(
               children: [
                 // Scrollable items area
                 Flexible(
                   child: Scrollbar(
                     thumbVisibility: true,
                     trackVisibility: true,
                     thickness: 5.w,
                     radius: Radius.circular(15.r),
                     child: SingleChildScrollView(
                       padding: EdgeInsets.only(left: 16.w),
                       child: Obx(() {
                       if(widget.dashboardController.isProductStockLoading.value == false){
                         return Center(child: CircularProgressIndicator());
                       }
                       Future.delayed(Duration(microseconds: 100));
                       return ListView.builder(
                         itemCount: widget.dashboardController.stockRows.length ?? 0,
                         shrinkWrap: true,
                         physics: NeverScrollableScrollPhysics(),
                         itemBuilder: (context, index) {
                           final stock = widget.dashboardController.stockRows[index];
                           final product = widget.dashboardController.myProductsList
                               .firstWhereOrNull((p) => p.id == stock.productId);

                           final colorList = product?.colors ?? [];
                           final variantList = product?.variants ?? [];
                           final sizeList = product?.sizes ?? [];

                           final colorName = colorList.firstWhereOrNull((c) => c.id == stock.colorId)?.colorName ?? "Color";
                           final variantName = variantList.firstWhereOrNull((v) => v.id == stock.variantId)?.variantName ?? "Variant";
                           final sizeName = sizeList.firstWhereOrNull((s) => s.id == stock.sizeId)?.size ?? "Size";

                           return Padding(
                             padding: EdgeInsets.only(bottom: 10),
                             child: Row(
                               children: [
                                 if( widget.dashboardController.colorSelectedList.isNotEmpty && colorName != 'null')SizedBox(
                                   width: 76.w,
                                   child: CustomDropDawnBtn(
                                     items: widget.dashboardController.colorSelectedList,
                                     onChange: (int? value, int index) {
                                       setState(() {
                                         widget.dashboardController.stockRows[index].colorId = value;
                                       });
                                     },
                                     title: colorName.toString(),
                                     btnHeight: 48.h,
                                     isIndexValue: true,
                                     textPadding: EdgeInsets.only(left: 10.w),
                                     iconPadding: EdgeInsets.symmetric(
                                         horizontal: 5.w),
                                     textStyle: sansMedium.copyWith(
                                       fontSize: 14.sp,
                                       height: 1.4.h,
                                       color:colorName == 'Color'? AppColor.coolGray4 : AppColor.textColor,
                                     ),
                                     iconSize: 11.w,
                                     dropdownStyleWidth: true,
                                     isSelected: true,
                                   ),
                                 ),
                                 if( widget.dashboardController.colorSelectedList
                                     .isNotEmpty )SizedBox(
                                     width: 12.w),

                                 if( widget.dashboardController.variantSelectedList
                                     .isNotEmpty )SizedBox(
                                   width: 112.w,
                                   child: CustomDropDawnBtn(
                                     items: widget.dashboardController
                                         .variantSelectedList,
                                     onChange: (int? value, int index) {
                                       setState(() {
                                         widget.dashboardController.stockRows[index].variantId = value;
                                       });
                                     },
                                     title: variantName,
                                     btnHeight: 48.h,
                                     isIndexValue: true,
                                     textPadding: EdgeInsets.only(left: 10.w),
                                     iconPadding: EdgeInsets.symmetric(
                                         horizontal: 5.w),
                                     textStyle: sansMedium.copyWith(
                                       fontSize: 14.sp,
                                       height: 1.4.h,
                                       color:variantName == 'Variant'? AppColor.coolGray4 : AppColor.textColor,
                                     ),
                                     iconSize: 11.w,
                                     dropdownStyleWidth: true,
                                   ),
                                 ),

                                 SizedBox(width: 12.w),
                                 if( widget.dashboardController.sizeSelectedList
                                     .isNotEmpty ) SizedBox(
                                   width: 73.w,
                                   child: CustomDropDawnBtn(
                                     items: widget.dashboardController
                                         .sizeSelectedList,
                                     onChange: (int? value, int index) {
                                       setState(() {
                                         widget.dashboardController.stockRows[index].sizeId = value;
                                       });
                                     },
                                     title: sizeName,
                                     btnHeight: 48.h,
                                     isIndexValue: true,
                                     textPadding: EdgeInsets.only(left: 10.w),
                                     iconPadding: EdgeInsets.symmetric(
                                         horizontal: 5.w),
                                     textStyle: sansMedium.copyWith(
                                       fontSize: 14.sp,
                                       height: 1.4.h,
                                       color: sizeName == 'Size'? AppColor.coolGray4 : AppColor.textColor,
                                     ),
                                     iconSize: 11.w,
                                     dropdownStyleWidth: true,
                                   ),
                                 ),

                                 SizedBox(width: 12.w),
                                 (widget.dashboardController.colorSelectedList
                                     .isEmpty &&
                                     widget.dashboardController.variantSelectedList
                                         .isEmpty &&
                                     widget.dashboardController.sizeSelectedList
                                         .isEmpty)
                                     ?

                                 Expanded(
                                   child: CustomTextFieldWidget(
                                     hintText: '00',
                                     controller: widget.dashboardController.stockCtrl,
                                     focusNode: widget.dashboardController.fStockCtrl,
                                   ),
                                 )
                                     :
                                 SizedBox(
                                   width: 73.w,
                                   child: CustomTextFieldWidget(
                                     hintText: '00',
                                     controller: widget.dashboardController.stockControllers[index],
                                   ),
                                 ),
                                 Spacer(),
                                 InkWell(
                                   onTap: () {
                                     widget.dashboardController.stockRows.removeAt(index);
                                     widget.dashboardController.stockControllers.removeAt(index);
                                     setState(() {});
                                   },
                                   child: Padding(
                                     padding: EdgeInsets.only(right: 16.w, left: 7.w),
                                     child: SvgPicture.asset(
                                       AppImage.icDeleteStock,
                                       width: 20.w,
                                     ),
                                   ),
                                 ),
                               ],
                             ),
                           );
                         },
                       );
                     }),
                     ),
                   ),
                 ),


                 Padding(
                   padding: EdgeInsets.only(left: 16.w,top: 20.h),
                   child: Align(
                     alignment: Alignment.centerLeft,
                     child: InkWell(
                       onTap: () {
                         final newRow = ProductStockRow(
                           productId: widget.productId,
                           stockCtrl: TextEditingController(),
                         );
                         widget.dashboardController.stockRows.add(newRow);
                         widget.dashboardController.stockControllers.add(newRow.stockCtrl);
                         setState(() {});
                       },
                       child: SvgPicture.asset(AppImage.icAddStock),
                     ),
                   ),
                 ),
               ],
             ),
           ),

          // Fixed bottom section with button
          Container(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              bottom: 24.h,
              top: 20.h,
            ),
            child: CustomButton(
              text: AppText.submit,
              marginRight: 0,
              marginLeft: 0,
              textStyle: sansSemiBold.copyWith(
                height: 1.4.h,
                fontSize: 18.sp,
                color: AppColor.white,
                letterSpacing: -.1,
              ),
              onPressed: () {
                List<Map<String, dynamic>> stocksToSend = [];

                for (var i = 0; i < widget.dashboardController.stockRows.length; i++) {
                  var stock = widget.dashboardController.stockRows[i];
                  var controller = widget.dashboardController.stockControllers[i];

                  stocksToSend.add({
                    "product_id": stock.productId,
                    "variant_id": stock.variantId,
                    "color_id": stock.colorId,
                    "size_id": stock.sizeId,
                    "stock": int.tryParse(controller.text) ?? 0,
                  });
                }

                Map<String, dynamic> body = {
                  "stocks": stocksToSend,
                };
                widget.dashboardController.stockCreateAndUpdate(body: body);
              },
            ),
          ),
        ],
      ),
    );
  }
}
