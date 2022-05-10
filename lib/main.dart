import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pingrobot/screens/initializer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:pingrobot/screens/notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AwesomeNotifications().initialize('resource://drawable/pingrobot', [
    NotificationChannel(
      channelKey: 'Key',
      channelName: 'high_priority_channel',
      channelDescription: 'High Priority Notifications',
      importance: NotificationImportance.High,
      enableLights: true,
      ledColor: Colors.white,
      playSound: true,
      soundSource: 'resource://raw/cheerful',
      enableVibration: true,
    )
  ]);
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PingRobot',
      debugShowCheckedModeBanner: false,
      home: MyAppInit(),
      scrollBehavior: MyBehavior(),
    );
  }
}

class MyAppInit extends StatefulWidget {
  const MyAppInit({Key? key}) : super(key: key);

  @override
  State<MyAppInit> createState() => _MyAppInitState();
}

class _MyAppInitState extends State<MyAppInit> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        await AwesomeNotifications().createNotification(
            content: NotificationContent(
          id: message.notification.hashCode,
          channelKey: 'Key',
          title: message.notification!.title,
          body: message.notification!.body,
        ));
      }
    });

    AwesomeNotifications().actionStream.listen((event) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Notifications()),
        (route) => route.isFirst,
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Notifications()),
          (route) => route.isFirst,
        );
      }
    });
  }

  @override
  void dispose() {
    AwesomeNotifications().actionSink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Initializer(),
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
