import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:spinal_flutter/components/rounded_button.dart';

class InventoryScreen extends StatefulWidget {
  static const String id = 'inventory_screen';

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 220.0,
            floating: true,
            pinned: true,
            snap: true,
            elevation: 50,
            backgroundColor: Colors.pink,
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
          SliverList(delegate: new SliverChildListDelegate(_buildList(50))),
        ],
      ),
      drawer: ClipRRect(
        borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(30.0),
            topRight: Radius.circular(30.0)),
        child: Drawer(),
      ),
    );
  }

  List _buildList(int count) {
    List<Widget> listItems = List();

    for (int i = 0; i < count; i++) {
      listItems.add(new Padding(
          padding: new EdgeInsets.all(20.0),
          child: new Text('Item ${i.toString()}',
              style: new TextStyle(fontSize: 25.0))));
    }

    return listItems;
  }
}
