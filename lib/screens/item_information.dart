import 'package:flutter/material.dart';
import 'package:spinal_flutter/components/item.dart';
import 'dart:convert';
import 'package:spinal_flutter/constants.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:spinal_flutter/components/rounded_button.dart';

class ItemInformation extends StatefulWidget {
  static const String id = 'item_information';

  final Item item;
  ItemInformation(this.item);
  @override
  _ItemInformationState createState() => _ItemInformationState();
}

class _ItemInformationState extends State<ItemInformation>
    with SingleTickerProviderStateMixin {
  bool favoriteToggle = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            actions: <Widget>[
              IconButton(
                icon: Icon(
                    favoriteToggle ? Icons.favorite : Icons.favorite_border),
                onPressed: () {
                  setState(() {
                    if (favoriteToggle == true)
                      favoriteToggle = false;
                    else
                      favoriteToggle = true;
                  });
                },
              ),
            ],
            elevation: 100,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.memory(base64.decode(widget.item.image)),
            ),
          ),
          SliverPadding(
            padding: EdgeInsetsDirectional.only(start: 5.0, end: 5.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  widget.item.itemName,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  'Expiration: ${widget.item.expiry}',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  'Ingredients:',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
                ),
                Text(
                  widget.item.ingredients,
                  style: TextStyle(fontSize: 15.0),
                ),
              ]),
            ),
          )
        ],
      ),
    );
  }
}
