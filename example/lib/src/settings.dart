import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  Settings({Key? key}) : super(key: key);
  @override
  _MySettings createState() => _MySettings();
}

class _MySettings extends State<Settings> {
  final TextEditingController _numberController = TextEditingController();

  late SharedPreferences _preferences;
  // Initial Selected Value
  bool voiceOnly = true;
  var dropdownvalue = 'Audio Call';
  var items = [
    'Audio Call',
    'Video Call',
  ];

  @override
  initState() {
    super.initState();
    _loadSettings();
  }

  @override
  deactivate() {
    super.deactivate();
    _saveSettings();
  }

  void _loadSettings() async {
    _preferences = await SharedPreferences.getInstance();
    setState(() {
      _numberController.text = _preferences.getString('number') ?? '';
      voiceOnly = _preferences.getBool('voiceOnly') ?? true;
      dropdownvalue = voiceOnly ? 'Audio Call' : 'Video Call';
    });
  }

  void _saveSettings() {
    _preferences.setString('number', _numberController.text);
    _preferences.setBool('voiceOnly', voiceOnly);
  }

  void _alert(BuildContext context, String alertFieldName) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$alertFieldName is empty'),
          content: Text('Please enter $alertFieldName!'),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleSave(BuildContext context) {
    if (_numberController.text == '') {
      _alert(context, "Number Not Valid");
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Call Settings"),
      ),
      body: Align(
        alignment: Alignment(0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Dial Number',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  ),
                ),
                TextFormField(
                  controller: _numberController,
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10.0),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12),
                    ),
                  ),
                ),
                DropdownButton(
                  value: dropdownvalue,
                  // icon: const Icon(Icons.call),
                  items: items.map((String items) {
                    return DropdownMenuItem(
                      value: items,
                      child: Text(items),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownvalue = newValue!;
                      newValue == 'Audio Call'
                          ? voiceOnly = true
                          : voiceOnly = false;
                    });
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 18.0, 0.0, 0.0),
              child: Container(
                height: 48.0,
                width: 160.0,
                child: MaterialButton(
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                  color: Colors.blue,
                  textColor: Colors.white,
                  onPressed: () => _handleSave(context),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
