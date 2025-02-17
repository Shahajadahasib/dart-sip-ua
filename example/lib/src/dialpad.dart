import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sip_ua/sip_ua.dart';

import 'widgets/action_button.dart';

class DialPadWidget extends StatefulWidget {
  final SIPUAHelper? _helper;
  DialPadWidget(this._helper, {Key? key}) : super(key: key);
  @override
  _MyDialPadWidget createState() => _MyDialPadWidget();
}

class _MyDialPadWidget extends State<DialPadWidget>
    implements SipUaHelperListener {
  String? _dest;
  SIPUAHelper? get helper => widget._helper;
  TextEditingController? _textController;
  late SharedPreferences _preferences;

  String? receivedMsg;
  final Map<String, String> _wsExtraHeaders = {
    // 'Origin': ' https://tryit.jssip.net',
    // 'Host': 'tryit.jssip.net:10443'
  };
  @override
  initState() {
    super.initState();
    receivedMsg = "";
    _bindEventListeners();
    _loadSettings();
    _registerAccount();
  }

  void _loadSettings() async {
    _preferences = await SharedPreferences.getInstance();
    _dest =
        _preferences.getString('number') ?? 'No Emergency Number Added Yet!';
    _textController = TextEditingController(text: _dest);
    _textController!.text = _dest!;

    setState(() {});
  }

  void _registerAccount() async {
    _preferences = await SharedPreferences.getInstance();
    UaSettings settings = UaSettings();

    settings.webSocketUrl = _preferences.getString('ws_uri')!;
    settings.webSocketSettings.extraHeaders = _wsExtraHeaders;
    settings.webSocketSettings.allowBadCertificate = true;
    //settings.webSocketSettings.userAgent = 'Dart/2.8 (dart:io) for OpenSIPS.';

    settings.uri = _preferences.getString('sip_uri');
    settings.authorizationUser = _preferences.getString('auth_user');
    settings.password = _preferences.getString('password');
    settings.displayName = _preferences.getString('display_name');
    settings.userAgent = 'Dart SIP Client v1.0.0';
    settings.dtmfMode = DtmfMode.RFC2833;

    helper!.start(settings);
  }

  void _bindEventListeners() {
    helper!.addSipUaHelperListener(this);
  }

  Future<Widget?> _handleCall({
    required BuildContext context,
    required bool voiceOnly,
  }) async {
    var dest = _preferences.getString('number') ?? '';
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.fuchsia) {
      await Permission.microphone.request();
      await Permission.camera.request();
    }
    if (dest.isEmpty) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('No Number Added'),
            content: Text('Please Add Number in the settings menu!'),
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
      return null;
    }

    final mediaConstraints = <String, dynamic>{'audio': true, 'video': true};

    MediaStream mediaStream;

    if (kIsWeb && !voiceOnly) {
      mediaStream =
          await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
      mediaConstraints['video'] = false;
      MediaStream userStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      mediaStream.addTrack(userStream.getAudioTracks()[0], addToNative: true);
    } else {
      mediaConstraints['video'] = !voiceOnly;
      mediaStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    }

    helper!.call(dest, voiceonly: voiceOnly, mediaStream: mediaStream);
    _preferences.setString('dest', dest);
    return null;
  }

//back space

  // void _handleBackSpace([bool deleteAll = false]) {
  //   var text = _textController!.text;
  //   if (text.isNotEmpty) {
  //     setState(() {
  //       text = deleteAll ? '' : text.substring(0, text.length - 1);
  //       _textController!.text = text;
  //     });
  //   }
  // }

