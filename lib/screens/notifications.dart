import 'package:flutter/material.dart';
import 'package:pingrobot/theme/colors.dart';

class Notifications extends StatelessWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: CustomColors.primaryColor,
      ),
    ));
  }
}
