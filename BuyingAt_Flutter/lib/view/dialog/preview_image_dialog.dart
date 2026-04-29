import 'dart:async';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:classified/controller/product_details_controller.dart';
import 'package:classified/model/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/instance_manager.dart';
import 'package:get/route_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../utils/_constant.dart';
import '../../utils/app_color.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_image.dart';
import '../../utils/app_text.dart';
import '../../utils/image_loader.dart';
import '../../widget/custom_app_bar.dart';

class PreviewImage extends StatefulWidget {
  final List<GetGalleryImage>? images;
  final int activeIndex;

  const PreviewImage({super.key, this.images, this.activeIndex = 0});

  @override
  _PreviewImageState createState() => _PreviewImageState();
}

class _PreviewImageState extends State<PreviewImage> {
  late PageController _pageController;

  @override
  void initState() {
    _currentIndex = widget.activeIndex;
    _pageController = PageController(initialPage: _currentIndex);

    super.initState();
    _loadImageSize(index: _currentIndex);
    // ScreenshotService.preventScreenshots();
  }

  ImageProvider<Object>? imageProvider;
  int _currentIndex = 0;
  double _imageHeight = 0.0;
  double _imageWidth = 0.0;
  double aspectRatio = 0.0;

  Future<void> _loadImageSize({int index = 0}) async {
    _currentIndex = index;
    Size imageSize = await getImageSize(
        '${Constant.imageBaseUrl}${widget.images![_currentIndex].img}');
    setState(() {
      _imageHeight = imageSize.height;
      _imageWidth = imageSize.width;
      aspectRatio = _imageWidth / _imageHeight;
      _imageHeight = 1.sw / aspectRatio;
    });
  }

  Future<Size> getImageSize(String imageUrl) async {
    final Completer<Size> completer = Completer();

    final CachedNetworkImageProvider provider = CachedNetworkImageProvider(imageUrl);

    final ImageStream stream = provider.resolve(const ImageConfiguration());

    stream.addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        var myImage = info.image;
        completer.complete(
          Size(myImage.width.toDouble(), myImage.height.toDouble()),
        );
      }),
    );

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar:  CustomAppBar(
        appHeight: 0,
        isBackButtonExist: false,
        color: Colors.black,
      ),
      body: Stack(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                itemCount: widget.images!.length,
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: CachedNetworkImageProvider(
                        '${Constant.imageBaseUrl}${widget.images![index].img}'),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 1.2,
                    heroAttributes:
                        PhotoViewHeroAttributes(tag: widget.images![index]),
                  );
                },
                pageController: _pageController,
                onPageChanged: (index) {
                  _loadImageSize(index: index);
                },
              ),
              Container(
                height: _imageHeight,
                width: 1.sw,
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.fromLTRB(0, 0, 16.w, 10.h),
                child: Text(
                  AppText.appText,
                  style: sansBold.copyWith(
                    fontSize: 24.sp,
                    color: AppColor.white.withValues(alpha: 0.66),
                  ),
                ),
              ),
              Container(
                height: _imageHeight,
                width: 1.sw,
                alignment: Alignment.topRight,
                padding: EdgeInsets.fromLTRB(0, 16.h, 16.w, 0),
                child: Container(
                  padding: EdgeInsets.fromLTRB(8.w, 7.h, 8.w, 5.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.w),
                    color: AppColor.buttonColor.withValues(alpha: .5),
                    border: Border.all(
                        color: AppColor.white.withValues(alpha: 0.25),
                        strokeAlign: BorderSide.strokeAlignOutside),
                  ),
                  child: Text(
                    '${_currentIndex + 1}/${widget.images?.length ?? 0}',
                    style: sansBold.copyWith(
                      fontSize: 14.sp,
                      color: AppColor.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 60.h,
              margin: EdgeInsets.only(bottom: 100.h),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.only(left: 8.w),
                itemCount: widget.images?.length ?? 0,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      _pageController.jumpToPage(index);
                      _loadImageSize(index: index);
                    },
                    child: Container(
                      height: 52.h,
                      margin: EdgeInsets.symmetric(horizontal: 7.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.w),
                        border: Border.all(
                          color: _currentIndex == index
                              ? AppColor.white
                              : Colors.transparent,
                          width: _currentIndex == index ? 1 : 0,
                          strokeAlign: BorderSide.strokeAlignOutside,
                        ),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                      child: ImageLoader(
                        url: '${Constant.imageBaseUrl}${widget.images![index].img}',
                        height: 52.h,
                        width: 70.w,
                        radius: 5.w,
                        boxFit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(8.w, 10.h, 8.w, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildBackButton(
                    onTap: () {
                      Get.back();
                    },
                    image: AppImage.icBack1),
                const Spacer(),
                _buildBackButton(
                    onTap: () {
                      Get.find<ProductDetailsController>().downloadImage(
                          imagePath:
                              '${Constant.imageBaseUrl}${widget.images![_currentIndex].img}');
                    },
                    image: AppImage.icDownload),
                SizedBox(
                  width: 8.w,
                ),
                _buildBackButton(
                    onTap: () {
                      Get.back();
                    },
                    image: AppImage.icExitScreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton({required Function onTap, required String image}) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        onTap();
      },
      child: const SizedBox(
        height: 36,
        width: 36,
      ).blurred(
        colorOpacity: .1,
        borderRadius: BorderRadius.circular(9),
        blur: 2,
        blurColor: const Color(0xFF121212).withValues(alpha: .04),
        overlay: SvgPicture.asset(
          image,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // ScreenshotService.allowScreenshots();
    super.dispose();
  }
}
