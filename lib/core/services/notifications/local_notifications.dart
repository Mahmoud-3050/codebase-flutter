import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService{

  final FlutterLocalNotificationsPlugin _service = FlutterLocalNotificationsPlugin();


  static Future<void> requestPermission(FlutterLocalNotificationsPlugin instance) async{
    final bool? result = await instance
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    log('@NOTIFICATIONS:: FlutterLocalNotificationsPlugin requestPermission $result');
  }

  Future<void> initialize() async{
    log('@NOTIFICATIONS:: FlutterLocalNotificationsPlugin initialize STARTING...');
    const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    DarwinInitializationSettings iosInitializationSettings = const DarwinInitializationSettings(
      notificationCategories: <DarwinNotificationCategory>[
        DarwinNotificationCategory(
            'demoCategory',
            options: <DarwinNotificationCategoryOption>{
              DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
            }
        ),
      ],
      // onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) =>
      //     showNotification(id: id, title: title?? '', body: body?? '', icon: ''),
    );
    InitializationSettings settings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    bool? isInit = await _service.initialize(settings: settings);
    log('@NOTIFICATIONS:: FlutterLocalNotificationsPlugin initialized $isInit');
    requestPermission(_service);
  }

  Future<NotificationDetails> _notificationsDetails(String icon) async{
    AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails(
      'my_channel_id',
      'my_channel_name',
      channelDescription: 'my_description',
      importance: Importance.max,
      priority: Priority.max,
      //sound: RawResourceAndroidNotificationSound('notification'),
    );
    return NotificationDetails(android: androidNotificationDetails);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String icon,
  }) async{
    log('@NOTIFICATIONS:: showNotification id($id) title($title) STARTING...');
    log('@NOTIFICATIONS:: showNotification NotificationDetails title: $title, body: $body');
    final NotificationDetails details = await _notificationsDetails(icon);
    await _service.show(id: id, title: title, body: body, notificationDetails: details);
  }

  // void onDidReceiveLocalNotification({int? id, String? title, String? body, String? payload}){
  //   log('@NOTIFICATIONS:: onDidReceiveLocalNotification id($id) title($title)');
  // }
}