import 'package:flutter/material.dart';
import 'package:pingrobot/screens/home.dart';
import 'package:pingrobot/theme/colors.dart';

class Signin extends StatelessWidget {
  const Signin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: CustomColors.whiteScaffold,
        body: SafeArea(
            child: Padding(
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
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const Home()));
                      },
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            CustomColors.primaryColor),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                      ),
                      icon: SizedBox(
                          width: 26,
                          child: Image.asset('assets/images/google.png')),
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
