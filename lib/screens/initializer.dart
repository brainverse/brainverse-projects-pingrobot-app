import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pingrobot/screens/signin.dart';
import 'package:pingrobot/theme/colors.dart';
import 'home.dart';

class Initializer extends StatefulWidget {
  const Initializer({Key? key}) : super(key: key);

  @override
  _InitializerState createState() => _InitializerState();
}

class _InitializerState extends State<Initializer> {
  bool isVerifying = true;
  late FirebaseAuth _auth;
  late User? _user;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _user = _auth.currentUser;
    // isVerifying = false;
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        isVerifying = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isVerifying
        ? Scaffold(
            backgroundColor: CustomColors.whiteScaffold,
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/pingrobot.png',
                        width: 160,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        : _user == null
            ? const Signin()
            : const Home();
  }
}
