import 'package:flutter/material.dart';
import 'package:pingrobot/theme/colors.dart';
import 'package:pingrobot/util/notifications.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final List unreadNotifications = [];

  @override
  void initState() {
    super.initState();
    for (var item in notifications) {
      if (!item['read']) {
        unreadNotifications.add(item);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: CustomColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Column(
          children: [
            if (unreadNotifications.isNotEmpty)
              Expanded(
                child: Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, left: 8.0, bottom: 8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Unread',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: unreadNotifications.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(Icons.dns),
                            title:
                                Text('${unreadNotifications[index]['title']}'),
                            subtitle: Text(
                                '${unreadNotifications[index]['message']}'),
                            trailing:
                                Text('${unreadNotifications[index]['date']}'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            if (unreadNotifications.isNotEmpty)
              const SizedBox(
                height: 15,
              ),
            Expanded(
              child: Card(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, left: 8.0, bottom: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Read',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(Icons.web),
                            title: Text('${notifications[index]['title']}'),
                            subtitle:
                                Text('${notifications[index]['message']}'),
                            trailing: Text('${notifications[index]['date']}'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }
}
