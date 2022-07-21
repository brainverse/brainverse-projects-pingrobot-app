import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pingrobot/components/profile_popup_menu.dart';
import 'package:pingrobot/theme/colors.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final formKey = GlobalKey<FormState>();
  final formKeyEdit = GlobalKey<FormState>();
  TextEditingController websiteNameController = TextEditingController();
  TextEditingController websiteUrlController = TextEditingController();
  String websiteName = '';
  String websiteUrl = '';
  late final userUrlsRef;
  late final database;
  late final userId;
  late final userNotificationsRef;

  @override
  void initState() {
    super.initState();
    database = FirebaseDatabase.instance.ref();
    userId = FirebaseAuth.instance.currentUser!.uid;
    userUrlsRef = database.child('userUrls/$userId');
    userNotificationsRef = database.child('userNotifications/$userId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.lightGreyScaffold,
      body: SafeArea(
          child: Column(
        children: [
          SizedBox(
            height: 25,
          ),
          Row(
            children: [
              SizedBox(
                width: 15,
              ),
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_back_ios,
                        color: CustomColors.grey,
                        size: 25,
                      ),
                      Text(
                        'Back',
                        style: TextStyle(
                            color: CustomColors.grey,
                            fontSize: 25,
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              ProfilePopupMenu(),
              SizedBox(
                width: 15,
              )
            ],
          ),
          SizedBox(
            height: 35,
          ),
          Container(
            height: MediaQuery.of(context).size.height / 6.3,
            width: MediaQuery.of(context).size.height,
            color: CustomColors.lightGreyScaffold,
            child: Material(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        'Property Status Logs',
                        style:
                            TextStyle(color: CustomColors.white, fontSize: 28),
                      ),
                    ),
                  ],
                ),
                color: CustomColors.primaryColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(50),
                )),
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.height,
              color: CustomColors.primaryColor,
              child: Material(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 25,
                      ),
                      Expanded(child: _logList())
                    ],
                  ),
                  color: CustomColors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(50),
                  )),
            ),
          )
        ],
      )),
    );
  }

  Widget _logList() {
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
              nextUnread['id'] = key;
              unread.add(nextUnread);
            });
            if (unread.isEmpty) {
              return _nothingHere();
            } else {
              unread.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
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
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          width: 200,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(milliseconds: 1500),
                          content: Text(
                            'Log Deleted',
                            textAlign: TextAlign.center,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ));
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
                        minLeadingWidth: 10,
                        leading: Icon(
                          Icons.circle,
                          size: 12,
                          color: unread[index]['status'] == 'OK'
                              ? CustomColors.green
                              : CustomColors.red,
                        ),
                        title: Text(
                          '${unread[index]['title']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
            return _nothingHere();
          }
        });
  }

  Widget _nothingHere() {
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
              'Logs will appear here once you have some.',
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
