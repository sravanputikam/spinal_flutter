import 'package:flutter/material.dart';
import 'package:spinal_flutter/components/item.dart';
import 'dart:convert';
import 'package:spinal_flutter/constants.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:spinal_flutter/widgets/rounded_button.dart';

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
  bool editToggle = false;
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    String quantity = widget.item.quantity;
//    var calories = widget.item.nutrients['Calories'];

    return Scaffold(
      backgroundColor: Color(0xFF7A9BEE),
      appBar: AppBar(
        backgroundColor: Color(0xFF7A9BEE),
        elevation: 0.0,
        title: Text(widget.item.itemName),
        actions: <Widget>[
          IconButton(
            icon: Icon(editToggle ? Icons.check : Icons.mode_edit),
            onPressed: () {
              setState(() {
                editToggle = !editToggle;
              });
            },
          ),
          IconButton(
            icon: Icon(favoriteToggle ? Icons.favorite : Icons.favorite_border),
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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 50.0,
            width: MediaQuery.of(context).size.width,
            color: Color(0xFF7A9BEE),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
                color: Colors.white,
              ),
              child: ListView(
                children: <Widget>[
                  Hero(
                    tag: widget.item.itemName,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: 150.0,
                          width: 150.0,
                          child: Image.memory(base64.decode(widget.item.image)),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                'images/yellow_clock.png',
                                height: 30.0,
                                width: 30.0,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Image.asset(
                                'images/unsafe_icon.png',
                                height: 30.0,
                                width: 30.0,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    widget.item.itemName[0].toUpperCase() +
                        widget.item.itemName.substring(1),
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'Quantity Left: ',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        width: 15.0,
                        child: editToggle == false
                            ? Text(
                                quantity,
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w400),
                              )
                            : TextFormField(
                                initialValue: quantity,
                                readOnly: false,
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w400),
                              ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    'Expiration: ${widget.item.expiry}',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  ListTileTheme(
                    contentPadding: EdgeInsets.all(0),
                    child: ExpansionTile(
                      title: Text(
                        'Ingredients:',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.w400),
                      ),
                      children: <Widget>[
                        Text(
                          widget.item.ingredients,
                          style: TextStyle(fontSize: 15.0),
                        ),
                      ],
                    ),
                  ),
                  ListTileTheme(
                    contentPadding: EdgeInsets.all(0),
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      title: Text(
                        'Nutrients:',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.w400),
                      ),
                      children: createTable(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  createTable() {
    var nutrients = widget.item.nutrients;
    print(nutrients);
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Text(
              'Total Servings: ${nutrients['Total Servings']}',
              style: TextStyle(fontSize: 17),
            ),
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Text(
              'Serving Size: ${nutrients['Serving Size']} ${nutrients['Serving Unit']}',
              style: TextStyle(fontSize: 17),
            ),
          ),
        ],
      ),
      Container(
        padding: EdgeInsets.only(right: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              'DV%',
              style: TextStyle(fontSize: 15.0),
            ),
          ],
        ),
      ),
      RowCell(
        color: Colors.white,
        category: 'Energy',
        space1: 125.0,
        quantity: nutrients['Calories'].toStringAsFixed(1) + 'kcal',
        space2: 25.0,
        dv: nutrients['Calories (DV%)'].toString(),
      ),
      RowCell(
        color: Colors.grey[200],
        category: 'Protein',
        space1: 123.0,
        quantity: nutrients['Protein'][0].toStringAsFixed(1) + ' g',
        space2: 62.0,
        dv: nutrients['Protein (DV%)'].toString(),
      ),
      RowCell(
        color: Colors.white,
        category: 'Total Fat',
        space1: 112.0,
        quantity: nutrients['Total Fat'][0].toStringAsFixed(1) + ' g',
        space2: 60.0,
        dv: nutrients['Total Fat (DV%)'].toString(),
      ),
      RowCell(
        space: 40.0,
        color: Colors.grey[200],
        category: 'Saturated Fat',
        space1: 35.0,
        quantity: nutrients['Saturated Fat'][0].toStringAsFixed(1) + ' g',
        space2: 60.0,
        dv: '',
      ),
      RowCell(
        space: 40.0,
        color: Colors.white,
        category: 'Trans Fat',
        space1: 67.0,
        quantity: nutrients['Trans Fat'][0].toStringAsFixed(1) + ' g',
        space2: 60.0,
        dv: '',
      ),
      RowCell(
        color: Colors.grey[200],
        category: 'Toal Carbohydrates',
        space1: 26.0,
        quantity: nutrients['Carbohydrates'][0].toStringAsFixed(1) + ' g',
        space2: 50.0,
        dv: nutrients['Carbohydrates (DV%)'].toString(),
      ),
      RowCell(
        space: 40.0,
        color: Colors.white,
        category: 'Dietary Fiber',
        space1: 42.0,
        quantity: nutrients['Fiber'][0].toStringAsFixed(1) + ' g',
        space2: 60.0,
        dv: nutrients['Fiber (DV%)'].toString(),
      ),
      RowCell(
        space: 40.0,
        color: Colors.grey[200],
        category: 'Sugars',
        space1: 88.0,
        quantity: nutrients['Sugar'][0].toStringAsFixed(1) + ' g',
        space2: 60.0,
        dv: '',
      ),
      RowCell(
        color: Colors.white,
        category: 'Cholesterol',
        space1: 90.0,
        quantity: nutrients['Cholesterol'][0].toStringAsFixed(1) + 'mg',
        space2: 60.0,
        dv: '',
      ),
    ];
  }
}

class RowCell extends StatelessWidget {
  String category;
  double space;
  double space1;
  String quantity;
  double space2;
  String dv;
  final Color color;

  RowCell(
      {this.space = 0,
      this.color,
      this.category,
      this.space1,
      this.quantity,
      this.space2,
      this.dv});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      height: 30.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: space,
          ),
          Text(
            category,
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 15.0,
            ),
          ),
          SizedBox(
            width: space1,
          ),
          Text(
            quantity,
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 15.0,
            ),
          ),
          SizedBox(
            width: space2,
          ),
          SafeArea(
            child: Text(
              '$dv',
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 15.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
