import 'package:flutter/material.dart';

calculateDifference(dynamic snapshot) {
  dynamic expiry = snapshot.value['Expiration Date'];
  dynamic servingsLeft = snapshot.value['Servings Left'];
  print(snapshot.value['Item Name']);
  print(servingsLeft);
  if (servingsLeft != null && servingsLeft == '0') {
    return 0;
  }
  var expiration = expiry[1].split('/');
  var item_expiration = DateTime(int.parse(expiration[2]),
      int.parse(expiration[0]), int.parse(expiration[1]));
  var currentDate = DateTime.now();
  final difference = item_expiration.difference(currentDate).inDays + 1;
  print(difference);
  return difference;
}
