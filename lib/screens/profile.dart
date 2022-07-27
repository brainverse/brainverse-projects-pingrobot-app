import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutterwave/flutterwave.dart';
import 'package:pingrobot/theme/colors.dart';

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List checked = [
    {
      'current': false,
      'cost': '0',
      'type': 'FREE',
      'perks': [
        '- Monitor up to 3 properties',
        '- Includes 10min, 30min & 1hr checks'
      ]
    },
    {
      'value': false,
      'current': false,
      'cost': '150',
      'type': 'PREMIUM',
      'perks': [
        '- Monitor up to 10 properties',
        '- Includes 1min & 5min checks'
      ]
    },
    {
      'value': false,
      'current': false,
      'cost': '350',
      'type': 'AGENCY',
      'perks': [
        '- Monitor up to 50 properties',
        '- Includes 1min & 5min checks'
      ]
    }
  ];

  late final database;

  late final userId;

  late final userPaymentRef;

  late var paymentSnapshot;

  _userEmail() {
    return FirebaseAuth.instance.currentUser!.email;
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return CustomColors.primaryColor;
    }
    return CustomColors.primaryColor;
  }

  _proceedToPayment(BuildContext context, price, type) async {
    final flutterwave = Flutterwave.forUIPayment(
        amount: price,
        currency: FlutterwaveCurrency.KES,
        context: this.context,
        publicKey: "FLWPUBK_TEST-80caf38c534c399ffe90a8ad8e04d15b-X",
        encryptionKey: "FLWSECK_TEST7e2bcb308ab3",
        email: _userEmail(),
        fullName: "PingRobot",
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

  _fetchPaymentState() async {
    paymentSnapshot = await userPaymentRef.get();
  }

  @override
  void initState() {
    super.initState();
    database = FirebaseDatabase.instance.ref();

    userId = FirebaseAuth.instance.currentUser!.uid;

    userPaymentRef = database.child('userPayments/$userId');
    _fetchPaymentState().whenComplete(() {
      if (paymentSnapshot.exists) {
        if (DateTime.now().isAfter(DateTime.fromMillisecondsSinceEpoch(
            paymentSnapshot.value['expires']))) {
          setState(() {
            checked[0]['current'] = true;
          });
        } else {
          if (paymentSnapshot.value['type'] == 'PREMIUM') {
            setState(() {
              checked[1]['current'] = true;
            });
          } else {
            setState(() {
              checked[2]['current'] = true;
            });
          }
        }
      } else {
        setState(() {
          checked[0]['current'] = true;
        });
      }
    });
  }

  // @override
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: CustomColors.lightGreyScaffold,
          appBar: AppBar(
            title: Text('Profile'),
            backgroundColor: CustomColors.primaryColor,
          ),
          body: checked[0]['current'] == false &&
                  checked[1]['current'] == false &&
                  checked[2]['current'] == false
              ? Center(
                  child: CircularProgressIndicator(
                  color: CustomColors.primaryColor,
                ))
              : Column(
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 8.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const Text(
                            'My Plans',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 10.0),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: checked.length,
                          itemBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              width: MediaQuery.of(context).size.width / 1.8,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                elevation: 2.0,
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: checked[index]['current']
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 16.0,
                                                  bottom: 18.0,
                                                  left: 3.0),
                                              child: Text(
                                                'CURRENT PLAN',
                                                style: TextStyle(
                                                    color: CustomColors
                                                        .primaryColor),
                                              ),
                                            )
                                          : index == 0
                                              ? SizedBox(
                                                  height: 45,
                                                )
                                              : Checkbox(
                                                  value: checked[index]
                                                      ['value'],
                                                  checkColor: Colors.white,
                                                  fillColor:
                                                      MaterialStateProperty
                                                          .resolveWith(
                                                              getColor),
                                                  shape: CircleBorder(),
                                                  onChanged: (value) {
                                                    if (index == 1) {
                                                      setState(() {
                                                        checked[1]['value'] =
                                                            value;
                                                        if (value == true) {
                                                          checked[2]['value'] =
                                                              false;
                                                        }
                                                      });
                                                    } else {
                                                      setState(() {
                                                        checked[2]['value'] =
                                                            value;
                                                        if (value == true) {
                                                          checked[1]['value'] =
                                                              false;
                                                        }
                                                      });
                                                    }
                                                  },
                                                ),
                                    ),
                                    Text(
                                      checked[index]['type'],
                                      style: TextStyle(
                                          fontSize: 26,
                                          color: CustomColors.primaryColor,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                            text:
                                                'Ksh ${checked[index]['cost']}',
                                            style: TextStyle(
                                                color: CustomColors.black,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w700)),
                                        TextSpan(
                                            text: '/month',
                                            style: TextStyle(
                                                color: CustomColors.grey,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500))
                                      ]),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    ...List.generate(
                                        checked[index]['perks'].length,
                                        (innerIndex) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          checked[index]['perks'][innerIndex],
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: CustomColors.grey,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        // SizedBox(
                        //   width: MediaQuery.of(context).size.width / 3,
                        // ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 3.0),
                            child: ElevatedButton(
                              onPressed: () {
                                if (checked[1]['value'] == false &&
                                    checked[2]['value'] == false) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    width: 200,
                                    behavior: SnackBarBehavior.floating,
                                    duration:
                                        const Duration(milliseconds: 1500),
                                    content: Text(
                                      'Please select an option to proceed',
                                      textAlign: TextAlign.center,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                  ));
                                } else {
                                  checked.forEach((element) {
                                    if (element['value'] == true) {
                                      var price = element['cost'];
                                      Navigator.pop(context);
                                      _proceedToPayment(
                                          context, price, element['type']);
                                    }
                                  });
                                }
                              },
                              style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        CustomColors.black),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50))),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: Text(
                                  'Update',
                                  style: TextStyle(
                                      color: CustomColors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 1.6,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 2.6,
                    )
                  ],
                )),
    );
  }
}
