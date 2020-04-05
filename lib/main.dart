import 'package:flutter/material.dart';
import 'package:spinal_flutter/screens/welcome_screen.dart';
import 'package:spinal_flutter/screens/login_screen.dart';
import 'package:spinal_flutter/screens/registration_screen.dart';
import 'package:spinal_flutter/screens/main_inventory_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spinal_flutter/services/auth.dart';
import 'package:custom_splash/custom_splash.dart';

void main() => runApp(
      ChangeNotifierProvider<AuthService>(
        child: MyApp(),
        create: (BuildContext context) {
          return AuthService();
        },
      ),
    );

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: CustomSplash(
        imagePath: 'images/google_logo.png',
        backGroundColor: Colors.white,
        animationEffect: 'zoom-in',
        duration: 2500,
        logoSize: 200,
        home: buildFutureBuilder(context),
      ),
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
//          InventoryScreen.id: (context) => InventoryScreen(snapshot.data),
      },
    );
  }

  FutureBuilder<FirebaseUser> buildFutureBuilder(BuildContext context) {
    return FutureBuilder<FirebaseUser>(
      future: Provider.of<AuthService>(context).getUser(),
      builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
        //          ⇐ NEW
        if (snapshot.connectionState == ConnectionState.done) {
          // log error to console                                            ⇐ NEW
          if (snapshot.error != null) {
            print("error");
            return Text(snapshot.error.toString());
          }
          // redirect to the proper page, pass the user into the
          // `HomePage` so we can display the user email in welcome msg     ⇐ NEW
          final bool loggedIn = snapshot.hasData;
          print("hello");
          return loggedIn ? InventoryScreen(snapshot.data) : WelcomeScreen();
        } else {
          print(snapshot.error);
          print('hi');
          // show loading indicator                                         ⇐ NEW
          return LoadingCircle();
        }
      },
    );
  }
}

class LoadingCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: CircularProgressIndicator(),
        alignment: Alignment(0.0, 0.0),
      ),
    );
  }
}
