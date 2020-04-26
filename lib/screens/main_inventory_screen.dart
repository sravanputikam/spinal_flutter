import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:spinal_flutter/services/auth.dart';
import 'package:spinal_flutter/widgets/customDrawer.dart';
import 'package:spinal_flutter/widgets/inventory_selector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:spinal_flutter/components/item.dart';
import 'package:spinal_flutter/screens/item_information.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:spinal_flutter/widgets/rounded_button.dart';

import '../validators.dart';

Future<String> loadAsset() async {
  return await rootBundle.loadString('assets/config.json');
}

FirebaseUser user;

class InventoryScreen extends StatefulWidget {
  static const String id = 'inventory_screen';
  final currentUser;

  InventoryScreen(this.currentUser);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

enum add { barcode, camera }

class DummyItem {
  String itemName;
  String image;
  String expiry;
  DummyItem(this.itemName, this.image, this.expiry);
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  String userUID;
  DatabaseReference _database;

  StreamSubscription<Event> _onAddedSubscription;
  StreamSubscription<Event> _onChangedSubscription;
  StreamSubscription<Event> _onDeletedSubscription;

  StreamSubscription<Event> _onAllergenAddedSubscription;
  StreamSubscription<Event> _onAllergenChangedSubscription;
  StreamSubscription<Event> _onAllergenDeletedSubscription;

  AnimationController controller;
  final controllerGrid = DragSelectGridViewController();
  bool selected = false;
  TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  List<Widget> actions = List();
  Animation animation;
  List<Item> _itemsList;
  List _allergenList = List();
  String searchItem;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  static int notifyCount = 0;

