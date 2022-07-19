import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:badges/badges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pingrobot/screens/about.dart';
import 'package:pingrobot/screens/notifications.dart';
import 'package:pingrobot/screens/signin.dart';
import 'package:pingrobot/screens/single_property.dart';
import 'package:pingrobot/services/google_signin.dart';
import 'package:pingrobot/services/time_progress_formatter.dart';
import 'package:pingrobot/shared/dialogs/payment_alert.dart';
import 'package:pingrobot/theme/colors.dart';
import 'package:flutterwave/flutterwave.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final formKey = GlobalKey<FormState>();
  final formKeyEdit = GlobalKey<FormState>();
  String websiteName = '';
  String websiteUrl = '';
  String websiteDescription = '';
  var frequency = 60;
  String websiteType = 'Web App';
  late final userUrlsRef;
  late final database;
  late final userId;
  late final userPaymentRef;
  late var paymentSnapshot;
  late var urlsSnapshot;
  String unlockFeatures = 'Let\'s unlock every feature';
  String moreThanThree =
      'You need a paid plan to monitor more than 3 properties. Please upgrade to continue';
  String paidFrequency =
      'You need a paid plan to monitor at this frequecy. Please upgrade to continue';

  @override
  void initState() {
    super.initState();
    AwesomeNotifications().isNotificationAllowed().then((value) {
      if (value == false) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(
                    'Allow Notifications',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CustomColors.black),
                    textAlign: TextAlign.center,
                  ),
                  content: Text(
                    'Our app would like to send you notifications',
                    textAlign: TextAlign.center,
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Don\'t Allow',
                        style: TextStyle(color: CustomColors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        AwesomeNotifications()
                            .requestPermissionToSendNotifications()
                            .then((_) => Navigator.pop(context));
                      },
                      child: Text(
                        'Allow',
                        style: TextStyle(color: CustomColors.primaryColor),
                      ),
                    ),
                  ],
                ));
      }
    });

    database = FirebaseDatabase.instance.ref();
    userId = FirebaseAuth.instance.currentUser!.uid;
    userUrlsRef = database.child('userUrls/$userId');
    userPaymentRef = database.child('userPayments/$userId');
    _fetchPaymentState();

    Future.delayed(Duration(milliseconds: 700), () {
      if (!paymentSnapshot.exists) {
        WidgetsBinding.instance!
            .addPostFrameCallback((_) => _paymentAlert(unlockFeatures));
      } else {
        if (DateTime.now().isAfter(DateTime.fromMillisecondsSinceEpoch(
            paymentSnapshot.value['expires']))) {
          WidgetsBinding.instance!
              .addPostFrameCallback((_) => _paymentAlert(unlockFeatures));
        }
      }
    });
    _saveDeviceToken();
  }

  _fetchPaymentState() async {
    paymentSnapshot = await userPaymentRef.get();
  }

  @override
  void dispose() {
    AwesomeNotifications().actionSink.close();
    super.dispose();
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
                child: RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: 'Hi ',
                      style:
                          TextStyle(color: CustomColors.black, fontSize: 21)),
                  TextSpan(
                      text: _userName(),
                      style: TextStyle(
                          color: CustomColors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 21)),
                ])),
              ),
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
                      color: CustomColors.black,
                      size: 25,
                    ),
                  )),
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
            height: MediaQuery.of(context).size.height / 4.7,
            width: MediaQuery.of(context).size.height,
            color: CustomColors.lightGreyScaffold,
            child: Material(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 45.0, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Properties',
                            style: TextStyle(
                                color: CustomColors.white, fontSize: 20),
                          ),
                          IconButton(
                              onPressed: () async {
                                urlsSnapshot = await userUrlsRef.get();
                                if (paymentSnapshot.exists) {
                                  //check if expired. if yes - FREE
                                  if (DateTime.now().isAfter(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          paymentSnapshot.value['expires']))) {
                                    //FREE
                                    if (urlsSnapshot.exists) {
                                      if (urlsSnapshot.value.length < 3) {
                                        //showbottomsheet
                                        _addPropertyBottomSheet();
                                      } else {
                                        _paymentAlert(moreThanThree);
                                      }
                                    } else {
                                      //showbottomsheet
                                      _addPropertyBottomSheet();
                                    }
                                  } else {
                                    //else check type and assign url # conditions appropriately
                                    if (paymentSnapshot.value['type'] ==
                                        'PREMIUM') {
                                      if (urlsSnapshot.exists) {
                                        if (urlsSnapshot.value.length < 10) {
                                          //showbottomsheet
                                          _addPropertyBottomSheet();
                                        } else {
                                          _paymentAlert(
                                              'You need an AGENCY plan to monitor more than 10 properties. Please upgrade to continue');
                                        }
                                      } else {
                                        //showbottomsheet
                                        _addPropertyBottomSheet();
                                      }
                                    } else {
                                      if (urlsSnapshot.exists) {
                                        if (urlsSnapshot.value.length < 50) {
                                          //showbottomsheet
                                          _addPropertyBottomSheet();
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            width: 200,
                                            behavior: SnackBarBehavior.floating,
                                            duration: const Duration(
                                                milliseconds: 1500),
                                            content: Text(
                                              'You have exceeded the limit on number of properties',
                                              textAlign: TextAlign.center,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                          ));
                                        }
                                      } else {
                                        //showbottomsheet
                                        _addPropertyBottomSheet();
                                      }
                                    }
                                  }
                                } else {
                                  //FREE
                                  if (urlsSnapshot.exists) {
                                    if (urlsSnapshot.value.length < 3) {
                                      //showbottomsheet
                                      _addPropertyBottomSheet();
                                    } else {
                                      _paymentAlert(moreThanThree);
                                    }
                                  } else {
                                    //showbottomsheet
                                    _addPropertyBottomSheet();
                                  }
                                }
                              },
                              icon: Icon(
                                Icons.add_circle,
                                size: 40,
                                color: CustomColors.white,
                              ))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    _urlStatusByNumber()
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
                      Expanded(child: _urlList())
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
              return Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height / 20,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                            child: Image.asset(
                              'assets/images/laptop_on_desk.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, top: 15.0, bottom: 15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${url['name']}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(
                                    Icons.circle,
                                    size: 12,
                                    color: url['live']
                                        ? CustomColors.green
                                        : CustomColors.red,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              url['statusTimestamp'] == null
                                  ? Text(
                                      '${url['url']}',
                                      style:
                                          TextStyle(color: CustomColors.grey),
                                    )
                                  : RichText(
                                      text: TextSpan(children: [
                                      TextSpan(
                                        text: url['live']
                                            ? 'Online since '
                                            : 'Offline since ',
                                        style: TextStyle(
                                            color: CustomColors.grey,
                                            fontSize: 13),
                                      ),
                                      TextSpan(
                                        text:
                                            formatTime(url['statusTimestamp']),
                                        style: TextStyle(
                                            color: CustomColors.black,
                                            fontSize: 13),
                                      ),
                                    ]))
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          SingleProperty(property: url)));
                                },
                                icon: Icon(
                                  Icons.navigate_next,
                                  color: CustomColors.navigateNextGrey,
                                  size: 36,
                                )),
                          ),
                        ],
                      )
                    ],
                  ),
                  Divider(
                    color: CustomColors.dividerGrey,
                    endIndent: 25,
                    indent: 25,
                  )
                ],
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

  Widget _urlStatusByNumber() {
    return StreamBuilder(
      stream: userUrlsRef.onValue,
      builder: (context, snapshot) {
        final onlineUrls = [];
        final offlineUrls = [];

        if (snapshot.hasData &&
            (snapshot.data! as DatabaseEvent).snapshot.value != null) {
          final mapOfUrls =
              (snapshot.data! as DatabaseEvent).snapshot.value as Map;
          mapOfUrls.forEach((key, value) {
            final nextUrl = Map.from(value);
            if (nextUrl['live'] == true) {
              onlineUrls.add(nextUrl);
            } else {
              offlineUrls.add(nextUrl);
            }
          });

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    '${onlineUrls.length}',
                    style: TextStyle(
                        color: CustomColors.white,
                        fontSize: 45,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 16,
                        color: CustomColors.green,
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      Text(
                        'Online',
                        style:
                            TextStyle(color: CustomColors.white, fontSize: 18),
                      )
                    ],
                  )
                ],
              ),
              Column(
                children: [
                  Text(
                    '${offlineUrls.length}',
                    style: TextStyle(
                        color: CustomColors.white,
                        fontSize: 45,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 16,
                        color: CustomColors.red,
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      Text(
                        'Offline',
                        style:
                            TextStyle(color: CustomColors.white, fontSize: 18),
                      )
                    ],
                  )
                ],
              )
            ],
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: CustomColors.primaryColor,
          ));
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    '0',
                    style: TextStyle(
                        color: CustomColors.white,
                        fontSize: 45,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 16,
                        color: CustomColors.green,
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      Text(
                        'Online',
                        style:
                            TextStyle(color: CustomColors.white, fontSize: 18),
                      )
                    ],
                  )
                ],
              ),
              Column(
                children: [
                  Text(
                    '0',
                    style: TextStyle(
                        color: CustomColors.white,
                        fontSize: 45,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 16,
                        color: CustomColors.red,
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      Text(
                        'Offline',
                        style:
                            TextStyle(color: CustomColors.white, fontSize: 18),
                      )
                    ],
                  )
                ],
              )
            ],
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

  _userName() {
    return FirebaseAuth.instance.currentUser!.displayName!.split(" ")[0];
  }

  _userEmail() {
    return FirebaseAuth.instance.currentUser!.email;
  }

  _addPropertyBottomSheet() async {
    // the next operation is performed here incase user made payment on launch dialog
    paymentSnapshot = await userPaymentRef.get();
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
          top: Radius.circular(50),
        )),
        backgroundColor: CustomColors.primaryColor,
        context: context,
        builder: (BuildContext context) {
          return FractionallySizedBox(
              heightFactor: 0.85, child: _addProperty());
        },
        isScrollControlled: true);
  }

  _addProperty() {
    return StatefulBuilder(
      builder: (BuildContext context, dialogSetState) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                'Add Property',
                style: TextStyle(color: CustomColors.white, fontSize: 28),
              ),
            ),
            SingleChildScrollView(
              child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 6.0, left: 11),
                          child: Text(
                            'Property Name *',
                            style: TextStyle(color: CustomColors.white),
                          ),
                        ),
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Property Name is required";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (String? value) {
                          websiteName = value!;
                        },
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CustomColors.primaryColor),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xffF0F0F0),
                          hintText: 'Enter Property Name',
                          hintStyle: TextStyle(
                              color: CustomColors.primaryColor, fontSize: 18),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50)),
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(50)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(50)),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 6.0, left: 11),
                          child: Text(
                            'Property Url  *',
                            style: TextStyle(color: CustomColors.white),
                          ),
                        ),
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Property Url is required";
                          } else {
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
                              return "Invalid Property Url";
                            }
                          }
                        },
                        onSaved: (String? value) {
                          websiteUrl = value!;
                        },
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CustomColors.primaryColor),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xffF0F0F0),
                          hintText: 'Enter Property Url',
                          hintStyle: TextStyle(
                              color: CustomColors.primaryColor, fontSize: 18),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50)),
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(50)),
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(50)),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 6.0, left: 11),
                          child: Text(
                            'Property Description',
                            style: TextStyle(color: CustomColors.white),
                          ),
                        ),
                      ),
                      TextFormField(
                        onSaved: (String? value) {
                          websiteDescription = value!;
                        },
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CustomColors.primaryColor),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xffF0F0F0),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          hintText: 'Enter Property Description',
                          hintStyle: TextStyle(
                              color: CustomColors.primaryColor, fontSize: 18),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50)),
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(50)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(50)),
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 6.0, left: 11),
                          child: Text(
                            'Property Type',
                            style: TextStyle(color: CustomColors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 56,
                        child: DropdownButtonFormField(
                          icon: Icon(Icons.expand_more),
                          dropdownColor: const Color(0xffF0F0F0),
                          value: websiteType,
                          items: [
                            DropdownMenuItem(
                              child: Text(
                                'Wordpress Site',
                                style: TextStyle(color: Colors.black),
                              ),
                              value: 'Wordpress Site',
                            ),
                            DropdownMenuItem(
                              child: Text(
                                'Web App',
                                style: TextStyle(color: Colors.black),
                              ),
                              value: 'Web App',
                            ),
                            DropdownMenuItem(
                              child: Text(
                                'API Endpoint',
                                style: TextStyle(color: Colors.black),
                              ),
                              value: 'API Endpoint',
                            )
                          ],
                          onSaved: (String? value) {
                            websiteType = value!;
                          },
                          onChanged: (String? value) {
                            websiteType = value!;
                          },
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: CustomColors.primaryColor),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xffF0F0F0),
                            hintText: 'Select Property Type',
                            hintStyle: TextStyle(
                                color: CustomColors.primaryColor, fontSize: 18),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50)),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black12),
                                borderRadius: BorderRadius.circular(50)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black12),
                                borderRadius: BorderRadius.circular(50)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 6.0, left: 11),
                          child: Text(
                            'Frequency',
                            style: TextStyle(color: CustomColors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 56,
                        child: DropdownButtonFormField(
                          icon: Icon(Icons.expand_more),
                          dropdownColor: const Color(0xffF0F0F0),
                          value: frequency,
                          items: [
                            DropdownMenuItem(
                              child: Text(
                                'Every Minute',
                                style: TextStyle(color: Colors.black),
                              ),
                              value: 1,
                            ),
                            DropdownMenuItem(
                              child: Text(
                                'Every 5 minutes',
                                style: TextStyle(color: Colors.black),
                              ),
                              value: 5,
                            ),
                            DropdownMenuItem(
                              child: Text(
                                'Every 10 minutes',
                                style: TextStyle(color: Colors.black),
                              ),
                              value: 10,
                            ),
                            DropdownMenuItem(
                              child: Text(
                                'Every 30 minutes',
                                style: TextStyle(color: Colors.black),
                              ),
                              value: 30,
                            ),
                            DropdownMenuItem(
                              child: Text(
                                'Every hour',
                                style: TextStyle(color: Colors.black),
                              ),
                              value: 60,
                            )
                          ],
                          onSaved: (value) {
                            if (value == 1 || value == 5) {
                              if (paymentSnapshot.exists) {
                                if (DateTime.now().isAfter(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        paymentSnapshot.value['expires']))) {
                                  frequency = 60;
                                } else {
                                  frequency = value! as int;
                                }
                              } else {
                                frequency = 60;
                              }
                            } else {
                              frequency = value! as int;
                            }
                          },
                          onChanged: (value) {
                            // check if chosen frequency is 1 or 5 and whether current account is a paid account.
                            if (value == 1 || value == 5) {
                              if (paymentSnapshot.exists) {
                                if (DateTime.now().isAfter(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        paymentSnapshot.value['expires']))) {
                                  // TO IMPLEMENT fallback to default frequency
                                  _paymentAlert(paidFrequency);
                                }
                              } else {
                                // TO IMPLEMENT fallback to default frequency
                                _paymentAlert(paidFrequency);
                              }
                            }
                          },
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: CustomColors.primaryColor),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xffF0F0F0),
                            hintText: 'Select Frequency',
                            hintStyle: TextStyle(
                                color: CustomColors.primaryColor, fontSize: 18),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50)),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black12),
                                borderRadius: BorderRadius.circular(50)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black12),
                                borderRadius: BorderRadius.circular(50)),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
            SizedBox(
              height: 18,
            ),
            Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      try {
                        await userUrlsRef.push().set({
                          'name': websiteName,
                          'url': websiteUrl,
                          'description': websiteDescription,
                          'type': websiteType,
                          'live': true,
                          'timestamp': DateTime.now().millisecondsSinceEpoch,
                          'statusTimestamp':
                              DateTime.now().millisecondsSinceEpoch,
                          'frequency': frequency
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          width: 200,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(milliseconds: 1500),
                          content: Text(
                            'Property Successfully Created',
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
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(CustomColors.black),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50))),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'Publish Property',
                      style: TextStyle(color: CustomColors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ]),
            SizedBox(
              height: 15,
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: CustomColors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _paymentAlert(title) {
    showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black87,
        builder: (context) {
          return PaymentAlert(title: title);
        });
  }

  _proceedToPayment(BuildContext context, price, type) async {
    final flutterwave = Flutterwave.forUIPayment(
        amount: price,
        currency: FlutterwaveCurrency.KES,
        context: this.context,
        publicKey: "FLWPUBK_TEST-80caf38c534c399ffe90a8ad8e04d15b-X",
        encryptionKey: "FLWSECK_TEST7e2bcb308ab3",
        email: _userEmail(),
        fullName: "Test User",
        txRef: DateTime.now().toIso8601String(),
        narration: "PingRobot",
        isDebugMode: true,
        phoneNumber: '+254',
        acceptAccountPayment: true,
        acceptCardPayment: true,
        acceptUSSDPayment: true,
        acceptMpesaPayment: true);
    final response = await flutterwave.initializeForUiPayments();
    if (response != null) {
      print(response.data!.status);
      if (response.data!.status == 'successful') {
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   width: 200,
        //   behavior: SnackBarBehavior.floating,
        //   duration: const Duration(milliseconds: 1500),
        //   content: Text(
        //     'Payment Successful',
        //     textAlign: TextAlign.center,
        //   ),
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(15.0),
        //   ),
        // ));
        _savePayment(type);
      }
    } else {
      print("No Response!");
    }
  }

  _savePayment(type) {
    database.child('userPayments/$userId').set({
      'type': type,
      'expires': DateTime.now().add(Duration(days: 31)).millisecondsSinceEpoch,
    });
  }
}
