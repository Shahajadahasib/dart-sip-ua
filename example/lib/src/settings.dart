import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sip_ua/sip_ua.dart';

class Settings extends StatefulWidget {
  final SIPUAHelper? _helper;
  Settings(this._helper, {Key? key}) : super(key: key);
  @override
  _MySettings createState() => _MySettings();
}

class _MySettings extends State<Settings> implements SipUaHelperListener {
  final TextEditingController _numberController = TextEditingController();

  late SharedPreferences _preferences;
  late RegistrationState _registerState;

  SIPUAHelper? get helper => widget._helper;

  @override
  initState() {
    super.initState();
    _registerState = helper!.registerState;
    helper!.addSipUaHelperListener(this);
    _loadSettings();
  }

  @override
  deactivate() {
    super.deactivate();
    helper!.removeSipUaHelperListener(this);
    _saveSettings();
  }

  void _loadSettings() async {
    _preferences = await SharedPreferences.getInstance();
    setState(() {
      _numberController.text = _preferences.getString('number') ?? '';
    });
  }

  void _saveSettings() {
    _preferences.setString('number', _numberController.text);
  }

  @override
  void registrationStateChanged(RegistrationState state) {
    setState(() {
      _registerState = state;
    });
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
        title: Text("SIP Account"),
      ),
      body: Align(
        alignment: Alignment(0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(48.0, 18.0, 48.0, 18.0),
                  child: Center(
                    child: Text(
                      'Register Status: ${EnumHelper.getName(_registerState.state)}',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Center(
                  child: Text(
                    'Dial Number',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
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

  @override
  void callStateChanged(Call call, CallState state) {
    //NO OP
  }

  @override
  void transportStateChanged(TransportState state) {}

  @override
  void onNewMessage(SIPMessageRequest msg) {
    // NO OP
  }

  @override
  void onNewNotify(Notify ntf) {
    // NO OP
  }
}
