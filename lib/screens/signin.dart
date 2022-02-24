import 'package:flutter/material.dart';
import 'package:pingrobot/screens/home.dart';
import 'package:pingrobot/services/google_signin.dart';
import 'package:pingrobot/theme/colors.dart';

class Signin extends StatefulWidget {
  const Signin({Key? key}) : super(key: key);

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: CustomColors.whiteScaffold,
        body: SafeArea(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: CustomColors.primaryColor,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 100,
                          ),
                          Image.asset(
                            'assets/images/pingrobot.png',
                            // width: 180,
                          ),
                          SizedBox(
                            height: 260,
                          ),
                          SizedBox(
                            width: 240,
                            child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  GoogleSigninService googleSigninService =
                                      GoogleSigninService();
                                  googleSigninService
                                      .googleSignin()
                                      .whenComplete(() {
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Home()));
                                  });
                                  //implement errors and exceptions
                                },
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          CustomColors.primaryColor),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18))),
                                ),
                                icon: SizedBox(
                                    width: 34,
                                    child: Image.asset(
                                        'assets/images/google_circle.png')),
                                label: const Padding(
                                  padding: EdgeInsets.all(14),
                                  child: Text(
                                    'Continue with Google',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )),
                          )
                        ],
                      ),
                    ),
                  )));
  }
}
