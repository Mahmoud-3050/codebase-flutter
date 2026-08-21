import 'dart:async';
import 'package:language/language.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/services/bloc_observer/bloc_observer.dart';
import 'core/services/crashlytics/crashlytics_service.dart';
import 'core/services/language/language_change_adapter.dart';
import 'core/services/local_storage/shared_preferences_language_storage.dart';
import 'core/services/notifications/app_notifications_service.dart';
import 'firebase_options.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ServiceLocator.init();
  await Language.instance.init(
    storage: SharedPreferencesLanguageStorage(
      ServiceLocator.instance<SharedPreferences>(),
    ),
    listener: LanguageChangeAdapter(dioConsumer: dioConsumer),
  );
  await AppNotificationsService.initNotifications();
  if (!kDebugMode) {
    CrashlyticsService.init();
  }
  Bloc.observer = AppBlocObserver();
  runApp(const App());
}
