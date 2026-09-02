import 'package:flutter/material.dart';

import 'app.dart';
import 'core/services/crashlytics/crashlytics_service.dart';
import 'core/utils/enums.dart';
import 'init_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppFlavor.activate(.live);
  await initApp();
  CrashlyticsService.init();
  runApp(const App());
}
