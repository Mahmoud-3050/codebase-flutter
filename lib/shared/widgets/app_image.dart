import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:themes/themes.dart';

import '../../config/themes/extra_colors.dart';
import '../../core/utils/values/assets.dart';
import 'app_shimmer.dart';

class AppImage extends StatefulWidget {
  final GlobalKey? imageKey;
  final String? imageUrl;
  final File? imageFile;
  final String? imageAsset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final bool isCached;
  final bool isCircle;
  final Duration? fadeDuration;
  final double? borderRadius;
  final Color? borderColor;
  final double? borderWidth;
  final Color? backgroundColor;

  const AppImage({
    this.imageKey,
    this.imageUrl,
    this.imageFile,
    this.imageAsset,
    this.width,
    this.height,
    this.fit = .fill,
    this.color,
    this.isCached = false,
    this.isCircle = false,
    this.fadeDuration,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.backgroundColor,
    super.key,
  });

  factory AppImage.network({
    String? imageUrl,
    double? width,
    double? height,
    BoxFit fit = .fill,
    Color? color,
    bool isCached = false,
    bool isCircle = false,
    Duration? fadeDuration,
    double? borderRadius,
    Color? borderColor,
    double? borderWidth,
    Color? backgroundColor,
  }) {
    return AppImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      color: color,
      isCached: isCached,
      isCircle: isCircle,
      fadeDuration: fadeDuration,
      borderRadius: borderRadius,
      borderColor: borderColor,
      borderWidth: borderWidth,
      backgroundColor: backgroundColor,
    );
  }

  factory AppImage.file({
    GlobalKey? imageKey,
    File? imageFile,
    double? width,
    double? height,
    BoxFit fit = .fill,
    Color? color,
    bool isCircle = false,
    double? borderRadius,
    Color? borderColor,
    double? borderWidth,
    Color? backgroundColor,
  }) {
    return AppImage(
      imageKey: imageKey,
      imageFile: imageFile,
      width: width,
      height: height,
      fit: fit,
      color: color,
      isCircle: isCircle,
      borderRadius: borderRadius,
      borderColor: borderColor,
      borderWidth: borderWidth,
      backgroundColor: backgroundColor,
    );
  }

  factory AppImage.asset({
    String? imageAsset,
    double? width,
    double? height,
    BoxFit fit = .fill,
    Color? color,
    bool isCircle = false,
    double? borderRadius,
    Color? borderColor,
    double? borderWidth,
    Color? backgroundColor,
  }) {
    return AppImage(
      imageAsset: imageAsset,
      width: width,
      height: height,
      fit: fit,
      color: color,
      isCircle: isCircle,
      borderRadius: borderRadius,
      borderColor: borderColor,
      borderWidth: borderWidth,
      backgroundColor: backgroundColor,
    );
  }

  @override
  State<AppImage> createState() => _AppImageState();
}

class _AppImageState extends State<AppImage> with WidgetsBindingObserver {
  int _textureGeneration = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != .resumed || !mounted) return;
    setState(() => _textureGeneration++);
  }

  @override
  Widget build(BuildContext context) {
    return _framed(
      KeyedSubtree(
        key: ValueKey<int>(_textureGeneration),
        child: _resolveChild(context),
      ),
    );
  }

  Widget _resolveChild(BuildContext context) {
    final url = widget.imageUrl;
    if (url != null && url.isNotEmpty) return _networkImage(context, url);

    final file = widget.imageFile;
    if (file != null) return _fileImage(file);

    final asset = widget.imageAsset;
    if (asset != null && asset.isNotEmpty) return _assetImage(asset);

    return _fallbackImage(context);
  }

  Widget _framed(Widget child) {
    final radius = widget.borderRadius ?? 0;
    return Container(
      width: widget.width,
      height: widget.height,
      clipBehavior: .hardEdge,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        shape: widget.isCircle ? .circle : .rectangle,
        borderRadius: widget.isCircle || radius == 0 ? null : .circular(radius),
        border: widget.borderColor != null || widget.borderWidth != null
            ? Border.all(
                color: widget.borderColor ?? Colors.white,
                width: widget.borderWidth ?? 2,
              )
            : null,
      ),
      child: child,
    );
  }

  Widget _networkImage(BuildContext context, String url) {
    if (widget.isCached) return _cachedNetworkImage(context, url);
    return _rawNetworkImage(context, url);
  }

  Widget _cachedNetworkImage(BuildContext context, String url) {
    final pixelRatio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    final cacheWidth = widget.width;
    final cacheHeight = widget.height;
    return CachedNetworkImage(
      imageUrl: url,
      color: widget.color,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      memCacheWidth: cacheWidth == null
          ? null
          : (cacheWidth * pixelRatio).round(),
      memCacheHeight: cacheHeight == null
          ? null
          : (cacheHeight * pixelRatio).round(),
      fadeInDuration: widget.fadeDuration ?? const Duration(milliseconds: 300),
      placeholderFadeInDuration: const Duration(milliseconds: 500),
      placeholder: (BuildContext context, String url) =>
          _loadingWidget(context),
      errorWidget: (BuildContext context, String url, Object error) =>
          _fallbackImage(context),
    );
  }

  Widget _rawNetworkImage(BuildContext context, String url) {
    return Image.network(
      url,
      color: widget.color,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      loadingBuilder:
          (BuildContext context, Widget child, ImageChunkEvent? progress) {
            if (progress != null) return _loadingWidget(context);
            return _fadeLoaded(child);
          },
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
          _fallbackImage(context),
    );
  }

  Widget _fileImage(File file) {
    return Image.file(
      key: widget.imageKey,
      file,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      color: widget.color,
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
          _fallbackImage(context),
    );
  }

  Widget _assetImage(String asset) {
    return Image.asset(
      asset,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      color: widget.color,
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
          _fallbackImage(context),
    );
  }

  Widget _fadeLoaded(Widget child) {
    final duration = widget.fadeDuration;
    if (duration == null) return child;
    return child.animate().fadeIn(curve: Curves.easeInOut, duration: duration);
  }

  Widget _loadingWidget(BuildContext context) {
    return AppShimmer(
      child: Container(
        width: widget.width,
        height: widget.height,
        color: context.colors.baseColorShimmer,
      ),
    );
  }

  Widget _fallbackImage(BuildContext context) {
    return Image.asset(
      Assets.imagesPlaceholder,
      width: widget.width,
      height: widget.height,
      fit: .cover,
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
        return ColoredBox(
          color: context.colors.baseColorShimmer,
          child: Icon(Icons.image, color: context.colors.grey400),
        );
      },
    );
  }
}
