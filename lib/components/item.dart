import 'package:firebase_database/firebase_database.dart';

class Item {
  String ingredients;
  String itemName;
  String quantity;
  String userId;
  String expiry;
  String key;
  String image;
  Item(this.userId);

  Item.fromSnapshot(DataSnapshot snapshot)
      : ingredients = snapshot.value["Ingredients"],
        image = snapshot.value['image'],
        expiry = snapshot.value['Expiration Date'],
        itemName = snapshot.value["Item Name"];

  toJson() {
    return {
      "itemName": itemName,
      "ingredients": ingredients,
      "image": image,
      'expiry': expiry,
    };
  }
}
