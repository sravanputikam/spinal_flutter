import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spinal_flutter/services/auth.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:spinal_flutter/components/rounded_button.dart';
import 'package:spinal_flutter/widgets/customDrawer.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InventoryScreen extends StatefulWidget {
  static const String id = 'inventory_screen';
  final FirebaseUser currentUser;

  InventoryScreen(this.currentUser);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () async {
                  await Provider.of<AuthService>(context, listen: false)
                      .logout();
                },
              ),
            ],
            elevation: 50,
            backgroundColor: Colors.amber,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'Current Inventory',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Card(
                  color: Colors.white,
                  elevation: 10.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FlutterLogo(
                        size: 125.0,
                      ),
                      Text(
                        'Carrots',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                        ),
                      )
                    ],
                  ),
                );
              },
              childCount: 30,
            ),
          ),
        ],
      ),
      drawer: SafeArea(
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(30.0),
              topRight: Radius.circular(30.0)),
          child: CustomDrawer(),
        ),
      ),
    );
  }
}
