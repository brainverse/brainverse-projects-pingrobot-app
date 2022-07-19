import 'package:badges/badges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pingrobot/screens/about.dart';
import 'package:pingrobot/screens/home.dart';
import 'package:pingrobot/screens/notifications.dart';
import 'package:pingrobot/screens/signin.dart';
import 'package:pingrobot/services/google_signin.dart';
import 'package:pingrobot/shared/dialogs/payment_alert.dart';
import 'package:pingrobot/theme/colors.dart';

class SingleProperty extends StatefulWidget {
  const SingleProperty({Key? key, required this.property}) : super(key: key);
  final Map property;

  @override
  State<SingleProperty> createState() => _SinglePropertyState();
}

class _SinglePropertyState extends State<SingleProperty> {
  final formKey = GlobalKey<FormState>();
  final formKeyEdit = GlobalKey<FormState>();
  TextEditingController websiteNameController = TextEditingController();
  TextEditingController websiteUrlController = TextEditingController();
  TextEditingController websiteDescriptionController = TextEditingController();
  String websiteDescription = '';
  String websiteName = '';
  String websiteUrl = '';
  String websiteType = '';
  var frequency;
  late final userUrlsRef;
  late final database;
  late final userId;
  late final userNotificationsRef;
  late DatabaseReference userPaymentRef;
  late var paymentSnapshot;

  @override
  void initState() {
    super.initState();
    database = FirebaseDatabase.instance.ref();
    userId = FirebaseAuth.instance.currentUser!.uid;
    userUrlsRef = database.child('userUrls/$userId');
    userNotificationsRef = database.child('userNotifications/$userId');
  }

  @override
  void dispose() {
    websiteNameController.dispose();
    websiteUrlController.dispose();
    websiteDescriptionController.dispose();
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
            height: MediaQuery.of(context).size.height / 6.3,
            width: MediaQuery.of(context).size.height,
            color: CustomColors.lightGreyScaffold,
            child: Material(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 16,
                      color: widget.property['live']
                          ? CustomColors.green
                          : CustomColors.red,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    SizedBox(
                      width: 255,
                      child: Text(
                        '${widget.property['name']}',
                        style:
                            TextStyle(color: CustomColors.white, fontSize: 28),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        // the next two operations are performed ahead of time to reduce delay when frequency is edited
                        userPaymentRef = database.child('userPayments/$userId');
                        paymentSnapshot = await userPaymentRef.get();
                        websiteNameController.text = widget.property['name'];
                        websiteUrlController.text = widget.property['url'];
                        websiteDescriptionController.text =
                            widget.property['description'];
                        websiteType = widget.property['type'];
                        frequency = widget.property['frequency'] ?? 60;
                        showModalBottomSheet(
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                              top: Radius.circular(50),
                            )),
                            backgroundColor: CustomColors.primaryColor,
                            context: context,
                            builder: (BuildContext context) {
                              return FractionallySizedBox(
                                  heightFactor: 0.85, child: _editProperty());
                            },
                            isScrollControlled: true);
                      },
                      icon: Icon(
                        Icons.edit,
                        size: 28,
                        color: CustomColors.white,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    IconButton(
                      onPressed: () => showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (BuildContext context, dialogSetState) =>
                                  AlertDialog(
                                content: Text(
                                  'Are you sure you want to delete this property?',
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
                                    onPressed: () async {
                                      try {
                                        await userUrlsRef
                                            .child(widget.property['id'])
                                            .remove();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          width: 200,
                                          behavior: SnackBarBehavior.floating,
                                          duration: const Duration(
                                              milliseconds: 1500),
                                          content: Text(
                                            'Property Successfully Deleted',
                                            textAlign: TextAlign.center,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                        ));
                                        Navigator.pop(context);
                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const Home()),
                                                (Route<dynamic> route) =>
                                                    false);
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          width: 200,
                                          behavior: SnackBarBehavior.floating,
                                          duration: const Duration(
                                              milliseconds: 1500),
                                          content: Text(
                                            '$e',
                                            textAlign: TextAlign.center,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                        ));
                                        Navigator.pop(context);
                                      }
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
                        size: 28,
                        color: CustomColors.white,
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
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 15.0, left: 8.0, bottom: 15.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Status Log',
                              style: TextStyle(
                                  color: CustomColors.grey, fontSize: 28)),
                        ),
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
              if (nextUnread['url'] == widget.property['id']) {
                nextUnread['id'] = key;
                unread.add(nextUnread);
              }
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
                        title: Text('${unread[index]['subtitle']}'),
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

  _editProperty() {
    return StatefulBuilder(
      builder: (BuildContext context, dialogSetState) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                'Edit Property',
                style: TextStyle(color: CustomColors.white, fontSize: 28),
              ),
            ),
            SingleChildScrollView(
              child: Form(
                  key: formKeyEdit,
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
                        controller: websiteNameController,
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
                            'Property Url *',
                            style: TextStyle(color: CustomColors.white),
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: websiteUrlController,
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
                      SizedBox(
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
                        controller: websiteDescriptionController,
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
                          value: websiteType,
                          items: [
                            DropdownMenuItem(
                              child: Text(''),
                              value: '',
                            ),
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
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            hintText: 'Property Type',
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
                          onChanged: (value) async {
                            // check if chosen frequency is 1 or 5 and whether current account is a paid account.
                            if (value == 1 || value == 5) {
                              if (paymentSnapshot.exists) {
                                if (DateTime.now().isAfter(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        paymentSnapshot.value['expires']))) {
                                  // TO IMPLEMENT fallback to default frequency
                                  // dialogSetState(() {
                                  //   frequency = 60;
                                  // });
                                  // Navigator.pop(context);
                                  _paymentAlert();
                                } else {
                                  frequency = value! as int;
                                }
                              } else {
                                // TO IMPLEMENT fallback to default frequency
                                // dialogSetState(() {
                                //   frequency = 60;
                                // });
                                // Navigator.pop(context);
                                _paymentAlert();
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
                    if (formKeyEdit.currentState!.validate()) {
                      formKeyEdit.currentState!.save();
                      try {
                        await userUrlsRef.child(widget.property['id']).update({
                          'name': websiteName,
                          'url': websiteUrl,
                          'description': websiteDescription,
                          'type': websiteType,
                          'frequency': frequency
                        });
                        setState(() {
                          widget.property['name'] = websiteName;
                          widget.property['type'] = websiteType;
                          widget.property['url'] = websiteUrl;
                          widget.property['description'] = websiteDescription;
                          widget.property['frequency'] = frequency;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          width: 200,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(milliseconds: 1500),
                          content: Text(
                            'Property Successfully Edited',
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
                      'Update Property',
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

  _paymentAlert() {
    showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black87,
        builder: (context) {
          return PaymentAlert(
              title:
                  'You need a paid plan to monitor at this frequecy. Please upgrade to continue');
        });
  }
}
