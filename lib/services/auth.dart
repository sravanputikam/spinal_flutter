import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/cupertino.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ///
  /// return the Future with firebase user object FirebaseUser if one exists
  ///
  Future<FirebaseUser> getUser() {
    return _auth.currentUser();
  }

  // wrapping the firebase calls
  Future logout() async {
    var result = FirebaseAuth.instance.signOut();
    notifyListeners();
    return result;
  }

  // wrapping the firebase calls
  Future createUser(
      {String firstName,
      String lastName,
      String email,
      String password}) async {
    var r = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    var u = r.user;
    UserUpdateInfo info = UserUpdateInfo();
    info.displayName = '$firstName $lastName';
    return await u.updateProfile(info);
  }

  ///
  /// wrapping the firebase call to signInWithEmailAndPassword
  /// `email` String
  /// `password` String
  ///
  Future<FirebaseUser> loginUser({String email, String password}) async {
    try {
      var result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      // since something changed, let's notify the listeners...
      notifyListeners();
      return result.user;
    } catch (e) {
      throw new AuthException(e.code, e.message);
    }
  }

  Future<FirebaseUser> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return currentUser;
  }
}
