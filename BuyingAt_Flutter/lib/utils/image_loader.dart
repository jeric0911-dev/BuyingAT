import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'app_color.dart';
import 'custom_cache_manager.dart';

class ImageLoader extends StatelessWidget {
  final String url;
  final double? width, height, radius, size;
  final BoxFit? boxFit;
  final Color? bgColor;
  final BorderRadius? borderRadius;

  const ImageLoader(
      {super.key,
      required this.url,
      this.width,
      this.height,
      this.boxFit,
      this.radius,
      this.bgColor,
      this.size, this.borderRadius,
      });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:borderRadius ?? BorderRadius.circular(radius ?? 0),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor
        ),
        child: CachedNetworkImage(
          key: UniqueKey(),
          imageUrl: url,
          cacheManager: CustomCacheManager.instance,
          fit: boxFit ?? BoxFit.fill,
          width: size ?? width,
          height: size ?? height,
          progressIndicatorBuilder: (BuildContext context, String child,
              DownloadProgress? loadingProgress) {
            if (loadingProgress == null) {
              return const SizedBox();
            } else {
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.downloaded /
                      (loadingProgress.totalSize ?? 1),
                  color: AppColor.buttonColor.withValues(alpha: 0.4),
                ),
              );
            }
          },
          errorListener: (_){

          },
          errorWidget: (BuildContext context, String s, Object error) {
            return Container(
              width: size ?? width,
              height: size ?? height,
              color: AppColor.white,
            );
          },
        ),
      ),
    );
  }
}
