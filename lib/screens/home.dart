import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:pingrobot/screens/notifications.dart';
import 'package:pingrobot/theme/colors.dart';

import '../util/urls.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: CustomColors.lightGreyScaffold,
        appBar: AppBar(
          backgroundColor: CustomColors.primaryColor,
          automaticallyImplyLeading: false,
          title: Text('PingRobot'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const Notifications()));
                },
                icon: Badge(
                  showBadge: true,
                  position: BadgePosition.topEnd(top: 1, end: 1),
                  child: Icon(
                    Icons.notifications,
                    color: CustomColors.white,
                  ),
                )),
            IconButton(
                onPressed: () {
                  showModalBottomSheet(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                        top: Radius.circular(5),
                      )),
                      context: context,
                      builder: (BuildContext context) {
                        return FractionallySizedBox(
                            heightFactor: 0.4, child: SizedBox());
                      },
                      isScrollControlled: true);
                },
                icon: Icon(
                  Icons.more_vert,
                  color: CustomColors.white,
                ))
          ],
        ),
        body: SafeArea(child: _urlList()),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (BuildContext context, dialogSetState) =>
                      AlertDialog(
                    title: Text(
                      'Create Domain',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CustomColors.black),
                      textAlign: TextAlign.center,
                    ),
                    content: SizedBox(
                      height: 200,
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: CustomColors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          //send data to the db
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            width: 200,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(milliseconds: 1500),
                            content: Text(
                              'Domain Successfully Created',
                              textAlign: TextAlign.center,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ));
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Save',
                          style: TextStyle(color: CustomColors.primaryColor),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          child: Icon(Icons.add),
          backgroundColor: CustomColors.primaryColor,
        ),
      ),
    );
  }

  Widget _urlList() {
    return ListView.builder(
      itemCount: urls.length,
      itemBuilder: (context, index) {
        Map url = urls[index];
        return Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(left: 10.0, top: 15.0, bottom: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${url['name']}',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      '${url['url']}',
                      style: TextStyle(color: CustomColors.grey),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                      onPressed: () => showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (BuildContext context, dialogSetState) =>
                                  AlertDialog(
                                title: Text(
                                  'Edit Domain',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: CustomColors.black),
                                  textAlign: TextAlign.center,
                                ),
                                content: SizedBox(
                                  height: 200,
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      'Cancel',
                                      style:
                                          TextStyle(color: CustomColors.grey),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      //send data to the db

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        width: 200,
                                        behavior: SnackBarBehavior.floating,
                                        duration:
                                            const Duration(milliseconds: 1500),
                                        content: Text(
                                          'Domain Successfully Edited',
                                          textAlign: TextAlign.center,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                      ));
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Save',
                                      style: TextStyle(
                                          color: CustomColors.primaryColor),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      icon: Icon(
                        Icons.edit,
                        color: CustomColors.grey,
                      )),
                  IconButton(
                      onPressed: () => showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (BuildContext context, dialogSetState) =>
                                  AlertDialog(
                                content: Text(
                                  'Are you sure you want to delete this domain?',
                                  textAlign: TextAlign.center,
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      'Cancel',
                                      style:
                                          TextStyle(color: CustomColors.grey),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      //send data to the db
                                      setState(() {
                                        urls.removeAt(index);
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        width: 200,
                                        behavior: SnackBarBehavior.floating,
                                        duration:
                                            const Duration(milliseconds: 1500),
                                        content: Text(
                                          'Domain Successfully Deleted',
                                          textAlign: TextAlign.center,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                      ));
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Yes',
                                      style: TextStyle(
                                          color: CustomColors.primaryColor),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      icon: Icon(
                        Icons.delete_forever,
                        color: CustomColors.red,
                      )),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
