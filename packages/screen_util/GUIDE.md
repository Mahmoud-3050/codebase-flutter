# screen_util

Local port of [flutter_screenutil](https://pub.dev/packages/flutter_screenutil) 5.9.3.
Public API names match the upstream package so host call sites stay unchanged.

Import `package:screen_util/screen_util.dart`.

| API | Use |
|---|---|
| `ScreenUtilInit` | Wrap the app root; set `designSize` and rebuild/scale options |
| `ScreenUtil()` | Singleton: `setWidth`, `setHeight`, `radius`, `setSp`, screen metrics |
| `num` extensions | `.w` `.h` `.r` `.sp` `.sw` `.sh` and spacing helpers |
| `RPadding` / `REdgeInsets` / `RSizedBox` | Pre-scaled layout widgets |
| `SU` mixin | Opt a custom widget into the resize rebuild sweep |
| `RebuildFactors` | When `ScreenUtilInit` rebuilds on metric changes |
| `FontSizeResolvers` | How `.sp` scales (width / height / radius / diameter / diagonal) |

Original work: Apache-2.0, 李卓原 / OpenFlutter. See `LICENSE` and `NOTICE`.
