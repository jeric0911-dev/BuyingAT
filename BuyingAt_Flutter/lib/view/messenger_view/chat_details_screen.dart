import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../helper/date_converter_helper.dart';
import '../../model/get_all_msg_thread_model.dart';
import '../../routes/app_routes.dart';
import '../../transition/fade_transition.dart';
import '../../utils/_constant.dart';
import '../../utils/app_color.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_image.dart';
import '../../utils/app_text.dart';
import '../../utils/image_loader.dart';
import '../../widget/custom_app_bar.dart';
import '../../widget/custom_button.dart';

class ChatDetailsScreen extends StatefulWidget {
  const ChatDetailsScreen({super.key});

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  bool isFavorite = false;
  var currentImageIndex = 0.obs;
  late AllThreadData product;

  @override
  void initState() {
    super.initState();
    product = Get.arguments['item'];
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   detailsController.getSingleProduct(productId: productId);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: AppText.details),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11.4.r),
                border: Border.all(color: AppColor.coolGray17, width: 1.15.w),
              ),
              width: double.infinity,
              child: Column(
                children: [
                  ImageLoader(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(11.4.r),
                      topRight: Radius.circular(11.4.r),
                    ),
                    height: 200.h,
                    width: double.infinity,
                    boxFit: BoxFit.cover,
                    url:
                        "${Constant.imageBaseUrl}${product.product?.getGalleryImages?.first.img}",
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgPicture.asset(AppImage.icClock),
                            SizedBox(width: 12.w),
                            Text(
                              DateConverter.formatToLongDate(
                                product.createdAt.toString(),
                              ),
                              style: sansReg.copyWith(
                                color: AppColor.primaryColor,
                                height: 1.17.h,
                                fontSize: 14.sp
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          product.product!.productTitle.toString(),
                          style: sansSemiBold.copyWith(
                            fontSize: 16.sp,
                            color: AppColor.primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 14.h),

                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '\$ ',
                                style: sansBold.copyWith(
                                  fontSize: 18.sp,
                                  color: AppColor.buttonColor,
                                ),
                              ),
                              TextSpan(
                                text: product.product?.price,
                                style: sansBold.copyWith(
                                  fontSize: 18.sp,
                                  color: AppColor.buttonColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 6.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            CustomButton(
              borderWidth: 1.15.sp,
              borderColor: AppColor.white,
              color: AppColor.babyBlue2,
              marginLeft: 0,
              marginRight: 0,
              text: AppText.viewProduct,
              textStyle: sansSemiBold.copyWith(
                fontSize: 18.sp,
                height: 1.4,
                letterSpacing: -.1,
                color: AppColor.buttonColor,
              ),
              onPressed: () {
                FadeScreenTransition(routeName: Routes.productDtlRoute, arguments: {'PId':product.id,'productUserId':product.product?.userId}).navigate();
              },
            ),
          ],
        ),
      ),
    );
  }
}
