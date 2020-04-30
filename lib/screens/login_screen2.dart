//import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spinal_flutter/services/auth.dart';

class LoginScreen2 extends StatefulWidget {
  static const String id = 'login_screen2';

  @override
  _LoginScreen2State createState() => _LoginScreen2State();
}

class _LoginScreen2State extends State<LoginScreen2> {
  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2250);
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> _loginUser(LoginData data) {
    return Future.delayed(loginTime).then((_) async {
      try {
        FirebaseUser result =
            await Provider.of<AuthService>(context, listen: false)
                .loginUser(email: data.name, password: data.password);
        print(result);
        if (result.isEmailVerified) {
          Navigator.of(context).pop();
        } else {
          await result.sendEmailVerification();
          return 'Email Not Verified';
        }
//        Navigator.of(context).pop();
      } on AuthException catch (error) {
        print(error.message);
        print(error.code);
        if (error.code == 'ERROR_WRONG_PASSWORD') return 'Incorrect Password';
        return "User doesn't exist";
      } on Exception catch (error) {
        print(error.toString());
        print("Hi");
      }
      return null;
    });
  }

  Future<String> _signUp(LoginData data) async {
    return Future.delayed(loginTime).then((_) async {
      try {
        FirebaseUser result =
            await Provider.of<AuthService>(context, listen: false).createUser(
          email: data.name,
          password: data.password,
        );
        print(result);
        try {
          await result.sendEmailVerification();
          Navigator.of(context).pop();
          return null;
        } catch (e) {
          return "An error occured while trying to send email verification";
//          print(e.code);
        }
      } on AuthException catch (error) {
        print(error.message);
        print(error.code);
        return error.message;
//        if (error.code == 'ERROR_WRONG_PASSWORD') return 'Incorrect Password';
//        return "User doesn't exist";
      } on Exception catch (error) {
        print(error.toString());
        print("Hi");
        return 'EMAIL_ALREADY_IN_USE';
      }
    });
  }

  Future<String> _recoverPassword(String email) async {
    return Future.delayed(loginTime).then((_) async {
      try {
        print(email);
        await _firebaseAuth.sendPasswordResetEmail(email: email);
      } on Exception catch (error) {
        print(error.toString());
        return 'There is no user associated with this email account';
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
      ),
      body: Stack(
        children: <Widget>[
          FlutterLogin(
            title: 'SPINAL',
            logoTag: 'logoTag',
            titleTag: 'titleTag',

//        logo: 'images/google_logo.png',
            onLogin: (loginData) {
              return _loginUser(loginData);
            },
            onSignup: (signInData) {
              return _signUp(signInData);
            },
            onSubmitAnimationCompleted: null,
            onRecoverPassword: (email) {
              return _recoverPassword(email);
            },
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 1.35,
            left: 7.5,
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: 350.0,
                  height: 40.0,
                  child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Expanded(
                      child: Divider(
                        color: Colors.white,
                        thickness: 3.0,
                        indent: 20.0,
                        endIndent: 5.0,
                      ),
                    ),
                    Text(
                      "OR",
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.white,
                        thickness: 3.0,
                        indent: 5.0,
                        endIndent: 20.0,
                      ),
                    ),
                  ]),
                ),
                Container(
                  width: 275.0,
                  child: GoogleSignInButton(
                    onPressed: () async {
                      try {
                        FirebaseUser result = await Provider.of<AuthService>(
                                context,
                                listen: false)
                            .signInWithGoogle();
                        print(result);
                        Navigator.of(context).pop();
                      } catch (e) {
                        print(e.toString());
                      }
                    },
                    borderRadius: 20.0,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
