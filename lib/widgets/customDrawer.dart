import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:spinal_flutter/constants.dart';
import 'package:spinal_flutter/screens/allergies_screen.dart';

class CustomDrawer extends StatelessWidget {
  DatabaseReference database;
  CustomDrawer(this.database);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                kAppName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: null,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                DrawerIcons(
                  item: 'Recipes',
                  image: kDrawerItems['Recipes'],
                ),
                DrawerIcons(
                  item: 'Allergies',
                  image: kDrawerItems['Allergies'],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AllergyScreen(database)),
                    );
                  },
                ),
                DrawerIcons(
                  item: 'Meal Prep',
                  image: kDrawerItems['Meal'],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class DrawerIcons extends StatelessWidget {
  DrawerIcons({
    @required this.item,
    @required this.image,
    @required this.onTap,
  });
  final String item;
  final image;
  final onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 25.0,
            backgroundImage: AssetImage(image),
          ),
        ),
        Text(
          item,
          style: TextStyle(fontSize: 10.0),
        )
      ],
    );
  }
}
