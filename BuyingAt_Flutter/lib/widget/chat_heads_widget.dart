import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controller/message_controller.dart';
import '../model/get_all_msg_thread_model.dart';
import '../utils/_constant.dart';
import '../utils/app_color.dart';
import '../utils/app_fonts.dart';
import '../utils/image_loader.dart';

class ChatHeadsWidget extends StatelessWidget {
  final bool isSelect;
  final int index;
  final AllThreadData item;
  final MessageController messageController;

  const ChatHeadsWidget({super.key,
    required this.isSelect,
    required this.index,
    required this.messageController, required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 4.h, right: 2.w),
      margin: EdgeInsets.only(right: 8.w),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 68.h,
                width: 88.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: isSelect
                      ? Border.all(
                    width: 3.w,
                    color: AppColor.buttonColor,
                  )
                      : null,
                ),
                child: ClipRRect(
                  borderRadius:isSelect?BorderRadius.circular(5.r) : BorderRadius.circular(8.r),
                  child: Obx(() {
                    if (messageController.getAllMsgThreadList.isEmpty) {
                      return SizedBox(
                        height: 68.h,
                        width: 88.w,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final imageUrl = item.product?.getGalleryImages?.first.img;
                    return ImageLoader(
                      boxFit: BoxFit.fill,
                      url: imageUrl != null || imageUrl != ""
                          ? "${Constant.imageBaseUrl}$imageUrl"
                          : "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png",
                    );

                  }),
                ),
              ),
              Positioned(
                top: -4.h,
                right: -2.w,
                child: Container(
                  height: 30.h,
                  width: 30.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: AppColor.buttonColor,
                      width: 2.sp,
                    ),
                  ),
                  child: ClipOval(
                    child: Obx(() {
                      if (messageController.getAllMsgThreadList.isEmpty) {
                        return SizedBox(
                          height: 30.h,
                          width: 30.h,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }

                      final userImg = item.product?.getProductUser?.profileImg;
                      return ImageLoader(
                        boxFit: BoxFit.fill,
                        url: userImg != null
                            ? "${Constant.imageBaseUrl}$userImg"
                            : "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png",
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            item.product != null
                ? (item.product!.productTitle!.length > 8
                ? '${item.product!.productTitle!.substring(0, 10)}...'
                : item.product!.productTitle.toString())
                : "no item",
            style: isSelect
                ? sansBold.copyWith(
              fontSize: 14.sp,
              color: AppColor.buttonColor,
            )
                : sansReg.copyWith(
              fontSize: 14.sp,
              color: AppColor.coolGray22,
            ),
          ),
        ],
      ),
    );
  }
}
