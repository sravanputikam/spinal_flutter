import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:spinal_flutter/constants.dart';
import 'package:spinal_flutter/screens/allergies_screen.dart';
import 'package:spinal_flutter/screens/settings.dart';

class CustomDrawer extends StatelessWidget {
  final DatabaseReference database;
  CustomDrawer(this.database);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        padding: EdgeInsets.all(10.0),
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Settings()),
                    );
                  },
                ),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Wrap(
              spacing: 15.0,
              runSpacing: 10.0,
              crossAxisAlignment: WrapCrossAlignment.start,
//              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                DrawerIcons(
                  item: 'Recipes',
                  image: kDrawerItems['Recipes'],
                  onTap: () {},
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
                  onTap: () {},
                ),
                DrawerIcons(
                  item: 'Grocery List',
                  image: kDrawerItems['GroceryList'],
                  onTap: () {},
                ),
                DrawerIcons(
                  item: 'Favorites',
                  image: kDrawerItems['Favorites'],
                  onTap: () {},
                )
              ],
            )
          ],
        ),
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
