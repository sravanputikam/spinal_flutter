import 'package:flutter/material.dart';
import 'package:spinal_flutter/screens/welcome_screen.dart';
import 'package:spinal_flutter/screens/login_screen.dart';
import 'package:spinal_flutter/screens/registration_screen.dart';
import 'package:spinal_flutter/screens/main_inventory_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: WelcomeScreen.id,
        routes: {
          WelcomeScreen.id: (context) => WelcomeScreen(),
          LoginScreen.id: (context) => LoginScreen(),
          RegistrationScreen.id: (context) => RegistrationScreen(),
          InventoryScreen.id: (context) => InventoryScreen(),
        });
  }
}
