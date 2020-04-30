import 'package:flutter/material.dart';

class InventorySelector extends StatefulWidget {
  @override
  _InventorySelectorState createState() => _InventorySelectorState();
}

int selectedIndex = 0;

class _InventorySelectorState extends State<InventorySelector> {
  final List<String> categories = ['Inventory'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.0,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  color: index == selectedIndex ? Colors.white : Colors.white60,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
