import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutterwave/flutterwave.dart';
import 'package:pingrobot/theme/colors.dart';

class PaymentAlert extends StatefulWidget {
  const PaymentAlert({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<PaymentAlert> createState() => _PaymentAlertState();
}

class _PaymentAlertState extends State<PaymentAlert> {
  List checked = [
    {
      'value': true,
      'cost': '150',
      'type': 'PREMIUM',
      'perks': [
        '- Monitor up to 10 properties',
        '- Includes 1min & 5min checks'
      ]
    },
    {
      'value': false,
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

  @override
  void initState() {
    super.initState();
    database = FirebaseDatabase.instance.ref();
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
            color: CustomColors.lightGreyScaffold,
            borderRadius: BorderRadius.circular(10)),
        width: 368,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 15.0),
            child: DefaultTextStyle(
              style: TextStyle(color: CustomColors.black),
              child: Text(
                widget.title.isEmpty
                    ? 'You are trying to access a paid feature. \n Please upgrade to continue'
                    : widget.title,
                style: TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 10.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 3.6,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 2,
                itemBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    // height: MediaQuery.of(context).size.height / 2.9,
                    width: MediaQuery.of(context).size.width / 1.8,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      elevation: 2.0,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: index == 0 &&
                                    widget.title.split(' ')[3] == 'AGENCY'
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        top: 16.0, bottom: 18.0, left: 3.0),
                                    child: Text(
                                      'CURRENT PLAN',
                                      style: TextStyle(
                                          color: CustomColors.primaryColor),
                                    ),
                                  )
                                : Checkbox(
                                    value: checked[index]['value'],
                                    checkColor: Colors.white,
                                    fillColor:
                                        MaterialStateProperty.resolveWith(
                                            getColor),
                                    shape: CircleBorder(),
                                    onChanged: (value) {
                                      if (index == 0) {
                                        setState(() {
                                          checked[0]['value'] = value;
                                          if (value == true) {
                                            checked[1]['value'] = false;
                                          }
                                        });
                                      } else {
                                        setState(() {
                                          checked[1]['value'] = value;
                                          if (value == true) {
                                            checked[0]['value'] = false;
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
                                  text: 'Ksh ${checked[index]['cost']}',
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
                          ...List.generate(checked[index]['perks'].length,
                              (innerIndex) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
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
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 4.0),
            child: Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.title.split(' ')[3] == 'AGENCY') {
                      checked[0]['value'] = false;
                    }

                    if (checked[0]['value'] == false &&
                        checked[1]['value'] == false) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        width: 200,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(milliseconds: 1500),
                        content: Text(
                          'You must select an option to proceed',
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
                          _proceedToPayment(context, price, element['type']);
                        }
                      });
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
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Upgrade',
                      style: TextStyle(color: CustomColors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          SizedBox(
            height: 15,
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: CustomColors.primaryColor, fontSize: 16),
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ]),
      ),
    );
  }
}
