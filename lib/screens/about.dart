import 'package:flutter/material.dart';
import 'package:pingrobot/theme/colors.dart';

class About extends StatelessWidget {
  const About({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text('About'),
            backgroundColor: CustomColors.primaryColor,
          ),
          body: Column(
            children: [
              const ListTile(
                title: Text('Version'),
                subtitle: Text('1.0.0'),
              ),
              const Divider(
                height: 10,
                thickness: 1,
              ),
            ],
          )),
    );
  }
}
