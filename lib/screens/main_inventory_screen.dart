import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
import 'package:rxdart/subjects.dart';

import '../validators.dart';

Future<String> loadAsset() async {
  return await rootBundle.loadString('assets/config.json');
}

FirebaseUser user;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

NotificationAppLaunchDetails notificationAppLaunchDetails;

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}

final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

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
  bool empty = false;

  List<Widget> actions = List();
  Animation animation;
  List<Item> _itemsList;
  List _allergenList = List();
  String searchItem;
  String filtering = 'initialFilter';
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  static int notifyCount = 0;
  var _items = List<Item>();

  String quantity;
  String servings;
  String servingsLeft;
  String quantityLeft;

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
              padding: EdgeInsets.only(top: 10.0),
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
                  buildExpandedGridView(reason == 2 ? List<Item>() : data,
                      filter: 'allergy', imageHeight: 100.0, imageWidth: 100.0),
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
      _showItemDialog(allergies, "Allergy Alert", 2);
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
    DatabaseReference itemDatabase;
    itemDatabase = _database.child('Items');

    _database.child('Items').once().then((DataSnapshot snapshot) async {
      Map<dynamic, dynamic> values = snapshot.value;
      print("GetLost");
//      print(values.length);
      try {
        if (values.length == 0) {
          empty = true;
        }
      } catch (e) {
        empty = true;
      }
    });

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

    WidgetsFlutterBinding.ensureInitialized();
//    notificationAppLaunchDetails =
//        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    var initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
          didReceiveLocalNotificationSubject.add(ReceivedNotification(
              id: id, title: title, body: body, payload: payload));
        });
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
      }
      List<Item> expiryItems = List<Item>();
      _showItemDialog(expiryItems, "Item Expiring in a Week", 1);

