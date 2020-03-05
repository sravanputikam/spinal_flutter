import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spinal_flutter/components/rounded_button.dart';
import 'package:spinal_flutter/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spinal_flutter/screens/main_inventory_screen.dart';
import 'package:spinal_flutter/services/auth.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showSpinner = false;
  final _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  String email;
  String password;

  void signOutGoogle() async {
    await googleSignIn.signOut();
    print("User Sign Out");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: FlutterLogo(
                      size: 100.0,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Enter your email'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your password'),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                title: 'Log In',
                colour: Colors.lightBlueAccent,
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });

                  try {
                    FirebaseUser result =
                        await Provider.of<AuthService>(context, listen: false)
                            .loginUser(email: email, password: password);
                    setState(() {
                      showSpinner = false;
                    });
                    print(result);
                    Navigator.of(context).pop();
//                    Navigator.pushNamed(context, InventoryScreen.id)
                  } on AuthException catch (error) {
                    return _buildErrorDialog(context, error.message);
                  } on Exception catch (error) {
                    return _buildErrorDialog(context, error.toString());
                  }
                },
              ),
              GoogleSignInButton(
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  FirebaseUser result =
                      await Provider.of<AuthService>(context, listen: false)
                          .signInWithGoogle();
                  setState(() {
                    showSpinner = false;
                  });
                  print(result);
                  Navigator.of(context).pop();
                },
                borderRadius: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future _buildErrorDialog(BuildContext context, _message) {
  return showDialog(
    builder: (context) {
      return AlertDialog(
        title: Text('Error Message'),
        content: Text(_message),
        actions: <Widget>[
          FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              })
        ],
      );
    },
    context: context,
  );
}
