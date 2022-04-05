import 'package:flutter/material.dart';
import 'package:pingrobot/screens/initializer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pingrobot/screens/notifications.dart';
import 'package:pingrobot/services/local_notification.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalNotificationService().initialize();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);

  // await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );
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

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null) {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const Notifications()));
        }
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      LocalNotificationService().display(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const Notifications()));
      }
    });
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
