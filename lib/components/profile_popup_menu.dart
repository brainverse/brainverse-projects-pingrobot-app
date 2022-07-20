import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pingrobot/screens/about.dart';
import 'package:pingrobot/screens/profile.dart';
import 'package:pingrobot/screens/signin.dart';
import 'package:pingrobot/services/google_signin.dart';

class ProfilePopupMenu extends StatelessWidget {
  const ProfilePopupMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      child: CircleAvatar(
        radius: 20,
        backgroundImage:
            NetworkImage(FirebaseAuth.instance.currentUser!.photoURL ?? ''),
      ),
      onSelected: (result) {
        if (result == 'Signout') {
          GoogleSigninService googleSigninService = GoogleSigninService();
          googleSigninService.googleSignout().whenComplete(() =>
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const Signin()),
                  (Route<dynamic> route) => false));
        } else if (result == 'About') {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const About()));
        } else if (result == 'Profile') {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => Profile()));
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
        const PopupMenuItem(
          value: 'Profile',
          child: ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Profile'),
          ),
        ),
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
    );
  }
}
