import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spinal_flutter/services/auth.dart';
import 'package:spinal_flutter/widgets/customDrawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:spinal_flutter/components/item.dart';
import 'package:spinal_flutter/screens/item_information.dart';

FirebaseUser user;

class InventoryScreen extends StatefulWidget {
  static const String id = 'inventory_screen';
  final FirebaseUser currentUser;

  InventoryScreen(this.currentUser);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  String userUID;
  DatabaseReference _database;
  StreamSubscription<Event> _onAddedSubscription;
  StreamSubscription<Event> _onChangedSubscription;
  StreamSubscription<Event> _onDeletedSubscription;
  AnimationController controller;
  Animation animation;
  List<Item> _itemsList;

  @override
  void initState() {
    super.initState();
    _itemsList = new List();
    controller = AnimationController(
        duration: Duration(milliseconds: 3000), vsync: this);
    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(controller);
    controller.forward();
    controller.addListener(() {
      setState(() {});
    });
    userUID = widget.currentUser.uid;
    _database = FirebaseDatabase.instance.reference().child(userUID);
    _database.keepSynced(true);
//    //_database.once().then((DataSnapshot snapshot) {
//      print('Connected to second database and read ${snapshot.value}');
//    });
    _onAddedSubscription = _database.onChildAdded.listen((onEntryAdded));
    _onDeletedSubscription = _database.onChildRemoved.listen((onEntryRemoved));
  }

  @override
  void dispose() {
    _onAddedSubscription.cancel();
    _onChangedSubscription.cancel();
    _onDeletedSubscription.cancel();
    controller.dispose();
    super.dispose();
  }

  onEntryAdded(Event event) {
    if (event.snapshot.key != 'Allergies') {
      setState(() {
        _itemsList.add(Item.fromSnapshot(event.snapshot));
      });
    }
  }

  onEntryRemoved(Event event) {
    setState(() {
      String item = event.snapshot.value['Item Name'];
      for (int i = 0; i < _itemsList.length; i++) {
        if (_itemsList[i].itemName == item) _itemsList.removeAt(i);
      }
    });
  }

//  addNewItem(String todoItem) {
//    if (todoItem.length > 0) {
//      Item todo = new Item(todoItem.toString(), widget.userId, false);
//      _database.reference().child("todo").push().set(todo.toJson());
//    }
//  }
//
//  updateItem(Item todo) {
//    //Toggle completed
//    todo.completed = !todo.completed;
//    if (todo != null) {
//      _database.reference().child("todo").child(todo.key).set(todo.toJson());
//    }
//  }

//  deleteItem(String todoId, int index) {
//    _database.reference().child("todo").child(todoId).remove().then((_) {
//      print("Delete $todoId successful");
//      setState(() {
//        _todoList.removeAt(index);
//      });
//    });
//  }

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
                Uint8List image = base64.decode(_itemsList[index].image);
                String itemName = _itemsList[index].itemName;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ItemInformation(_itemsList[index])),
                    );
                  },
                  child: Card(
                    color: Colors.white,
                    elevation: 10.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Hero(
                          tag: itemName,
                          child: Container(
                            child: Image.memory(image),
                            width: 150,
                            height: 150,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: _itemsList.length,
            ),
          ),
        ],
      ),
      drawer: SafeArea(
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(30.0),
              topRight: Radius.circular(30.0)),
          child: CustomDrawer(_database),
        ),
      ),
    );
  }
}
