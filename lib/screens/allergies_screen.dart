import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AllergyScreen extends StatefulWidget {
  static const String id = 'allergy_screen';
  final DatabaseReference database;

  AllergyScreen(this.database);

  @override
  _AllergyScreen createState() => _AllergyScreen();
}

enum ConfirmAction { Cancel, Accept }

class _AllergyScreen extends State<AllergyScreen> {
  StreamSubscription<Event> _onAddedSubscription;
  StreamSubscription<Event> _onChangedSubscription;
  StreamSubscription<Event> _onDeletedSubscription;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final _textEditingController = TextEditingController();
  List _allergenList = List();
  List _allergyKeys = List();
  DatabaseReference _database;

  @override
  void initState() {
    super.initState();
    _database = widget.database;
    _onAddedSubscription =
        _database.child("Allergies").onChildAdded.listen((onEntryAdded));
    _onDeletedSubscription =
        _database.child("Allergies").onChildRemoved.listen((onEntryRemoved));
  }

  @override
  void dispose() {
    _onAddedSubscription.cancel();
    _onChangedSubscription.cancel();
    _onDeletedSubscription.cancel();
    super.dispose();
  }

  onEntryAdded(Event event) {
    setState(() {
//      print(event.snapshot.value);
      _allergenList.add(event.snapshot.value);
      _allergyKeys.add(event.snapshot.key);
    });
  }

  onEntryRemoved(Event event) {
    setState(() {
      String allergy = event.snapshot.value;
      _allergenList.remove(allergy);
      _allergyKeys.remove(event.snapshot.key);
    });
  }

  addNewAllergen(String allergy) {
    if (allergy.length > 0) {
      _database.reference().child("Allergies").push().set(allergy);
    }
  }

  deleteAllergen(String allergy, var key, int index) {
    _database.reference().child("Allergies").child(key).remove().then((_) {
      print("Delete $allergy successful");
      _allergyKeys.remove(key);
      setState(() {
        _allergenList.remove(allergy);
      });
    });
  }

  showAddAllergenDialog(BuildContext context) async {
    _textEditingController.clear();
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            content: Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                  controller: _textEditingController,
                  autofocus: false,
                  decoration: InputDecoration(
                    labelText: 'Add new allergen',
                  ),
                ))
              ],
            ),
            actions: <Widget>[
              FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              FlatButton(
                  child: const Text('Add'),
                  onPressed: () {
                    addNewAllergen(_textEditingController.text.toString());
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  Future<ConfirmAction> deleteConfirmDialog(BuildContext context) async {
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text('Delete This Allergy?'),
//          content: const Text('This will delete the contact from your device.'),
          actions: <Widget>[
            FlatButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.Cancel);
              },
            ),
            FlatButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.Accept);
              },
            )
          ],
        );
      },
    );
  }

  Widget slideLeftBackground(alignment) {
    return Container(
      color: Colors.red,
      child: Align(
        child: Row(
          mainAxisAlignment: alignment,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              " Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

  Widget showAllergyList() {
    if (_allergenList.length > 0) {
      return Expanded(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: _allergenList.length,
              itemBuilder: (BuildContext context, int index) {
                String allergen = _allergenList[index];
                var key = _allergyKeys[index];
                return Dismissible(
                  key: Key(allergen),
//                background: Container(color: Colors.red),
                  background: slideLeftBackground(MainAxisAlignment.start),
                  secondaryBackground:
                      slideLeftBackground(MainAxisAlignment.end),
                  confirmDismiss: (direction) async {
                    bool confirm = false;
                    if (direction == DismissDirection.endToStart ||
                        direction == DismissDirection.startToEnd) {
                      final ConfirmAction action =
                          await deleteConfirmDialog(context);
                      if (action == ConfirmAction.Accept) {
                        confirm = true;
                      }
                    }
                    return confirm;
                  },
                  onDismissed: (direction) async {
                    deleteAllergen(allergen, key, index);
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(
                        allergen,
                        style: TextStyle(fontSize: 20.0),
                      ),
                      leading: FlutterLogo(),
                    ),
                  ),
                );
              }),
        ),
      );
    } else {
      return Expanded(
        child: Center(
            child: Text(
          "Hurray. You have no allergies",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30.0),
        )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF333333),
//        appBar: new AppBar(
//          title: new Text('Allergies'),
//        ),
        body: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                SafeArea(
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.width - 250.0,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Color(0xFF333333),
//                      borderRadius: BorderRadius.only(
//                          bottomLeft: Radius.circular(30.0),
//                          bottomRight: Radius.circular(30.0)),
                        ),
                      ),
                      Container(
                        height: 90.0,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(40.0),
                            topLeft: Radius.circular(40.0),
                          ),
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        iconSize: 30.0,
                        color: Colors.white,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width / 4,
                  top: 20.0,
                  child: SafeArea(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: Image(
                        image: AssetImage("images/allergy_alert.png"),
                        width: 175.0,
                        height: 175.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            showAllergyList(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showAddAllergenDialog(context);
          },
          backgroundColor: Color(0xFF333333),
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ));
  }
}

//class Allergy {
//  String allergen;
//  Allergy();
//
//  Allergy.fromSnapshot(DataSnapshot snapshot)
//      : allergen = snapshot.value['Allergies'];
//  toJson() {
//    return {"Allergies": allergen};
//  }
//}
