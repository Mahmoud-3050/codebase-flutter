import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/services/bloc_observer/bloc_observer.dart';
import 'core/services/crashlytics/crashlytics_service.dart';
import 'core/services/notifications/app_notifications_service.dart';
import 'firebase_options.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ServiceLocator.init();
  await AppNotificationsService.initNotifications();
  if (!kDebugMode) {
    CrashlyticsService.init();
  }
  Bloc.observer = AppBlocObserver();
  runApp(const App());
}