//      selectNotificationSubject.add(payload);
    });

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

  deleteItem(String itemName, int index) {
    _database.child(itemName).remove().then((_) {
      print("Delete $itemName successful");
      setState(() {
        _itemsList.removeAt(index);
      });
    });
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

  filterSearchResults(String query, String filter) {
    List<Item> dummySearchList = _itemsList;
    print(dummySearchList.length);
    if (query.length > 1 && filter == 'search') {
      print(query);
      List<Item> dummyListData = List<Item>();
      dummySearchList.forEach((item) {
        print(item.itemName);
        if (item.itemName.toLowerCase().contains(query.toLowerCase()) == true) {
          dummyListData.add(item);
        }
      });
      setState(() {
        print(dummyListData.length);
        _items.clear();
        _items.addAll(dummyListData);
      });
      return;
    } else if (filter == 'A to Z') {
//      dummySearchList.removeWhere((item) => item.daysLeft <= 0);
      dummySearchList.sort((a, b) =>
          a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()));
      print('Helloo filtering');
      setState(() {
        filtering = 'A to Z';
        _items.clear();
        _items.addAll(dummySearchList);
      });
      return;
    } else if (filter == 'Z to A') {
//      dummySearchList.removeWhere((item) => item.daysLeft <= 0);
      dummySearchList.sort((a, b) =>
          b.itemName.toLowerCase().compareTo(a.itemName.toLowerCase()));
      print('Helloo filtering');
      setState(() {
        filtering = 'Z to A';
        _items.clear();
        _items.addAll(dummySearchList);
      });
      return;
    } else if (filter == 'expired') {
      filtering = 'expired';
      print(dummySearchList.length);
      dummySearchList.removeWhere((item) => item.daysLeft > 0);
      dummySearchList.removeWhere((item) => item.quantity == '0');
      setState(() {
        _items.clear();
        _items.addAll(dummySearchList);
      });
      return;
    } else if (filter == 'Expiry Date') {
      filtering = 'Expiry Date';
      dummySearchList.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
      setState(() {
        _items.clear();
        _items.addAll(dummySearchList);
      });
      return;
    } else {
      filtering = 'current';
      dummySearchList.removeWhere((item) => item.daysLeft <= 0);
      setState(() {
        _items.clear();
        _items.addAll(dummySearchList);
      });
      return;
    }
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
        title: Hero(
          tag: 'titleTage',
          child: Text(
            'SPINAL',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.0,
            ),
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
              padding: EdgeInsets.only(top: 5.0),
              height: 50.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    child: TextField(
                      showCursor: true,
                      controller: searchController,
                      focusNode: _searchFocus,
                      decoration: InputDecoration(
                        hasFloatingPlaceholder: false,
                        labelText: "Search",
//                  hintText: "Search Current Inventory",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                      ),
                      onEditingComplete: () {
                        print(searchController.value);
                      },
                      onSubmitted: (text) {
                        filterSearchResults(text, 'search');
                        _searchFocus.unfocus();
                      },
                    ),
                    width: 300.0,
                  ),
                  popUpFilterButton(),
                ],
              ),
            ),
            buildExpandedGridView(_items, filter: filtering)
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

  buildExpandedGridView(List<Item> itemsList,
      {filter = 'initialFilter', imageWidth = 150.0, imageHeight = 150.0}) {
    if (itemsList.length == 0) {
      itemsList.addAll(_itemsList);
    }
    List<Item> dummy = List<Item>();
    if (filter == 'allergy') {
      for (int i = 0; i < _itemsList.length; i++) {
        for (int j = 0; j < _allergenList.length; j++) {
          String allergenName = _allergenList[j];
          if (_itemsList[i].ingredients.contains(allergenName) == true &&
              _itemsList[i].daysLeft > 0) {
            dummy.add(_itemsList[i]);
          }
        }
      }
      itemsList.clear();
      itemsList.addAll(dummy);
    } else if (filter == 'initialFilter') {
      itemsList.removeWhere((item) => item.daysLeft <= 0);
    } else if (filter == 'expiryAlert') {
      dummy.addAll(_itemsList);
      dummy.removeWhere((item) => item.daysLeft > 8);
      dummy.removeWhere((item) => item.daysLeft < 0);
      itemsList.clear();
      itemsList.addAll(dummy);
    }
    if (empty == false && _itemsList.length > 0) {
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
                    return buildGridTile(
                        filter, index, item, imageWidth, imageHeight);
                  },
                ),
        ),
      );
    } else {
      return Expanded(
        child: Container(
          padding: EdgeInsets.only(left: 5.0, right: 5.0),
          color: Colors.white,
          child: Image.asset(
            'images/empty_fridge.png',
          ),
        ),
      );
    }
  }

  buildGridTile(type, index, Item item, imageWidth, imageHeight) {
    Uint8List image = base64.decode(item.image);
    String itemName = item.itemName;
    bool checkAllergen = true;
    _allergenList.forEach((allergen) {
      if (item.ingredients.contains(allergen)) checkAllergen = false;
    });
    String expirationImage;

    if (item.daysLeft <= 0)
      expirationImage = 'images/expired_icon.png';
    else if (item.daysLeft <= 7 && item.daysLeft >= 1)
      expirationImage = 'images/red_clock.png';
    else if (7 < item.daysLeft && item.daysLeft <= 14)
      expirationImage = 'images/yellow_clock.png';
    else
      expirationImage = 'images/green_clock.png';
    return Container(
      padding: EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () async {
          String left = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ItemInformation(item, _allergenList,
                    _database, quantityLeft, servingsLeft)),
          );
          if (left == '0') {
            setState(() {
              int mainIndex =
                  _itemsList.indexWhere((element) => item == element);
              _itemsList[mainIndex].daysLeft = 0;
              filtering = 'initialFilter';
            });
          }
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
                    child: Center(
                        child: Image.memory(
                      image,
                      scale: 0.75,
                      filterQuality: FilterQuality.low,
                    )),
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
                        expirationImage,
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

  popUpFilterButton() {
    return PopupMenuButton(
      padding: EdgeInsets.all(0.0),
      onSelected: (result) {
        filterSearchResults('', result);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
        const PopupMenuItem(
          value: 'Expiry Date',
          child: Text('Expiry Date'),
        ),
        const PopupMenuItem(
          value: 'A to Z',
          child: Text('A to Z'),
        ),
        const PopupMenuItem(
          value: 'Z to A',
          child: Text('Z to A'),
        ),
        const PopupMenuItem(
          value: 'expired',
          child: Text('expired'),
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
