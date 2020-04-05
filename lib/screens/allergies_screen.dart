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
      print(event.snapshot.value);
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
            content: new Row(
              children: <Widget>[
                new Expanded(
                    child: new TextField(
                  controller: _textEditingController,
                  autofocus: false,
                  decoration: InputDecoration(
                    labelText: 'Add new allergen',
                  ),
                ))
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Save'),
                  onPressed: () {
                    addNewAllergen(_textEditingController.text.toString());
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  Widget showAllergyList() {
    if (_allergenList.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _allergenList.length,
          itemBuilder: (BuildContext context, int index) {
            String allergen = _allergenList[index];
            var key = _allergyKeys[index];
            return Dismissible(
              key: Key(allergen),
              background: Container(color: Colors.red),
              onDismissed: (direction) async {
                deleteAllergen(allergen, key, index);
              },
              child: ListTile(
                title: Text(
                  allergen,
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
            );
          });
    } else {
      return Center(
          child: Text(
        "Hurray. You have no allergies",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          title: new Text('Allergies'),
        ),
        body: showAllergyList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showAddAllergenDialog(context);
          },
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
