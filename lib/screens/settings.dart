import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  var _selected_repeat;
  var _selected_interval;
  var _repeat = [
    'daily',
    'weekly on Monday',
    'weekly on Tuesday',
    'weekly on Wednesday',
    'weekly on Thursday',
    'weekly on Friday',
    'weekly on Saturday',
    'weekly on Sunday',
  ];
  var _intervals = ['week', 'month'];
  var _prefs;

  setSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _selected_repeat = _prefs.getString('spinal_repeat') ?? 'daily';
    _selected_interval = _prefs.getString('spinal_interval') ?? 'week';
  }

  @override
  void initState() {
    super.initState();
    setSharedPreferences();
  }

  showRepeatDialogue(BuildContext context) async {
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              height: 200,
              width: 350.0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
//                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Remind me ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        DropdownButton<String>(
                          iconEnabledColor: Color(0xFF3EB16F),
//                          hint: Text(
//                            _selected_repeat,
//                            style: TextStyle(
//                                fontSize: 10,
//                                color: Colors.black,
//                                fontWeight: FontWeight.w400),
//                          ),
                          elevation: 4,
                          value: _selected_repeat,
                          items: _repeat.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (newVal) {
                            setState(() {
                              _selected_repeat = newVal;
                            });
                          },
                        ),
                        Text(
                          "a",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        DropdownButton<String>(
                          iconEnabledColor: Color(0xFF3EB16F),
//                          hint: Text(
//                            _selected_interval,
//                            style: TextStyle(
//                                fontSize: 10,
//                                color: Colors.black,
//                                fontWeight: FontWeight.w400),
//                          ),
                          elevation: 4,
                          value: _selected_interval,
                          items: _intervals.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (newVal) {
                            setState(() {
                              _selected_interval = newVal;
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(
                          width: 100.0,
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: const Color(0xFF1BC0C5),
                          ),
                        ),
                        SizedBox(
                          width: 100.0,
                          child: RaisedButton(
                            onPressed: () {
                              _prefs.setString(
                                  'spinal_repeat', _selected_repeat);
                              _prefs.setString(
                                  'spinal_interval', _selected_interval);
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Save",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: const Color(0xFF1BC0C5),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: 'Notifications',
            tiles: [
              SettingsTile(
                title: 'Set Time',
                subtitle: 'Set the time of reminder',
                leading: Icon(
                  Icons.timer,
                  size: 27.0,
                ),
                onTap: () async {
                  Future<TimeOfDay> selectedTimeRTL = (await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: 7, minute: 0),
                    builder: (BuildContext context, Widget child) {
                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: child,
                      );
                    },
                  )) as Future<TimeOfDay>;
                },
              ),
              SettingsTile(
                title: 'Set Frequency',
                subtitle: 'Set the frequency of reminder',
                leading: Icon(
                  Icons.repeat,
                  size: 27.0,
                ),
                onTap: () async {
                  showRepeatDialogue(context);
                },
              ),
              SettingsTile.switchTile(
                title: 'Alert',
                subtitle: 'Alert new item added',
                leading: Icon(Icons.add_alert),
                switchValue: true,
                onToggle: (bool value) {
                  setState(() {});
                },
              ),
            ],
          ),
          SettingsSection(
            title: 'Account',
            tiles: [
              SettingsTile(title: 'Phone number', leading: Icon(Icons.phone)),
              SettingsTile(title: 'Email', leading: Icon(Icons.email)),
              SettingsTile(title: 'Sign out', leading: Icon(Icons.exit_to_app)),
            ],
          ),
          SettingsSection(
            title: 'Secutiry',
            tiles: [
              SettingsTile.switchTile(
                title: 'Lock app in background',
                leading: Icon(Icons.phonelink_lock),
                switchValue: true,
                onToggle: (bool value) {
                  setState(() {});
                },
              ),
              SettingsTile.switchTile(
                  title: 'Use fingerprint',
                  leading: Icon(Icons.fingerprint),
                  onToggle: (bool value) {},
                  switchValue: false),
              SettingsTile.switchTile(
                title: 'Change password',
                leading: Icon(Icons.lock),
                switchValue: true,
                onToggle: (bool value) {},
              ),
            ],
          ),
          SettingsSection(
            title: 'Misc',
            tiles: [
              SettingsTile(
                  title: 'Terms of Service', leading: Icon(Icons.description)),
              SettingsTile(
                  title: 'Open source licenses',
                  leading: Icon(Icons.collections_bookmark)),
            ],
          )
        ],
      ),
    );
  }
}
