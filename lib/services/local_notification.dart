import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  late final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  void initialize() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'));
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_priority_channel', // id
      'High Priority Notifications', // title
      importance: Importance.max,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void display(RemoteMessage message) {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    try {
      // final Int64List vibrationPattern = Int64List(4);
      // vibrationPattern[0] = 0;
      // vibrationPattern[1] = 1000;
      // vibrationPattern[2] = 5000;
      // vibrationPattern[3] = 2000;

      final NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
        'high_priority_channel', 'High Priority Notifications',
        importance: Importance.max,
        priority: Priority.high,
        // playSound: true,
        // vibrationPattern: vibrationPattern,
        // enableLights: true,
        // ledColor: const Color.fromARGB(255, 255, 0, 0),
        // ledOnMs: 1000,
        // ledOffMs: 500
      ));

      flutterLocalNotificationsPlugin.show(
          message.notification.hashCode,
          message.notification!.title,
          message.notification!.body,
          notificationDetails);
    } on Exception catch (e) {
      print(e);
    }
  }
}
