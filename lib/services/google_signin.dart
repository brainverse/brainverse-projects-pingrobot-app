import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSigninService {
  final _googleSignIn = GoogleSignIn(scopes: [
    'email',
  ]);

  googleSignin() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser != null) {
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      return authResult;
    } else {
      return;
    }
  }

  googleSignout() async {
    await _googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }
}
