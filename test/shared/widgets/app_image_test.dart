import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themes/testing.dart';
import 'package:themes/themes.dart';

import 'package:codebase/config/themes/app_theme.dart';
import 'package:codebase/config/themes/colors_palettes.dart';
import 'package:codebase/core/utils/values/assets.dart';
import 'package:codebase/shared/widgets/app_image.dart';
import 'package:codebase/shared/widgets/app_shimmer.dart';

void main() {
  setUp(() async {
    await Themes.instance.init(config: ColorsPalettes.config);
  });

  tearDown(resetThemes);

  group('factories', () {
    test('network factory forwards fields', () {
      const fade = Duration(milliseconds: 120);
      final widget = AppImage.network(
        imageUrl: 'https://example.com/a.png',
        width: 10,
        height: 20,
        fit: .cover,
        color: Colors.red,
        isCached: true,
        isCircle: true,
        fadeDuration: fade,
        borderRadius: 8,
        borderColor: Colors.blue,
        borderWidth: 3,
        backgroundColor: Colors.green,
      );

      expect(widget.imageUrl, 'https://example.com/a.png');
      expect(widget.width, 10);
      expect(widget.height, 20);
      expect(widget.fit, BoxFit.cover);
      expect(widget.color, Colors.red);
      expect(widget.isCached, isTrue);
      expect(widget.isCircle, isTrue);
      expect(widget.fadeDuration, fade);
      expect(widget.borderRadius, 8);
      expect(widget.borderColor, Colors.blue);
      expect(widget.borderWidth, 3);
      expect(widget.backgroundColor, Colors.green);
    });

    test(
      'file factory forwards fields and does not reuse imageKey as widget key',
      () {
        final imageKey = GlobalKey();
        final file = File('missing.png');
        final widget = AppImage.file(
          imageKey: imageKey,
          imageFile: file,
          width: 12,
          height: 14,
          fit: .contain,
          color: Colors.orange,
          isCircle: true,
          borderRadius: 4,
          borderColor: Colors.black,
          borderWidth: 1,
          backgroundColor: Colors.white,
        );

        expect(widget.key, isNull);
        expect(widget.imageKey, imageKey);
        expect(widget.imageFile, file);
        expect(widget.width, 12);
        expect(widget.height, 14);
        expect(widget.fit, BoxFit.contain);
        expect(widget.color, Colors.orange);
        expect(widget.isCircle, isTrue);
        expect(widget.borderRadius, 4);
        expect(widget.borderColor, Colors.black);
        expect(widget.borderWidth, 1);
        expect(widget.backgroundColor, Colors.white);
      },
    );

    test('asset factory forwards fields', () {
      final widget = AppImage.asset(
        imageAsset: Assets.imagesPlaceholder,
        width: 16,
        height: 18,
        fit: .fitWidth,
        color: Colors.purple,
        borderRadius: 6,
        borderColor: Colors.teal,
        borderWidth: 2,
        backgroundColor: Colors.grey,
      );

      expect(widget.imageAsset, Assets.imagesPlaceholder);
      expect(widget.width, 16);
      expect(widget.height, 18);
      expect(widget.fit, BoxFit.fitWidth);
      expect(widget.color, Colors.purple);
      expect(widget.isCircle, isFalse);
      expect(widget.borderRadius, 6);
      expect(widget.borderColor, Colors.teal);
      expect(widget.borderWidth, 2);
      expect(widget.backgroundColor, Colors.grey);
    });

    test('defaults match the public constructor', () {
      const widget = AppImage();
      expect(widget.fit, BoxFit.fill);
      expect(widget.isCached, isFalse);
      expect(widget.isCircle, isFalse);
    });
  });

  group('source resolution', () {
    testWidgets('empty network url shows the placeholder asset', (
      tester,
    ) async {
      await tester.pumpWidget(_harness(const AppImage(imageUrl: '')));

      expect(
        _imageProvider(tester),
        const AssetImage(Assets.imagesPlaceholder),
      );
    });

    testWidgets('empty asset shows the placeholder', (tester) async {
      await tester.pumpWidget(_harness(const AppImage(imageAsset: '')));

      expect(
        _imageProvider(tester),
        const AssetImage(Assets.imagesPlaceholder),
      );
    });

    testWidgets('missing source with a size still shows the placeholder', (
      tester,
    ) async {
      await tester.pumpWidget(_harness(const AppImage(width: 40, height: 40)));

      expect(
        _imageProvider(tester),
        const AssetImage(Assets.imagesPlaceholder),
      );
    });

    testWidgets('asset factory renders the given asset', (tester) async {
      await tester.pumpWidget(
        _harness(AppImage.asset(imageAsset: Assets.imagesPlaceholder)),
      );

      expect(
        _imageProvider(tester),
        const AssetImage(Assets.imagesPlaceholder),
      );
    });

    testWidgets('empty url falls through to the asset', (tester) async {
      await tester.pumpWidget(
        _harness(
          const AppImage(
            imageUrl: '',
            imageAsset: Assets.imagesPlaceholderUser,
          ),
        ),
      );

      expect(
        _imageProvider(tester),
        const AssetImage(Assets.imagesPlaceholderUser),
      );
    });

    testWidgets('non-empty url wins over file and asset', (tester) async {
      await tester.pumpWidget(
        _harness(
          AppImage(
            imageUrl: 'https://example.com/a.png',
            imageFile: File('ignored.png'),
            imageAsset: Assets.imagesPlaceholderUser,
            isCached: true,
          ),
        ),
      );

      expect(find.byType(CachedNetworkImage), findsOneWidget);
      expect(
        tester
            .widget<CachedNetworkImage>(find.byType(CachedNetworkImage))
            .imageUrl,
        'https://example.com/a.png',
      );
    });

    testWidgets('file wins over asset when url is absent', (tester) async {
      await tester.pumpWidget(
        _harness(
          AppImage(
            imageFile: File('missing-app-image.png'),
            imageAsset: Assets.imagesPlaceholderUser,
          ),
        ),
      );

      expect(_imageProvider(tester), isA<FileImage>());
      expect(
        _imageProvider(tester),
        isNot(const AssetImage(Assets.imagesPlaceholderUser)),
      );
    });
  });

  group('framing', () {
    testWidgets(
      'isCircle clips with a circular decoration and ignores radius',
      (tester) async {
        await tester.pumpWidget(
          _harness(
            const AppImage(
              imageAsset: Assets.imagesPlaceholder,
              isCircle: true,
              borderRadius: 12,
              width: 40,
              height: 40,
            ),
          ),
        );

        final decoration = _frameDecoration(tester);
        expect(decoration.shape, BoxShape.circle);
        expect(decoration.borderRadius, isNull);
        expect(_frameContainer(tester).clipBehavior, Clip.hardEdge);
      },
    );

    testWidgets('borderRadius clips a rounded rectangle', (tester) async {
      await tester.pumpWidget(
        _harness(
          const AppImage(
            imageAsset: Assets.imagesPlaceholder,
            borderRadius: 12,
            width: 40,
            height: 40,
          ),
        ),
      );

      final decoration = _frameDecoration(tester);
      expect(decoration.shape, BoxShape.rectangle);
      expect(decoration.borderRadius, BorderRadius.circular(12));
    });

    testWidgets('borderColor uses default width 2', (tester) async {
      await tester.pumpWidget(
        _harness(
          const AppImage(
            imageAsset: Assets.imagesPlaceholder,
            borderColor: Colors.red,
          ),
        ),
      );

      expect(
        _frameDecoration(tester).border,
        Border.all(color: Colors.red, width: 2),
      );
    });

    testWidgets('borderWidth alone uses a white border', (tester) async {
      await tester.pumpWidget(
        _harness(
          const AppImage(imageAsset: Assets.imagesPlaceholder, borderWidth: 4),
        ),
      );

      expect(
        _frameDecoration(tester).border,
        Border.all(color: Colors.white, width: 4),
      );
    });

    testWidgets('backgroundColor is painted on the frame', (tester) async {
      await tester.pumpWidget(
        _harness(
          const AppImage(
            imageAsset: Assets.imagesPlaceholder,
            backgroundColor: Colors.amber,
            width: 40,
            height: 40,
          ),
        ),
      );

      expect(_frameDecoration(tester).color, Colors.amber);
    });

    testWidgets('width and height are applied to the frame', (tester) async {
      await tester.pumpWidget(
        _harness(
          const AppImage(
            imageAsset: Assets.imagesPlaceholder,
            width: 48,
            height: 32,
          ),
        ),
      );

      expect(tester.getSize(find.byType(AppImage)), const Size(48, 32));
    });
  });

  group('network', () {
    testWidgets('uncached network uses Image.network', (tester) async {
      await tester.pumpWidget(
        _harness(
          AppImage.network(
            imageUrl: 'https://example.com/a.png',
            color: Colors.red,
            width: 40,
            height: 40,
            fit: .cover,
          ),
        ),
      );

      final image = tester.widget<Image>(
        find.byWidgetPredicate(
          (candidate) => candidate is Image && candidate.image is NetworkImage,
        ),
      );
      expect((image.image as NetworkImage).url, 'https://example.com/a.png');
      expect(image.color, Colors.red);
      expect(image.fit, BoxFit.cover);
      expect(image.width, 40);
      expect(image.height, 40);
    });

    testWidgets('cached network uses CachedNetworkImage and shimmer', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          AppImage.network(
            imageUrl: 'https://example.com/a.png',
            isCached: true,
            color: Colors.blue,
            width: 40,
            height: 40,
            fadeDuration: const Duration(milliseconds: 120),
          ),
        ),
      );

      final cached = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      final pixelRatio = tester.view.devicePixelRatio;
      expect(cached.imageUrl, 'https://example.com/a.png');
      expect(cached.color, Colors.blue);
      expect(cached.width, 40);
      expect(cached.height, 40);
      expect(cached.fadeInDuration, const Duration(milliseconds: 120));
      expect(cached.memCacheWidth, (40 * pixelRatio).round());
      expect(cached.memCacheHeight, (40 * pixelRatio).round());
      expect(find.byType(AppShimmer), findsOneWidget);
    });

    testWidgets('cached network without size omits mem cache dimensions', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          AppImage.network(
            imageUrl: 'https://example.com/a.png',
            isCached: true,
          ),
        ),
      );

      final cached = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(cached.memCacheWidth, isNull);
      expect(cached.memCacheHeight, isNull);
      expect(cached.fadeInDuration, const Duration(milliseconds: 300));
    });
  });

  group('file', () {
    testWidgets('file branch uses FileImage and imageKey', (tester) async {
      final imageKey = GlobalKey();
      final file = File('missing-app-image.png');

      await tester.pumpWidget(
        _harness(
          AppImage.file(
            imageKey: imageKey,
            imageFile: file,
            width: 40,
            height: 40,
            color: Colors.green,
            fit: .contain,
          ),
        ),
      );

      final image = tester.widget<Image>(find.byKey(imageKey));
      expect(image.image, FileImage(file));
      expect(image.color, Colors.green);
      expect(image.fit, BoxFit.contain);
      expect(image.width, 40);
      expect(image.height, 40);
    });
  });

  group('asset', () {
    testWidgets('missing asset falls back to the placeholder', (tester) async {
      await tester.pumpWidget(
        _harness(
          const AppImage(imageAsset: 'assets/images/does-not-exist.png'),
        ),
      );
      await tester.pump();
      tester.takeException();
      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (Widget candidate) =>
              candidate is Image &&
              candidate.image == const AssetImage(Assets.imagesPlaceholder),
        ),
        findsOneWidget,
      );
    });

    testWidgets('passes color and fit to the asset image', (tester) async {
      await tester.pumpWidget(
        _harness(
          const AppImage(
            imageAsset: Assets.imagesPlaceholder,
            color: Colors.red,
            fit: .contain,
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.color, Colors.red);
      expect(image.fit, BoxFit.contain);
    });
  });

  group('lifecycle', () {
    testWidgets('rebuilds the image subtree when the app resumes', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(const AppImage(imageAsset: Assets.imagesPlaceholder)),
      );

      expect(find.byKey(const ValueKey<int>(0)), findsOneWidget);

      tester.binding.handleAppLifecycleStateChanged(.paused);
      await tester.pump();
      expect(find.byKey(const ValueKey<int>(0)), findsOneWidget);

      tester.binding.handleAppLifecycleStateChanged(.inactive);
      await tester.pump();
      expect(find.byKey(const ValueKey<int>(0)), findsOneWidget);

      tester.binding.handleAppLifecycleStateChanged(.resumed);
      await tester.pump();

      expect(find.byKey(const ValueKey<int>(0)), findsNothing);
      expect(find.byKey(const ValueKey<int>(1)), findsOneWidget);
    });

    testWidgets('does not throw after dispose when the app resumes', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(const AppImage(imageAsset: Assets.imagesPlaceholder)),
      );
      await tester.pumpWidget(_harness(const SizedBox()));

      tester.binding.handleAppLifecycleStateChanged(.resumed);
      await tester.pump();
    });
  });
}

ImageProvider<Object> _imageProvider(WidgetTester tester) {
  return tester.widget<Image>(find.byType(Image)).image;
}

Container _frameContainer(WidgetTester tester) {
  return tester.widget<Container>(
    find
        .descendant(of: find.byType(AppImage), matching: find.byType(Container))
        .first,
  );
}

BoxDecoration _frameDecoration(WidgetTester tester) {
  return _frameContainer(tester).decoration! as BoxDecoration;
}

Widget _harness(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(393, 852),
    minTextAdapt: true,
    builder: (context, _) {
      return MaterialApp(
        theme: appTheme(ColorsPalettes.config.light, .light),
        home: Scaffold(body: Center(child: child)),
      );
    },
  );
}
