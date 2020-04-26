import 'package:firebase_database/firebase_database.dart';

class Item {
  String ingredients;
  String itemName;
  String quantity;
  String userId;
  dynamic nutrients;
  dynamic purchaseDate;
  dynamic expiry;
  String key;
  String image;
  Item(this.userId);

  Item.fromSnapshot(DataSnapshot snapshot)
      : image = snapshot.value['image'],
        expiry = snapshot.value['Expiration Date'],
        nutrients = snapshot.value['Nutrition List'],
        purchaseDate = snapshot.value['Purchase Date'],
        quantity = snapshot.value['Quantity'],
        itemName = snapshot.value["Item Name"],
        ingredients = snapshot.value["Ingredients"];

  toJson() {
    return {
      "itemName": itemName,
      "image": image,
      'expiry': expiry,
      'nutrionList': nutrients,
      'purchaseDate': purchaseDate,
      'quantity': quantity,
      "ingredients": ingredients,
    };
  }
}