  _showItemDialog(List data, String message, int reason) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          final mediaQuery = MediaQuery.of(context);
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              height: mediaQuery.size.height - 100.0,
              width: 350.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Center(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  reason == 2
                      ? Center(
                          child: Container(
                            child: Text(
                              'Items below contain: ${data.toString()}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          height: 0.0,
                          width: 0.0,
                        ),
                  buildExpandedGridView(data,
                      type: 'allergy', imageHeight: 100.0, imageWidth: 100.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(right: 0.0),
                        child: RoundedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          title: 'Done',
                          colour: Colors.greenAccent,
//                          Text(
//                            'Done',
//                            style: TextStyle(color: Colors.greenAccent),
//                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  _alertUser(Map<String, dynamic> message) {
    String type = message['data']['alertType'];
    if (type == 'Allergy') {
      dynamic allergies = message['data']['allergy'];
      allergies = allergies.split(',');
      _showItemDialog(allergies, "Allergen Alert", 2);
//            _alertUser(allergies, type);
    } else {
      dynamic expiry_items = message['data']['expiry'];
      expiry_items = expiry_items.split(',');
      _showItemDialog(expiry_items, "Expiry Alert", 1);
    }
  }

  @override
  void initState() {
    super.initState();

    _itemsList = new List();
    controllerGrid.addListener(scheduleRebuild);
    userUID = widget.currentUser.uid;
    _database =
        FirebaseDatabase.instance.reference().child('Users').child(userUID);
    _database.keepSynced(true);
    _onAddedSubscription =
        _database.child('Items').onChildAdded.listen((onEntryAdded));
    _onDeletedSubscription =
        _database.child('Items').onChildRemoved.listen((onEntryRemoved));

    _onAllergenAddedSubscription = _database
        .child("Allergies")
        .onChildAdded
        .listen((onAllergenEntryAdded));
    _onDeletedSubscription = _database
        .child("Allergies")
        .onChildRemoved
        .listen((onAllergenEntryRemoved));

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        if (notifyCount % 2 == 0) {
//          print("onMessage: $message");
          _alertUser(message);
        }
        notifyCount++;
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
//        _navigateToItemDetail(message);
        _alertUser(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
//        _navigateToItemDetail(message);
        _alertUser(message);
      },
    );
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      String _homeScreenText = "Push Messaging token: $token";
      print(_homeScreenText);
    });
    _firebaseMessaging.subscribeToTopic("AllergyAlert");
    actions = checkSelected();
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

  onAllergenEntryAdded(Event event) {
    setState(() {
//      print(event.snapshot.value);
      _allergenList.add(event.snapshot.value);
    });
  }

  onAllergenEntryRemoved(Event event) {
    setState(() {
      String allergy = event.snapshot.value;
      _allergenList.remove(allergy);
    });
  }

//  addNewItem(String todoItem) {
//    if (todoItem.length > 0) {
//      Item todo = new Item(todoItem.toString(), widget.userId, false);
//      _database.reference().child("todo").push().set(todo.toJson());
//    }
//  }
//

  deleteItem(String itemName, int index) {
    _database.child(itemName).remove().then((_) {
      print("Delete $itemName successful");
      setState(() {
        _itemsList.removeAt(index);
      });
    });
  }

  Future<List> search(String search) async {
    await Future.delayed(Duration(seconds: 2));
    List<DummyItem> dItems = [];
    if (_itemsList.isNotEmpty) {
      for (int i = 0; i < _itemsList.length; i++) {
        if (_itemsList[i].itemName.contains(search)) {
          dItems.add(DummyItem(_itemsList[i].itemName, _itemsList[i].image,
              _itemsList[i].expiry));
        }
      }
    }
    return dItems;
  }

  checkSelected() {
    List<Widget> action = [];
    if (selected == false) {
      action.add(
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
              color: Colors.white,
            ),
            onPressed: null,
          ),
          elevation: 10.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        ),
      );
      action.add(
        IconButton(
          icon: Icon(
            Icons.exit_to_app,
            size: 25.0,
            color: Colors.white,
          ),
          onPressed: () async {
            await Provider.of<AuthService>(context, listen: false).logout();
          },
        ),
      );
    } else {
      action.add(
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {},
        ),
      );
    }
    return action;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Colors.red[400],
      appBar: AppBar(
        actions: actions,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'Inventory',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
            _searchFocus.unfocus();
          }
        },
        child: Column(
          children: <Widget>[
            InventorySelector(),
            Container(
              width: mediaQuery.size.width,
              height: 50.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0)),
              ),
              child: TextField(
                showCursor: true,
                controller: searchController,
                focusNode: _searchFocus,
                decoration: InputDecoration(
                  hasFloatingPlaceholder: false,
                  labelText: "Search",
//                  hintText: "Search Current Inventory",
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: PopupFilterButton(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                ),
                onEditingComplete: () {
                  print(searchController.value);
                },
                onSubmitted: (text) {
                  print(text);
                  _searchFocus.unfocus();
                },
              ),
            ),
            buildExpandedGridView(_itemsList)
          ],
        ),
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

  buildExpandedGridView(dynamic itemsList,
      {type = 'main', imageWidth = 150.0, imageHeight = 150.0}) {
    List<Item> dummy = List<Item>();
    if (type == 'allergy') {
      for (int i = 0; i < _itemsList.length; i++) {
        for (int j = 0; j < itemsList.length; j++) {
          String itemName = itemsList[j];
          if (_itemsList[i].itemName.contains(itemName) == true) {
            dummy.add(_itemsList[i]);
          }
        }
      }
      itemsList = dummy;
    }
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(top: 10.0),
        color: Colors.white,
        child: itemsList.length == 0
            ? showCircularProgress(true)
            : GridView.builder(
                itemCount: itemsList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemBuilder: (BuildContext context, int index) {
                  dynamic item = itemsList[index];
                  return buildGridTile(index, item, imageWidth, imageHeight);
                },
              ),
      ),
    );
  }

  buildGridTile(index, dynamic item, imageWidth, imageHeight) {
    Uint8List image = base64.decode(item.image);
    String itemName = item.itemName;
    bool checkAllergen = true;
    _allergenList.forEach((allergen) {
      if (item.ingredients.contains(allergen)) checkAllergen = false;
    });
    return Container(
      padding: EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ItemInformation(item)),
          );
        },
        onLongPress: () {
//          deleteItem(itemName, index);
        },
        child: Card(
          color: Colors.white,
          elevation: 10.0,
          child: Center(
            child: Hero(
              tag: itemName,
              child: Stack(children: [
                Center(
                  child: Container(
                    child: Center(child: Image.memory(image)),
                    width: imageWidth,
                    height: imageHeight,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: 5.0, top: 3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                        width: 10.0,
                      ),
                      Image.asset(
                        'images/yellow_clock.png',
                        height: 20.0,
                        width: 20.0,
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      Image.asset(
                        checkAllergen
                            ? 'images/safe_icon.png'
                            : 'images/unsafe_icon.png',
                        height: 20.0,
                        width: 20.0,
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget EmptyWidget() {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            child: Image.asset("images/groceries_shopping_logo.png"),
          ),
          Text(
            'You need to go Shopping',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.brown, fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class PopupFilterButton extends StatelessWidget {
  const PopupFilterButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      padding: EdgeInsets.all(0.0),
      onSelected: (add result) {
        print(result);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<add>>[
        const PopupMenuItem<add>(
          value: add.barcode,
          child: Text('Expiry Date'),
        ),
        const PopupMenuItem<add>(
          value: add.camera,
          child: Text('A to Z'),
        ),
        const PopupMenuItem<add>(
          value: add.camera,
          child: Text('Z to A'),
        )
      ],
      icon: IconButton(
        icon: Icon(
          Icons.filter_list,
          size: 25.0,
//          color: Colors.white,
        ),
        onPressed: null,
      ),
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
        side: BorderSide(),
      ),
    );
  }
}
