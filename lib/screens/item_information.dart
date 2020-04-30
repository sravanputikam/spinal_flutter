import 'package:flutter/material.dart';
import 'package:spinal_flutter/components/item.dart';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';

class ItemInformation extends StatefulWidget {
  static const String id = 'item_information';

  final Item item;
  final database;
  final allergenList;
  String quantityLeft = '';
  String servingsLeft = '';

  ItemInformation(this.item, this.allergenList, this.database,
      this.quantityLeft, this.servingsLeft);
  @override
  _ItemInformationState createState() => _ItemInformationState();
}

class _ItemInformationState extends State<ItemInformation>
    with SingleTickerProviderStateMixin {
  bool favoriteToggle = false;
  bool editToggle = false;
  String quantityLeft;
  String servingsLeft = '';
  String oldQuantityLeft;
  bool added = false;
  String oldServingsLeft;
  DatabaseReference itemDatabase;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    String quantity = widget.item.quantity.toString();
    String servings = widget.item.nutrients['Total Servings'].toString();
    itemDatabase =
        widget.database.child('Items').child('${widget.item.itemName}');
//    oldQuantityLeft = widget.servingsLeft;
//    oldServingsLeft = widget.quantityLeft;
//    quantityLeft = widget.quantityLeft;
//    servingsLeft = widget.servingsLeft;
//    print(widget.item.daysLeft);
    itemDatabase.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      if (values.containsKey('Quantity Left')) {
        quantityLeft = values['Quantity Left'];
        oldQuantityLeft = quantityLeft;
      } else {
        itemDatabase.update({'Quantity Left': quantity});
        quantityLeft = quantity;
        oldQuantityLeft = quantityLeft;
      }
      if (values.containsKey('Servings Left')) {
        servingsLeft = values['Servings Left'];
        oldServingsLeft = servingsLeft;
      } else {
        itemDatabase.update({'Servings Left': servings});
        servingsLeft = servings;
        oldServingsLeft = servingsLeft;
      }
      setState(() {
        added = !added;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    String quantity = widget.item.quantity.toString();
    String servings = widget.item.nutrients['Total Servings'].toString();
    bool checkAllergen = true;
    widget.allergenList.forEach((allergen) {
      if (widget.item.ingredients.contains(allergen)) checkAllergen = false;
    });

    String expirationImage;
    if (widget.item.daysLeft <= 7)
      expirationImage = 'images/red_clock.png';
    else if (7 < widget.item.daysLeft && widget.item.daysLeft <= 14)
      expirationImage = 'images/yellow_clock.png';
    else
      expirationImage = 'images/green_clock.png';

    return Scaffold(
      backgroundColor: Color(0xFF7A9BEE),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (servingsLeft == '0') {
              Navigator.of(context).pop('0');
            } else {
              Navigator.of(context).pop('n');
            }
          },
        ),
        backgroundColor: Color(0xFF7A9BEE),
        elevation: 0.0,
//        title: Text(widget.item.itemName),
        actions: <Widget>[
          IconButton(
            icon: Icon(editToggle ? Icons.check : Icons.mode_edit),
            onPressed: () async {
              if (servingsLeft == '0' || quantityLeft == '0') {
                final action = await confirmFinish(context);
                if (action == 'Yes') {
                  setState(() {
                    editToggle = !editToggle;
                  });
                }
              } else {
                setState(() {
                  itemDatabase.update({'Quantity Left': quantityLeft});
                  itemDatabase.update({'Servings Left': servingsLeft});
                  editToggle = !editToggle;
                });
              }
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
            height: 75.0,
            width: MediaQuery.of(context).size.width,
            color: Color(0xFF7A9BEE),
            child: Center(
              child: Text(
                widget.item.itemName[0].toUpperCase() +
                    widget.item.itemName.substring(1),
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
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
                          height: 2.0,
                        ),
                        Container(
                          height: 50.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                expirationImage,
                                height: 30.0,
                                width: 30.0,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Image.asset(
                                checkAllergen
                                    ? 'images/safe_icon.png'
                                    : 'images/unsafe_icon.png',
                                height: 30.0,
                                width: 30.0,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Text(
                    'Expiration: ${widget.item.expiry[1]}',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
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
                        width: 50.0,
                        child: editToggle == false
                            ? Text(
                                added ? quantityLeft : quantity,
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            : TextFormField(
                                initialValue: added ? quantityLeft : quantity,
                                readOnly: false,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w400),
                                onFieldSubmitted: (newValue) {
                                  print(newValue);
                                  if (newValue != quantityLeft) {
                                    quantityLeft = newValue;
                                  }
                                },
                              ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'Servings Left: ',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        width: 50.0,
                        child: editToggle == false
                            ? Text(
                                added ? servingsLeft : servings,
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w400),
                              )
                            : TextFormField(
                                initialValue: added ? servingsLeft : servings,
                                readOnly: false,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w400),
                                onFieldSubmitted: (newValue) {
                                  print(newValue);
                                  if (newValue != servingsLeft) {
                                    servingsLeft = newValue;
//                                    itemDatabase.update(
//                                        {'Servings Left': servingsLeft});
                                  }
                                },
                              ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Wrap(
                    runAlignment: WrapAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Serving Size: ${widget.item.nutrients['Serving Size']} ${widget.item.nutrients['Serving Unit']}',
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.w400),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  ListTileTheme(
                    contentPadding: EdgeInsets.all(0.0),
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
                  editToggle
                      ? Container(
                          height: 150.0,
                        )
                      : Container(
                          height: 0.0,
                        )
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
      Wrap(
//        mainAxisAlignment: MainAxisAlignment.start,
        runAlignment: WrapAlignment.start,
        children: <Widget>[
          Text(
            'Serving Size: ${nutrients['Serving Size']} ${nutrients['Serving Unit']}',
            style: TextStyle(fontSize: 17),
            textAlign: TextAlign.left,
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
        space2: 50.0,
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

  Future confirmFinish(context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Did you really finish your food ?'),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop('No');
                setState(() {
                  servingsLeft = oldServingsLeft;
                  quantityLeft = oldQuantityLeft;
                });
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                itemDatabase.update({'Servings Left': '0'});
                itemDatabase.update({'Quantity Left': '0'});
                servingsLeft = '0';
                oldServingsLeft = '0';
                quantityLeft = '0';
                oldQuantityLeft = '0';
                Navigator.of(context).pop('Yes');
              },
            ),
          ],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        );
      },
    );
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
