import 'package:flutter/material.dart';
import 'package:pingrobot/theme/colors.dart';
import 'package:url_launcher/url_launcher.dart';

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
              ListTile(
                title: Text('Privacy Policy'),
                onTap: () async {
                  var url = Uri.parse(
                      "https://github.com/brainverse/pingrobot-privacy/blob/main/privacy-policy.md");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    throw "Cannot launch $url";
                  }
                },
              ),
            ],
          )),
    );
  }
}
