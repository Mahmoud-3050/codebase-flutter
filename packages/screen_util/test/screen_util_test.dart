import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_util/screen_util.dart';

void main() {
  const smallerDeviceSize = Size(300, 600);
  const smallerDeviceData = MediaQueryData(size: smallerDeviceSize);

  const biggerDeviceSize = Size(500, 900);
  const biggerDeviceData = MediaQueryData(size: biggerDeviceSize);

  const uiSize = Size(470, 740);

  group('ScreenUtil calculations', () {
    test('scales down on a smaller screen', () {
      ScreenUtil.configure(
        data: smallerDeviceData,
        designSize: uiSize,
        minTextAdapt: true,
        splitScreenMode: false,
      );

      expect(1.w, smallerDeviceSize.width / uiSize.width);
      expect(1.w < 1, isTrue);
      expect(1.h, smallerDeviceSize.height / uiSize.height);
      expect(1.h < 1, isTrue);
      expect(1.r, lessThanOrEqualTo(1.w));
      expect(1.sp, 1.w < 1.h ? 1.w : 1.h);
    });

    test('scales up on a bigger screen', () {
      ScreenUtil.configure(
        data: biggerDeviceData,
        designSize: uiSize,
        minTextAdapt: true,
        splitScreenMode: false,
      );

      expect(1.w, biggerDeviceSize.width / uiSize.width);
      expect(1.w > 1, isTrue);
      expect(1.h, biggerDeviceSize.height / uiSize.height);
      expect(1.h > 1, isTrue);
    });
  });

  testWidgets('ScreenUtilInit initializes and scales to screen width', (
    tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: uiSize,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return SizedBox(width: uiSize.width.w, child: const Text('Test'));
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Test'), findsOneWidget);
    expect(
      uiSize.width.w,
      tester.view.physicalSize.width / tester.view.devicePixelRatio,
    );
  });
}
