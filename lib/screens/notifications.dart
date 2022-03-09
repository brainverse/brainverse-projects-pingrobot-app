import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pingrobot/theme/colors.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  // final List unread = [];
  // final List read = [];

  late final userNotificationsRef;

  @override
  void initState() {
    super.initState();
    final database = FirebaseDatabase.instance.ref();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    userNotificationsRef = database.child('userNotifications/$userId');
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
        child:
            //  read.isEmpty && unread.isEmpty
            //     ? Center(
            //         child: Padding(
            //           padding: const EdgeInsets.symmetric(horizontal: 20.0),
            //           child: Column(
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: [
            //               Icon(
            //                 Icons.notifications_none_outlined,
            //                 size: 55,
            //                 color: CustomColors.grey,
            //               ),
            //               const SizedBox(
            //                 height: 5,
            //               ),
            //               Text(
            //                 'You\'ve got nothing here.',
            //                 style: TextStyle(
            //                     fontWeight: FontWeight.w800,
            //                     fontSize: 22,
            //                     color: CustomColors.black),
            //               ),
            //               const SizedBox(
            //                 height: 5,
            //               ),
            //               Text(
            //                 'Notifications will appear here once you have some.',
            //                 textAlign: TextAlign.center,
            //                 style: TextStyle(
            //                   color: CustomColors.grey,
            //                   fontSize: 16,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       )
            //     :
            Column(
          children: [
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
                    Expanded(child: _unreadList())
                  ],
                ),
              ),
            ),
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
                    Expanded(child: _readList()),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }

  Widget _unreadList() {
    return StreamBuilder(
        stream: userNotificationsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              (snapshot.data! as DatabaseEvent).snapshot.value != null) {
            final unread = [];
            final mapOfUrls =
                (snapshot.data! as DatabaseEvent).snapshot.value as Map;
            mapOfUrls.forEach((key, value) {
              final nextUnread = Map.from(value);
              if (nextUnread['read'] == false) {
                nextUnread['id'] = key;
                unread.add(nextUnread);
              }
            });
            if (unread.isEmpty) {
              return _nothingHere('Unread');
            } else {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: unread.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                      key: Key(unread[index]['id'].toString()),
                      onDismissed: (direction) {
                        userNotificationsRef
                            .child('${unread[index]['id']}')
                            .remove();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Notification Deleted')));
                      },
                      background: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.delete,
                              color: CustomColors.black,
                            ),
                            SizedBox(
                              width: 150,
                            ),
                            Icon(
                              Icons.delete,
                              color: CustomColors.black,
                            ),
                          ],
                        ),
                        color: CustomColors.red,
                      ),
                      child: ListTile(
                        leading: IconButton(
                          icon: Icon(Icons.dns),
                          color: CustomColors.red,
                          onPressed: () {
                            userNotificationsRef
                                .child('${unread[index]['id']}')
                                .update({"read": true});
                          },
                        ),
                        title: Text('${unread[index]['title']}'),
                        subtitle: Text('${unread[index]['subtitle']}'),
                        trailing: Text(
                            '${DateFormat('dd/MM/yyyy, HH:mm').format(DateTime.fromMillisecondsSinceEpoch(unread[index]['timestamp']))}'),
                      ));
                },
              );
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: CustomColors.primaryColor,
            ));
          } else {
            return _nothingHere('Unread');
          }
        });
  }

  Widget _readList() {
    return StreamBuilder(
        stream: userNotificationsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              (snapshot.data! as DatabaseEvent).snapshot.value != null) {
            final read = [];
            final mapOfUrls =
                (snapshot.data! as DatabaseEvent).snapshot.value as Map;
            mapOfUrls.forEach((key, value) {
              final nextRead = Map.from(value);
              if (nextRead['read'] == true) {
                nextRead['id'] = key;
                read.add(nextRead);
              }
            });
            if (read.isEmpty) {
              return _nothingHere('Read');
            } else {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: read.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                      key: Key(read[index]['id'].toString()),
                      onDismissed: (direction) {
                        userNotificationsRef
                            .child('${read[index]['id']}')
                            .remove();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Notification Deleted')));
                      },
                      background: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.delete,
                              color: CustomColors.black,
                            ),
                            SizedBox(
                              width: 150,
                            ),
                            Icon(
                              Icons.delete,
                              color: CustomColors.black,
                            ),
                          ],
                        ),
                        color: CustomColors.red,
                      ),
                      child: ListTile(
                        leading: Icon(Icons.dns),
                        title: Text('${read[index]['title']}'),
                        subtitle: Text('${read[index]['subtitle']}'),
                        trailing: Text(
                            '${DateFormat('dd/MM/yyyy, HH:mm').format(DateTime.fromMillisecondsSinceEpoch(read[index]['timestamp']))}'),
                      ));
                },
              );
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: CustomColors.primaryColor,
            ));
          } else {
            return _nothingHere('Read');
          }
        });
  }

  Widget _nothingHere(String type) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 48,
              color: CustomColors.grey,
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              'You\'ve got nothing here.',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: CustomColors.black),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              '$type Notifications will appear here once you have some.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CustomColors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
