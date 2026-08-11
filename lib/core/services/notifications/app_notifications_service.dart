import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../injection_container.dart';
import '../../utils/enums.dart';
import 'firebase_messaging.dart';
import 'local_notifications.dart';

/// add: <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
/// run: flutter pub add permission_handler

abstract class AppNotificationsService {
  static Future<void> initNotifications() async{
    await Firebase.initializeApp();
    requestPermission();
    final LocalNotificationService notificationService = LocalNotificationService();
    await notificationService.initialize();
    bool requestFCMApis = true;
    if(Platform.isIOS){
      final apnsToken = await AppFirebaseMessaging.getAPNSToken();
      if (apnsToken == null) {
        // APNS token is available, make FCM plugin API requests...
        requestFCMApis = false;
      }
    }
    if(requestFCMApis){
      AppFirebaseMessaging.setForegroundNotificationPresentationOptions();
      AppFirebaseMessaging.onMessage(notificationService);
      AppFirebaseMessaging.onMessageOpenedApp(notificationService);
      AppFirebaseMessaging.onBackgroundMessage();
      AppFirebaseMessaging.getToken();
      AppFirebaseMessaging.onTokenRefresh();
      AppFirebaseMessaging.subscribeToTopic(AppFirebaseMessagingTopics.all);
      AppFirebaseMessaging.subscribeToTopic(
          deviceType == DeviceType.ios
              ? AppFirebaseMessagingTopics.ios
              : AppFirebaseMessagingTopics.android
      );
    }
  }
  
  static Future<void> requestPermission() async {
    // final result = await FirebaseMessaging.instance.requestPermission();
    // log('requestPermission FirebaseMessaging: ${result.notificationCenter.name}');
    // if(result.notificationCenter == AppleNotificationSetting.enabled){
    //   return;
    // }
    PermissionStatus status = await Permission.notification.status;
    log('requestPermission PermissionStatus: ${status.toString()}');
    if (status != PermissionStatus.granted) {
      status = await Permission.notification.request();
      log('requestPermission PermissionStatus.request(): ${status.toString()}');
    }
  }
}