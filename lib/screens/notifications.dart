// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:pingrobot/theme/colors.dart';

// class Notifications extends StatefulWidget {
//   const Notifications({Key? key}) : super(key: key);

//   @override
//   State<Notifications> createState() => _NotificationsState();
// }

// class _NotificationsState extends State<Notifications> {
//   // final List unread = [];
//   // final List read = [];

//   late final userNotificationsRef;

//   @override
//   void initState() {
//     super.initState();
//     final database = FirebaseDatabase.instance.ref();
//     final userId = FirebaseAuth.instance.currentUser!.uid;
//     userNotificationsRef = database.child('userNotifications/$userId');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//         child: Scaffold(
//       appBar: AppBar(
//         title: Text('Notifications'),
//         backgroundColor: CustomColors.primaryColor,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
//         child:
//             //  read.isEmpty && unread.isEmpty
//             //     ? Center(
//             //         child: Padding(
//             //           padding: const EdgeInsets.symmetric(horizontal: 20.0),
//             //           child: Column(
//             //             mainAxisAlignment: MainAxisAlignment.center,
//             //             children: [
//             //               Icon(
//             //                 Icons.notifications_none_outlined,
//             //                 size: 55,
//             //                 color: CustomColors.grey,
//             //               ),
//             //               const SizedBox(
//             //                 height: 5,
//             //               ),
//             //               Text(
//             //                 'You\'ve got nothing here.',
//             //                 style: TextStyle(
//             //                     fontWeight: FontWeight.w800,
//             //                     fontSize: 22,
//             //                     color: CustomColors.black),
//             //               ),
//             //               const SizedBox(
//             //                 height: 5,
//             //               ),
//             //               Text(
//             //                 'Notifications will appear here once you have some.',
//             //                 textAlign: TextAlign.center,
//             //                 style: TextStyle(
//             //                   color: CustomColors.grey,
//             //                   fontSize: 16,
//             //                 ),
//             //               ),
//             //             ],
//             //           ),
//             //         ),
//             //       )
//             //     :
//             Column(
//           children: [
//             Expanded(
//               child: Card(
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(
//                           top: 8.0, left: 8.0, bottom: 8.0),
//                       child: Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           'Unread',
//                           style: TextStyle(
//                               fontWeight: FontWeight.w800, fontSize: 16),
//                         ),
//                       ),
//                     ),
//                     Expanded(child: _unreadList())
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(
//               height: 15,
//             ),
//             Expanded(
//               child: Card(
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(
//                           top: 8.0, left: 8.0, bottom: 8.0),
//                       child: Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           'Read',
//                           style: TextStyle(
//                               fontWeight: FontWeight.w800, fontSize: 16),
//                         ),
//                       ),
//                     ),
//                     Expanded(child: _readList()),
//                   ],
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     ));
//   }

//   Widget _unreadList() {
//     return StreamBuilder(
//         stream: userNotificationsRef.onValue,
//         builder: (context, snapshot) {
//           if (snapshot.hasData &&
//               (snapshot.data! as DatabaseEvent).snapshot.value != null) {
//             final unread = [];
//             final mapOfUrls =
//                 (snapshot.data! as DatabaseEvent).snapshot.value as Map;
//             mapOfUrls.forEach((key, value) {
//               final nextUnread = Map.from(value);
//               if (nextUnread['read'] == false) {
//                 nextUnread['id'] = key;
//                 unread.add(nextUnread);
//               }
//             });
//             if (unread.isEmpty) {
//               return _nothingHere('Unread');
//             } else {
//               unread.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
//               return ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: unread.length,
//                 itemBuilder: (context, index) {
//                   return Dismissible(
//                       key: Key(unread[index]['id'].toString()),
//                       onDismissed: (direction) {
//                         userNotificationsRef
//                             .child('${unread[index]['id']}')
//                             .remove();
//                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                           width: 200,
//                           behavior: SnackBarBehavior.floating,
//                           duration: const Duration(milliseconds: 1500),
//                           content: Text(
//                             'Notification Deleted',
//                             textAlign: TextAlign.center,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15.0),
//                           ),
//                         ));
//                       },
//                       background: Container(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             Icon(
//                               Icons.delete,
//                               color: CustomColors.black,
//                             ),
//                             SizedBox(
//                               width: 150,
//                             ),
//                             Icon(
//                               Icons.delete,
//                               color: CustomColors.black,
//                             ),
//                           ],
//                         ),
//                         color: CustomColors.red,
//                       ),
//                       child: ListTile(
//                         leading: IconButton(
//                           icon: Icon(Icons.dns),
//                           color: CustomColors.red,
//                           onPressed: () {
//                             userNotificationsRef
//                                 .child('${unread[index]['id']}')
//                                 .update({"read": true});
//                           },
//                         ),
//                         title: Text('${unread[index]['title']}'),
//                         subtitle: Text('${unread[index]['subtitle']}'),
//                         trailing: Text(
//                             '${DateFormat('dd/MM/yyyy, HH:mm').format(DateTime.fromMillisecondsSinceEpoch(unread[index]['timestamp']))}'),
//                       ));
//                 },
//               );
//             }
//           } else if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//                 child: CircularProgressIndicator(
//               color: CustomColors.primaryColor,
//             ));
//           } else {
//             return _nothingHere('Unread');
//           }
//         });
//   }

//   Widget _readList() {
//     return StreamBuilder(
//         stream: userNotificationsRef.onValue,
//         builder: (context, snapshot) {
//           if (snapshot.hasData &&
//               (snapshot.data! as DatabaseEvent).snapshot.value != null) {
//             final read = [];
//             final mapOfUrls =
//                 (snapshot.data! as DatabaseEvent).snapshot.value as Map;
//             mapOfUrls.forEach((key, value) {
//               final nextRead = Map.from(value);
//               if (nextRead['read'] == true) {
//                 nextRead['id'] = key;
//                 read.add(nextRead);
//               }
//             });
//             if (read.isEmpty) {
//               return _nothingHere('Read');
//             } else {
//               read.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
//               return ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: read.length,
//                 itemBuilder: (context, index) {
//                   return Dismissible(
//                       key: Key(read[index]['id'].toString()),
//                       onDismissed: (direction) {
//                         userNotificationsRef
//                             .child('${read[index]['id']}')
//                             .remove();
//                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                           width: 200,
//                           behavior: SnackBarBehavior.floating,
//                           duration: const Duration(milliseconds: 1500),
//                           content: Text(
//                             'Notification Deleted',
//                             textAlign: TextAlign.center,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15.0),
//                           ),
//                         ));
//                       },
//                       background: Container(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             Icon(
//                               Icons.delete,
//                               color: CustomColors.black,
//                             ),
//                             SizedBox(
//                               width: 150,
//                             ),
//                             Icon(
//                               Icons.delete,
//                               color: CustomColors.black,
//                             ),
//                           ],
//                         ),
//                         color: CustomColors.red,
//                       ),
//                       child: ListTile(
//                         leading: Icon(Icons.dns),
//                         title: Text('${read[index]['title']}'),
//                         subtitle: Text('${read[index]['subtitle']}'),
//                         trailing: Text(
//                             '${DateFormat('dd/MM/yyyy, HH:mm').format(DateTime.fromMillisecondsSinceEpoch(read[index]['timestamp']))}'),
//                       ));
//                 },
//               );
//             }
//           } else if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//                 child: CircularProgressIndicator(
//               color: CustomColors.primaryColor,
//             ));
//           } else {
//             return _nothingHere('Read');
//           }
//         });
//   }

//   Widget _nothingHere(String type) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.notifications_none_outlined,
//               size: 48,
//               color: CustomColors.grey,
//             ),
//             const SizedBox(
//               height: 5,
//             ),
//             Text(
//               'You\'ve got nothing here.',
//               style: TextStyle(
//                   fontWeight: FontWeight.w800,
//                   fontSize: 18,
//                   color: CustomColors.black),
//             ),
//             const SizedBox(
//               height: 5,
//             ),
//             Text(
//               '$type Notifications will appear here once you have some.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: CustomColors.grey,
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pingrobot/screens/about.dart';
import 'package:pingrobot/screens/home.dart';
import 'package:pingrobot/screens/signin.dart';
import 'package:pingrobot/services/google_signin.dart';
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
              // IconButton(
              //     onPressed: () {
              //       Navigator.of(context).push(MaterialPageRoute(
              //           builder: (context) => const Notifications()));
              //     },
              //     icon: Badge(
              //       showBadge: true,
              //       position: BadgePosition.topEnd(top: 1, end: 1),
              //       child: Icon(
              //         Icons.notifications,
              //         color: CustomColors.black,
              //         size: 25,
              //       ),
              //     )),
              SizedBox(
                width: 10,
              ),
              PopupMenuButton(
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                      FirebaseAuth.instance.currentUser!.photoURL ?? ''),
                ),
                onSelected: (result) {
                  if (result == 'Signout') {
                    GoogleSigninService googleSigninService =
                        GoogleSigninService();
                    googleSigninService.googleSignout().whenComplete(() =>
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const Signin()),
                            (Route<dynamic> route) => false));
                  } else if (result == 'About') {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const About()));
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                  const PopupMenuItem(
                    value: 'About',
                    child: ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('About'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'Signout',
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Signout'),
                    ),
                  ),
                ],
              ),
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
                    // Icon(
                    //   Icons.circle,
                    //   size: 16,
                    //   color: CustomColors.green,
                    // ),
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
                    // IconButton(
                    //   onPressed: () {
                    //     websiteNameController.text = widget.property['name'];
                    //     websiteUrlController.text = widget.property['url'];
                    //     showModalBottomSheet(
                    //         shape: const RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.vertical(
                    //           top: Radius.circular(50),
                    //         )),
                    //         backgroundColor: CustomColors.primaryColor,
                    //         context: context,
                    //         builder: (BuildContext context) {
                    //           return FractionallySizedBox(
                    //               heightFactor: 0.85, child: _editProperty());
                    //         },
                    //         isScrollControlled: true);
                    //   },
                    //   icon: Icon(
                    //     Icons.edit,
                    //     size: 28,
                    //     color: CustomColors.white,
                    //   ),
                    // ),
                    // SizedBox(
                    //   width: 5,
                    // ),
                    // IconButton(
                    //   onPressed: () => showDialog(
                    //       context: context,
                    //       builder: (context) {
                    //         return StatefulBuilder(
                    //           builder: (BuildContext context, dialogSetState) =>
                    //               AlertDialog(
                    //             content: Text(
                    //               'Are you sure you want to delete this property?',
                    //               textAlign: TextAlign.center,
                    //             ),
                    //             actions: <Widget>[
                    //               TextButton(
                    //                 onPressed: () => Navigator.pop(context),
                    //                 child: Text(
                    //                   'Cancel',
                    //                   style:
                    //                       TextStyle(color: CustomColors.grey),
                    //                 ),
                    //               ),
                    //               TextButton(
                    //                 onPressed: () async {
                    //                   //send data to the db
                    //                   try {
                    //                     await userUrlsRef
                    //                         .child(widget.property['id'])
                    //                         .remove();
                    //                     ScaffoldMessenger.of(context)
                    //                         .showSnackBar(SnackBar(
                    //                       width: 200,
                    //                       behavior: SnackBarBehavior.floating,
                    //                       duration: const Duration(
                    //                           milliseconds: 1500),
                    //                       content: Text(
                    //                         'Property Successfully Deleted',
                    //                         textAlign: TextAlign.center,
                    //                       ),
                    //                       shape: RoundedRectangleBorder(
                    //                         borderRadius:
                    //                             BorderRadius.circular(15.0),
                    //                       ),
                    //                     ));
                    //                     Navigator.pop(context);
                    //                     Navigator.of(context)
                    //                         .pushAndRemoveUntil(
                    //                             MaterialPageRoute(
                    //                                 builder: (context) =>
                    //                                     const Home()),
                    //                             (Route<dynamic> route) =>
                    //                                 false);
                    //                   } catch (e) {
                    //                     ScaffoldMessenger.of(context)
                    //                         .showSnackBar(SnackBar(
                    //                       width: 200,
                    //                       behavior: SnackBarBehavior.floating,
                    //                       duration: const Duration(
                    //                           milliseconds: 1500),
                    //                       content: Text(
                    //                         '$e',
                    //                         textAlign: TextAlign.center,
                    //                       ),
                    //                       shape: RoundedRectangleBorder(
                    //                         borderRadius:
                    //                             BorderRadius.circular(15.0),
                    //                       ),
                    //                     ));
                    //                     Navigator.pop(context);
                    //                   }
                    //                 },
                    //                 child: Text(
                    //                   'Yes',
                    //                   style: TextStyle(
                    //                       color: CustomColors.primaryColor),
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         );
                    //       }),
                    //   icon: Icon(
                    //     Icons.delete_forever,
                    //     size: 28,
                    //     color: CustomColors.white,
                    //   ),
                    // ),
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
              // if (nextUnread['title'] == widget.property['name']) {
              //   nextUnread['id'] = key;
              //   unread.add(nextUnread);
              // }

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

  _userName() {
    return FirebaseAuth.instance.currentUser!.displayName!.split(" ")[0];
  }
}