//input number handle
  // void _handleNum(String number) {
  //   setState(() {
  //     _textController!.text += number;
  //   });
  // }

  //number pad

  // List<Widget> _buildNumPad() {
  //   var labels = [
  //     [
  //       {'1': ''},
  //       {'2': 'abc'},
  //       {'3': 'def'}
  //     ],
  //     [
  //       {'4': 'ghi'},
  //       {'5': 'jkl'},
  //       {'6': 'mno'}
  //     ],
  //     [
  //       {'7': 'pqrs'},
  //       {'8': 'tuv'},
  //       {'9': 'wxyz'}
  //     ],
  //     [
  //       {'*': ''},
  //       {'0': '+'},
  //       {'#': ''}
  //     ],
  //   ];

  //   return labels
  //       .map(
  //         (row) => Padding(
  //           padding: const EdgeInsets.all(12),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: row
  //                 .map(
  //                   (label) => ActionButton(
  //                     title: label.keys.first,
  //                     subTitle: label.values.first,
  //                     onPressed: () => _handleNum(label.keys.first),
  //                     number: true,
  //                   ),
  //                 )
  //                 .toList(),
  //           ),
  //         ),
  //       )
  //       .toList();
  // }

  List<Widget> _buildDialPad() {
    return [
      Container(
        width: 350,
        color: Color.fromARGB(31, 99, 88, 88),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                // color: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: TextField(
                  keyboardType: TextInputType.none,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                  controller: _textController,
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 20,
      ),
      //number pad

      // Container(
      //   color: Colors.green,
      //   width: 300,
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.center,
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: _buildNumPad(),
      //   ),
      // ),

      //video audio buttons

      // Container(
      //   // color: Colors.black,
      //   width: 300,
      //   child: Padding(
      //     padding: const EdgeInsets.all(12),
      //     child: Row(
      //       crossAxisAlignment: CrossAxisAlignment.center,
      //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //       children: <Widget>[
      //         ActionButton(
      //           icon: Icons.videocam,
      //           onPressed: () =>
      //               _handleCall(context: context, voiceOnly: false),
      //         ),
      //         ActionButton(
      //           icon: Icons.dialer_sip,
      //           fillColor: Colors.green,
      //           onPressed: () => _handleCall(context: context, voiceOnly: true),
      //         ),
      //         //backspace

      //         // ActionButton(
      //         //   icon: Icons.keyboard_arrow_left,
      //         //   onPressed: () => _handleBackSpace(),
      //         //   onLongPress: () => _handleBackSpace(true),
      //         // ),
      //       ],
      //     ),
      //   ),
      // ),

      ActionButton(
        icon: Icons.dialer_sip,
        fillColor: Colors.green,
        onPressed: () => _handleCall(
            context: context, voiceOnly: _preferences.getBool('voiceOnly')!),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:
            Text('Status: ${EnumHelper.getName(helper!.registerState.state)}'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String value) {
              switch (value) {
                case 'account':
                  Navigator.pushNamed(context, '/register');
                  break;
                case 'about':
                  Navigator.pushNamed(context, '/about');
                  break;
                case 'settings':
                  Navigator.pushNamed(context, '/settings');
                  break;
                default:
                  break;
              }
            },
            icon: Icon(Icons.menu),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Icon(
                        Icons.account_circle,
                        color: Colors.black38,
                      ),
                    ),
                    SizedBox(
                      child: Text('Account'),
                      width: 64,
                    )
                  ],
                ),
                value: 'account',
              ),
              PopupMenuItem(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Icon(
                      Icons.info,
                      color: Colors.black38,
                    ),
                    SizedBox(
                      child: Text('About'),
                      width: 64,
                    )
                  ],
                ),
                value: 'about',
              ),
              PopupMenuItem(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Icon(
                      Icons.info,
                      color: Colors.black38,
                    ),
                    SizedBox(
                      child: Text('Settings'),
                      width: 64,
                    )
                  ],
                ),
                value: 'settings',
              )
            ],
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            // alignment: Alignment(0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Padding(
                //   padding: const EdgeInsets.all(6.0),
                //   child: Center(
                //       child: Text(
                //     'Status: ${EnumHelper.getName(helper!.registerState.state)}',
                //     style: TextStyle(fontSize: 18, color: Colors.black54),
                //   )),
                // ),
                // Padding(
                //   padding: const EdgeInsets.all(6.0),
                //   child: Center(
                //       child: Text(
                //     'Received Message: $receivedMsg',
                //     style: TextStyle(fontSize: 14, color: Colors.black54),
                //   )),
                // ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildDialPad(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppBar(
                  elevation: 0,
                  backgroundColor: Colors.green,
                  title: Text('name'),
                  actions: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.video_call,
                        size: 34,
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.call,
                        size: 34,
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height * .9,
                    width: MediaQuery.of(context).size.width,
                    color: Color.fromARGB(179, 198, 192, 192),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // AppBar(
                        //   elevation: 0,
                        //   backgroundColor: Colors.green,
                        //   title: Text('name'),
                        //   actions: [
                        //     Icon(
                        //       Icons.video_call,
                        //       size: 34,
                        //     ),
                        //     SizedBox(
                        //       width: 15,
                        //     ),
                        //     Icon(
                        //       Icons.call,
                        //       size: 30,
                        //     ),
                        //     SizedBox(
                        //       width: 15,
                        //     ),
                        //   ],
                        // ),
                        Text('data'),
                        Container(
                          width: MediaQuery.of(context).size.width * .32,
                          height: 50,
                          decoration: BoxDecoration(
                            // color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                width: 1,
                                color: Color.fromARGB(255, 143, 130, 130)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(11.0),
                            child: Text(
                              'send message',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.black38),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),

                        // Text('data'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void registrationStateChanged(RegistrationState state) {
    setState(() {});
  }

  @override
  void transportStateChanged(TransportState state) {}

  @override
  void callStateChanged(Call call, CallState callState) {
    if (callState.state == CallStateEnum.CALL_INITIATION) {
      Navigator.pushNamed(context, '/callscreen', arguments: call);
    }
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {
    //Save the incoming message to DB
    String? msgBody = msg.request.body as String?;
    setState(
      () {
        receivedMsg = msgBody;
      },
    );
  }

  @override
  void onNewNotify(Notify ntf) {}
}
