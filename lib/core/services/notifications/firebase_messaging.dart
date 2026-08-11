import 'dart:async';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../injection_container.dart';
import 'local_notifications.dart';

abstract class AppFirebaseMessagingTopics {
  static const String all = 'all';
  static const String users = 'users';
  static const String android = 'android';
  static const String ios = 'ios';
}

abstract class AppFirebaseMessaging{

  static Future<void> setForegroundNotificationPresentationOptions() async{
    return await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
  }

  static void onTokenRefresh(){
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      ServiceLocator.injectFCMTokenSingleton(token);
      log('@AppFirebaseMessaging:: FCM onTokenRefresh: $token');
    });
  }

  static Future<void> getToken() async{
    final String? token = await FirebaseMessaging.instance.getToken();
    if(token != null){
      ServiceLocator.injectFCMTokenSingleton(token);
    }
    log('@AppFirebaseMessaging:: FCM token: $token');
  }

  static void onMessage(LocalNotificationService service){
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      log('@AppFirebaseMessaging:: FCM onMessage: ${event.notification?.title}');
      // ServiceLocator.instance<GetNotificationsCubit>().fGetNotifications();
      _showLocalNotification(service, event);
    });
  }

  static void onMessageOpenedApp(LocalNotificationService service){
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage event) {
      log('@AppFirebaseMessaging:: FCM onMessageOpenedApp: ${event.notification?.title}');
      // ServiceLocator.instance<GetNotificationsCubit>().fGetNotifications();
      _showLocalNotification(service, event);
    });
  }

  static void onBackgroundMessage(){
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
  }

  static Future<void> _backgroundHandler(RemoteMessage event) async{
    log('@AppFirebaseMessaging:: FCM onBackgroundMessage: Title: ${event.notification?.title}');
  }

  static void subscribeToTopic(String topic){
    FirebaseMessaging.instance.subscribeToTopic(topic).then((value) {
      log('@AppFirebaseMessaging:: FCM (Success) Subscribe To Topic[$topic]');
    }).catchError((error){
      log('@AppFirebaseMessaging:: FCM (Error) Subscribe To Topic[$topic], Error: ${error.toString()}');
    });
  }

  static void unsubscribeFromTopic(String topic){
    FirebaseMessaging.instance.unsubscribeFromTopic(topic).then((value) {
      log('@AppFirebaseMessaging:: FCM (Success) Unsubscribe From Topic[$topic]');
    }).catchError((error){
      log('@AppFirebaseMessaging:: FCM (Error) Unsubscribe From Topic[$topic], Error: ${error.toString()}');
    });
  }

  static void _showLocalNotification(LocalNotificationService service, RemoteMessage event){
    String title = event.notification?.title?? '';
    String body = event.notification?.body?? '';
    service.showNotification(id: event.hashCode, title: title, body: body, icon: '');
  }

  static Future<String?> getAPNSToken() async{
    final String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    log('@AppFirebaseMessaging:: getAPNSToken: apnsToken: $apnsToken');
    return apnsToken;
  }
}