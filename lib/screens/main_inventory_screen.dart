import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  final currentUser;

  InventoryScreen(this.currentUser);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

enum add { barcode, camera }

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  String userUID;
  DatabaseReference _database;
  StreamSubscription<Event> _onAddedSubscription;
  StreamSubscription<Event> _onChangedSubscription;
  StreamSubscription<Event> _onDeletedSubscription;
  AnimationController controller;
  final controllerGrid = DragSelectGridViewController();
  bool selected = false;

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
    controllerGrid.addListener(scheduleRebuild);
    userUID = widget.currentUser.uid;
//    userUID = "a1ah0KnneZg75X0dSJSXBdTtCFr1";
    _database = FirebaseDatabase.instance.reference().child(userUID);
    _database.keepSynced(true);
    _onAddedSubscription = _database.onChildAdded.listen((onEntryAdded));
    _onDeletedSubscription = _database.onChildRemoved.listen((onEntryRemoved));
  }

  void scheduleRebuild() => setState(() {});

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

  deleteItem(String itemName, int index) {
    _database.child(itemName).remove().then((_) {
      print("Delete $itemName successful");
      setState(() {
        _itemsList.removeAt(index);
      });
    });
  }

  checkSelected() {
    List<Widget> actions = List();
    if (!selected) {
      actions.add(
        PopupMenuButton(
          onSelected: (add result) {
            print(result);
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<add>>[
            const PopupMenuItem<add>(
              value: add.barcode,
              child: Text('Add item using barcode'),
            ),
            const PopupMenuItem<add>(
              value: add.camera,
              child: Text('Add item using picture'),
            ),
          ],
          icon: IconButton(
            icon: Icon(
              Icons.add,
              size: 30.0,
              color: Colors.black,
            ),
            onPressed: null,
          ),
          elevation: 10.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        ),
      );
      actions.add(
        IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: () async {
            await Provider.of<AuthService>(context, listen: false).logout();
          },
        ),
      );
    } else {
      actions.add(
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {},
        ),
      );
    }
    return actions;
  }

//  RelativeRect menuPosition(BuildContext c) {
//    final RenderSliver bar = c.findRenderObject();
//    final RenderBox overlay = Overlay.of(c).context.findRenderObject();
//    final RelativeRect position = RelativeRect.fromRect(
//      Rect.fromPoints(
//        bar.localToGlobal(bar.size.bottomRight(Offset.zero), ancestor: overlay),
//        bar.localToGlobal(bar.size.bottomRight(Offset.zero), ancestor: overlay),
//      ),
//      Offset.zero & overlay.size,
//    );
//    return position;
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      body: CustomScrollView(
        slivers: _itemsList.isEmpty ? EmptyWidget() : buildCustomScrollView(),
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

//
  List<Widget> buildCustomScrollView() {
    return <Widget>[
      SliverAppBar(
        expandedHeight: 250.0,
        floating: false,
        pinned: true,
        actions: checkSelected(),
        elevation: 50,
        backgroundColor: Colors.amber[50],
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          title: Text(
            'Current Inventory',
            style: TextStyle(
              color: Colors.black54,
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

            return _itemsList.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ItemInformation(_itemsList[index])),
                      );
                    },
                    onLongPress: () {
                      deleteItem(itemName, index);

//                    print("How are you");
//                    final result = await showMenu(
//                      context: context,
//                      items: <PopupMenuEntry>[
//                        PopupMenuItem(
//                          value: index,
//                          child: Row(
//                            children: <Widget>[
//                              Icon(Icons.delete),
//                              Text("Delete"),
//                            ],
//                          ),
//                        )
//                      ],
//                      position: menuPosition(context),
//                    );
//                    print(result);
                    },
                    child: Card(
                      color: Colors.white,
                      elevation: 10.0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                  )
                : Text('You have no food at your home. Go to grocery store');
          },
          childCount: _itemsList.length,
        ),
      ),
    ];
  }

  List<Widget> EmptyWidget() {
    return <Widget>[
      SliverAppBar(
        expandedHeight: 250.0,
        floating: false,
        pinned: true,
        actions: checkSelected(),
        elevation: 50,
        backgroundColor: Colors.amber[50],
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          title: Text(
            'Current Inventory',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildListDelegate(
          [
            Container(
              child: Image.asset("images/groceries_shopping_logo.png"),
            ),
            Text(
              'You need to go Shopping',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.brown,
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ];
  }
}
