import 'package:badges/badges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pingrobot/screens/about.dart';
import 'package:pingrobot/screens/notifications.dart';
import 'package:pingrobot/screens/signin.dart';
import 'package:pingrobot/services/google_signin.dart';
import 'package:pingrobot/theme/colors.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final formKey = GlobalKey<FormState>();
  final formKeyEdit = GlobalKey<FormState>();
  TextEditingController websiteNameController = TextEditingController();
  TextEditingController websiteUrlController = TextEditingController();
  String websiteName = '';
  String websiteUrl = '';
  late final userUrlsRef;
  late final database;
  late final userId;

  @override
  void initState() {
    super.initState();
    database = FirebaseDatabase.instance.ref();
    userId = FirebaseAuth.instance.currentUser!.uid;
    userUrlsRef = database.child('userUrls/$userId');
    _saveDeviceToken();
  }

  @override
  void dispose() {
    websiteNameController.dispose();
    websiteUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          PopupMenuButton(
            // offset: ,
            onSelected: (result) {
              if (result == 'Signout') {
                GoogleSigninService googleSigninService = GoogleSigninService();
                googleSigninService.googleSignout().whenComplete(() =>
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const Signin()),
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
              // const PopupMenuItem(
              //   value: 'Help',
              //   child: ListTile(
              //     leading: Icon(Icons.question_mark),
              //     title: Text('Help'),
              //   ),
              // ),
              const PopupMenuItem(
                value: 'Signout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Signout'),
                ),
              ),
            ],
          )
        ],
      ),
      body: SafeArea(child: _urlList()),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (BuildContext context, dialogSetState) => AlertDialog(
                  title: Text(
                    'Create Domain',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CustomColors.black),
                    textAlign: TextAlign.center,
                  ),
                  content: SingleChildScrollView(
                    child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Website Name is required";
                                } else {
                                  return null;
                                }
                              },
                              onSaved: (String? value) {
                                websiteName = value!;
                              },
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xffF0F0F0),
                                label: RichText(
                                    text: const TextSpan(children: [
                                  TextSpan(
                                      text: 'Website Name',
                                      style: TextStyle(
                                          color: Color(0xff606060),
                                          fontFamily: 'Arial Rounded',
                                          fontSize: 14)),
                                  TextSpan(
                                      text: ' *',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontFamily: 'Arial Rounded'))
                                ])),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.black12),
                                    borderRadius: BorderRadius.circular(10)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black12),
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Website Url/Ip is required";
                                } else {
                                  // domain ip check
                                  RegExp ipExp = new RegExp(
                                      r"^(?!0)(?!.*\.$)((1?\d?\d|25[0-5]|2[0-4]\d)(\.|$)){4}$",
                                      caseSensitive: false,
                                      multiLine: false);
                                  RegExp domainExp = RegExp(
                                      r"^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}$");
                                  RegExp urlExp = RegExp(
                                      r"(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?");
                                  if (ipExp.hasMatch(value) ||
                                      domainExp.hasMatch(value) ||
                                      urlExp.hasMatch(value)) {
                                    return null;
                                  } else {
                                    return "Invalid webisite Url/Ip";
                                  }
                                }
                              },
                              onSaved: (String? value) {
                                websiteUrl = value!;
                              },
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xffF0F0F0),
                                label: RichText(
                                    text: const TextSpan(children: [
                                  TextSpan(
                                      text: 'Website Url/Ip',
                                      style: TextStyle(
                                          color: Color(0xff606060),
                                          fontFamily: 'Arial Rounded',
                                          fontSize: 14)),
                                  TextSpan(
                                      text: ' *',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontFamily: 'Arial Rounded'))
                                ])),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.black12),
                                    borderRadius: BorderRadius.circular(10)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.black12),
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        )),
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
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          //send data to the db
                          try {
                            await userUrlsRef.push().set({
                              'name': websiteName,
                              'url': websiteUrl,
                              'timestamp': DateTime.now().millisecondsSinceEpoch
                            });
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
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              width: 200,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(milliseconds: 1500),
                              content: Text(
                                '$e',
                                textAlign: TextAlign.center,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ));
                            Navigator.pop(context);
                          }
                        }
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
    );
  }

  Widget _urlList() {
    return StreamBuilder(
      stream: userUrlsRef.onValue,
      builder: (context, snapshot) {
        final urls = [];
        if (snapshot.hasData &&
            (snapshot.data! as DatabaseEvent).snapshot.value != null) {
          final mapOfUrls =
              (snapshot.data! as DatabaseEvent).snapshot.value as Map;
          mapOfUrls.forEach((key, value) {
            final nextUrl = Map.from(value);
            nextUrl['id'] = key;
            urls.add(nextUrl);
          });
          urls.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

          return ListView.builder(
            itemCount: urls.length,
            itemBuilder: (context, index) {
              Map url = urls[index];
              return Card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, top: 15.0, bottom: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${url['name']}',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
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
                                  websiteNameController.text = url['name'];
                                  websiteUrlController.text = url['url'];
                                  return AlertDialog(
                                    title: Text(
                                      'Edit Domain',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: CustomColors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                    content: SingleChildScrollView(
                                      child: Form(
                                          key: formKeyEdit,
                                          child: Column(
                                            children: [
                                              TextFormField(
                                                controller:
                                                    websiteNameController,
                                                autovalidateMode:
                                                    AutovalidateMode
                                                        .onUserInteraction,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return "Website Name is required";
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                onSaved: (String? value) {
                                                  websiteName = value!;
                                                },
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor:
                                                      const Color(0xffF0F0F0),
                                                  label: RichText(
                                                      text: const TextSpan(
                                                          children: [
                                                        TextSpan(
                                                            text:
                                                                'Website Name',
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xff606060),
                                                                fontFamily:
                                                                    'Arial Rounded',
                                                                fontSize: 14)),
                                                        TextSpan(
                                                            text: ' *',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontFamily:
                                                                    'Arial Rounded'))
                                                      ])),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  enabledBorder: OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              color: Colors
                                                                  .black12),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Colors
                                                                  .black12),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 12,
                                              ),
                                              TextFormField(
                                                controller:
                                                    websiteUrlController,
                                                autovalidateMode:
                                                    AutovalidateMode
                                                        .onUserInteraction,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return "Website Url/Ip is required";
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                onSaved: (String? value) {
                                                  websiteUrl = value!;
                                                },
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor:
                                                      const Color(0xffF0F0F0),
                                                  label: RichText(
                                                      text: const TextSpan(
                                                          children: [
                                                        TextSpan(
                                                            text:
                                                                'Website Url/Ip',
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xff606060),
                                                                fontFamily:
                                                                    'Arial Rounded',
                                                                fontSize: 14)),
                                                        TextSpan(
                                                            text: ' *',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontFamily:
                                                                    'Arial Rounded'))
                                                      ])),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  enabledBorder: OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              color: Colors
                                                                  .black12),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              color: Colors
                                                                  .black12),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                ),
                                              ),
                                            ],
                                          )),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                              color: CustomColors.grey),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          if (formKeyEdit.currentState!
                                              .validate()) {
                                            formKeyEdit.currentState!.save();
                                            //send data to the db
                                            try {
                                              await userUrlsRef
                                                  .child(url['id'])
                                                  .update({
                                                'name': websiteName,
                                                'url': websiteUrl,
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                width: 200,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                duration: const Duration(
                                                    milliseconds: 1500),
                                                content: Text(
                                                  'Domain Successfully Edited',
                                                  textAlign: TextAlign.center,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                              ));
                                              Navigator.pop(context);
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                width: 200,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                duration: const Duration(
                                                    milliseconds: 1500),
                                                content: Text(
                                                  '$e',
                                                  textAlign: TextAlign.center,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                              ));
                                              Navigator.pop(context);
                                            }
                                          }
                                        },
                                        child: Text(
                                          'Save',
                                          style: TextStyle(
                                              color: CustomColors.primaryColor),
                                        ),
                                      ),
                                    ],
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
                                    builder: (BuildContext context,
                                            dialogSetState) =>
                                        AlertDialog(
                                      content: Text(
                                        'Are you sure you want to delete this domain?',
                                        textAlign: TextAlign.center,
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                                color: CustomColors.grey),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            //send data to the db
                                            try {
                                              await userUrlsRef
                                                  .child(url['id'])
                                                  .remove();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                width: 200,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                duration: const Duration(
                                                    milliseconds: 1500),
                                                content: Text(
                                                  'Domain Successfully Deleted',
                                                  textAlign: TextAlign.center,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                              ));
                                              Navigator.pop(context);
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                width: 200,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                duration: const Duration(
                                                    milliseconds: 1500),
                                                content: Text(
                                                  '$e',
                                                  textAlign: TextAlign.center,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                              ));
                                              Navigator.pop(context);
                                            }
                                          },
                                          child: Text(
                                            'Yes',
                                            style: TextStyle(
                                                color:
                                                    CustomColors.primaryColor),
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
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: CustomColors.primaryColor,
          ));
        } else {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.language,
                    size: 55,
                    color: CustomColors.grey,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'You\'ve got nothing here.',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: CustomColors.black),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Looks like you haven\'t added websites yet. Add some to start monitoring.',
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
      },
    );
  }

  _saveDeviceToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      database.child('userFcmTokens/$userId').set(fcmToken);
    }
  }
}
