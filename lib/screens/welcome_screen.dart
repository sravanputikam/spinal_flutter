import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:spinal_flutter/constants.dart';
import 'login_screen.dart';
import 'login_screen2.dart';
import 'registration_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:spinal_flutter/widgets/rounded_button.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(controller);
    controller.forward();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
//          mainAxisAlignment: MainAxisAlignment.,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 100.0,
            ),
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: FlutterLogo(
                      size: 100.0,
                    ),
                    height: 60.0,
                  ),
                ),
                TypewriterAnimatedTextKit(
                  text: [kAppName],
                  textStyle: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            Container(
              child: Image.asset('images/splash2.png'),
            ),
            SizedBox(
              height: 75.0,
            ),
            RaisedButton(
              onPressed: () {
                Navigator.pushNamed(context, LoginScreen2.id);
              },
              textColor: Colors.white,
              color: Colors.redAccent,
              elevation: 5.0,
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              padding: EdgeInsets.only(left: 30.0, right: 30.0),
              child: Text(
                kSignUpTerms,
                style: TextStyle(color: Colors.grey, fontSize: 10.0),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}
