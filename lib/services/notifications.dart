import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:spinal_flutter/screens/main_inventory_screen.dart';

Future<void> showDailyAtTime(TimeOfDay selectedTime) async {
  var time = Time(selectedTime.hour, selectedTime.minute, 0);
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'repeatDailyAtTime channel id',
      'repeatDailyAtTime channel name',
      'repeatDailyAtTime description');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.showDailyAtTime(
      0,
      'Items about to expire in a week',
      'Tap to view',
      time,
      platformChannelSpecifics);
}

String _toTwoDigitString(int value) {
  return value.toString().padLeft(2, '0');
}

Future<void> scheduleNotification() async {
  var scheduledNotificationDateTime = DateTime.now().add(Duration(seconds: 5));
  var vibrationPattern = Int64List(4);
  vibrationPattern[0] = 0;
  vibrationPattern[1] = 1000;
  vibrationPattern[2] = 5000;
  vibrationPattern[3] = 2000;

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your other channel id',
      'your other channel name',
      'your other channel description',
      icon: 'ic_launcher',
      vibrationPattern: vibrationPattern,
      enableLights: true,
      color: const Color.fromARGB(255, 255, 0, 0),
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500);
  var iOSPlatformChannelSpecifics =
      IOSNotificationDetails(sound: 'slow_spring_board.aiff');
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.schedule(
      0,
      'scheduled title',
      'scheduled body',
      scheduledNotificationDateTime,
      platformChannelSpecifics);
}

Future<void> showWeeklyAtDayAndTime() async {
  var time = Time(10, 0, 0);
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'show weekly channel id',
      'show weekly channel name',
      'show weekly description');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
      0,
      'show weekly title',
      'Weekly notification shown on Monday at approximately ${_toTwoDigitString(time.hour)}:${_toTwoDigitString(time.minute)}:${_toTwoDigitString(time.second)}',
      Day.Monday,
      time,
      platformChannelSpecifics);
}
