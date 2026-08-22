import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../utils/values/assets.dart';
import '../../config/themes/extra_colors.dart';
import 'app_shimmer.dart';

class AppImage extends StatelessWidget {
  final GlobalKey? imageKey;
  final String? imageUrl;
  final File? imageFile;
  final String? imageAsset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final bool? isCached;
  final bool? isCircle;
  final Duration? fadeDuration;

  const AppImage({
    this.imageKey,
    this.imageUrl,
    this.imageFile,
    this.imageAsset,
    this.width,
    this.height,
    this.fit = BoxFit.fill,
    this.color,
    this.isCached = false,
    this.isCircle = false,
    this.fadeDuration,
    super.key,
  });

  factory AppImage.network({
    String? imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.fill,
    Color? color,
    bool? isCached,
    bool? isCircle,
    Duration? fadeDuration,
  }) {
    return AppImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      color: color,
      isCached: isCached ?? false,
      isCircle: isCircle ?? false,
      fadeDuration: fadeDuration,
    );
  }

  factory AppImage.file({
    GlobalKey? imageKey,
    File? imageFile,
    double? width,
    double? height,
    BoxFit fit = BoxFit.fill,
    Color? color,
    bool? isCircle,
  }) {
    return AppImage(
      key: imageKey,
      imageFile: imageFile,
      width: width,
      height: height,
      fit: fit,
      color: color,
      isCircle: isCircle ?? false,
    );
  }

  factory AppImage.asset({
    String? imageAsset,
    double? width,
    double? height,
    BoxFit fit = BoxFit.fill,
    Color? color,
    bool? isCircle,
  }) {
    return AppImage(
      imageAsset: imageAsset,
      width: width,
      height: height,
      fit: fit,
      color: color,
      isCircle: isCircle ?? false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        if (imageUrl != null) {
          return _imageNetwork;
        }
        if (imageFile != null) {
          return _imageFile;
        }
        if (imageAsset != null) {
          return _imageAsset;
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildBaseCircle(ImageProvider child) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: child,
          fit: fit,
        ),
      ),
    );
  }

  Image get _imageAssetItem => Image.asset(
        imageAsset!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (BuildContext context, Object url, StackTrace? error) =>
            _errorWidget,
      );

  Widget get _imageAsset {
    if (isCircle == true) {
      return _buildBaseCircle(_imageAssetItem.image);
    }
    return _imageAssetItem;
  }

  Image get _imageFileItem => Image.file(
        key: imageKey,
        imageFile!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (BuildContext context, Object url, StackTrace? error) =>
            _errorWidget,
      );

  Widget get _imageFile {
    if (isCircle == true) {
      return _buildBaseCircle(_imageFileItem.image);
    }
    return _imageFileItem;
  }

  Image get _imageNetworkItem => Image.network(
        imageUrl!,
        color: color,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (fadeDuration != null) {
            return child.animate().fadeIn(
                  curve: Curves.easeInOut,
                  duration: fadeDuration,
                );
          } else {
            return child;
          }
        },
        errorBuilder: (BuildContext context, _, dynamic error) => _errorWidget,
      );

  Widget get _imageNetwork {
    // Check if the imageUrl is null or empty
    if (imageUrl == null || imageUrl?.isEmpty == true) {
      if (isCircle == true) {
        return _buildBaseCircle(
          _placeholderImage.image,
        );
      }
      return _placeholderImage;
    }
    if (isCached == true) {
      if (isCircle == true) {
        return _buildBaseCircle(CachedNetworkImageProvider(
          imageUrl!,
          maxWidth: width?.toInt(),
          maxHeight: height?.toInt(),
        ));
      }
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        color: color,
        width: width,
        height: height,
        fit: fit,
        placeholderFadeInDuration: const Duration(milliseconds: 500),
        placeholder: (BuildContext context, String url) => _loadingWidget,
        errorWidget: (BuildContext context, String url, dynamic error) =>
            _errorWidget,
      );
    }
    if (isCircle == true) {
      return _buildBaseCircle(_imageNetworkItem.image);
    }
    return _imageNetworkItem;
  }

  Widget get _loadingWidget => Center(
        child: AppShimmer(
          child: Container(
            width: width,
            height: height,
            color: colors.baseColorShimmer,
          ),
        ),
      );

  // Widget _loadingProgressWidget(ImageChunkEvent loadingProgress) => Center(
  //   child: CircularProgressIndicator(
  //     value: loadingProgress.expectedTotalBytes != null
  //         ? loadingProgress.cumulativeBytesLoaded /
  //         loadingProgress.expectedTotalBytes!
  //         : null,
  //   ).appLoading,
  // );

  Widget get _errorWidget => Center(
        child: Container(
          width: width,
          height: height,
          color: colors.baseColorShimmer,
          child: const Icon(
            Icons.error,
            color: Colors.grey,
          ),
        ),
      );

  Image get _placeholderImage {
    return Image.asset(
      Assets.imagesPlaceholder,
      width: width,
      height: height,
      fit: fit,
    );
  }
}
