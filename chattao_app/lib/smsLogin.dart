import 'dart:async';

import 'package:chattao_app/chat_list.dart';
import 'package:chattao_app/constants.dart';
import 'package:chattao_app/friends.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

class SMSLoginPage extends StatefulWidget {
  @override
  _SMSLoginPageState createState() => _SMSLoginPageState();
}

class _SMSLoginPageState extends State<SMSLoginPage> {
  Future<String> _message;
  String _testPhoneNumber;
  String _verificationId;

  dynamic activeScreen;
  PhoneNumberInputSegment phoneNumSeg;
  SMSCodeInputSegment smsInputSeg;

  @override
  initState() {
    super.initState();
    phoneNumSeg = new PhoneNumberInputSegment(_onPhoneInputComplete);
    smsInputSeg = new SMSCodeInputSegment(_onSmSCodeInputComplete);
    activeScreen = phoneNumSeg;
  }

  _showLoader(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: Center(
                heightFactor: 0.3,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                ),
              ),
            ));
  }

  _dismissLoader(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<String> _signInWithPhoneNum(String smsCode) async {
    final FirebaseUser user = await firebaseAuth.signInWithPhoneNumber(
      verificationId: _verificationId,
      smsCode: smsCode,
    );

    final FirebaseUser firebaseUser = await firebaseAuth.currentUser();
    assert(user.uid == firebaseUser.uid);

    if (firebaseUser != null) {
      var prefs = await SharedPreferences.getInstance();

      // Check is already sign up
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      var name = (firebaseUser.displayName == null ||
              firebaseUser.displayName.isEmpty)
          ? "TaoChat_" + firebaseUser.uid.substring(firebaseUser.uid.length - 5)
          : firebaseUser.displayName;
      var photoURL = (firebaseUser.photoUrl == null ||
              firebaseUser.photoUrl.isEmpty)
          ? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSUiD5eyL5b_4gPQ0bG9eYWJ3OAQPBk2IoIIjSTeK1uMCqrA39MYg"
          : firebaseUser.photoUrl;
      if (documents.length == 0) {
        // Update data to server if new user
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({
          'isOnline': true,
          'name': name,
          'photoUrl': photoURL,
          'id': firebaseUser.uid
        });
      }
      await prefs.setString('id', firebaseUser.uid);
      await prefs.setString('name', name);
      await prefs.setString('photoUrl', photoURL);
    }
  }

  _handleSmsLogin(BuildContext context) async {
    final PhoneVerificationCompleted verificationCompleted =
        (FirebaseUser user) {
      setState(() {
        _message =
            Future<String>.value('signInWithPhoneNumber auto succeeded: $user');
        print(_message);
      });
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      setState(() {
        _message = Future<String>.value(
            'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      this._verificationId = verificationId;
      // _smsCodeController.text = testSmsCode;
      _dismissLoader(context);
      _changeToScreen(1);
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      this._verificationId = verificationId;
      // _smsCodeController.text = testSmsCode;
    };

    await firebaseAuth.verifyPhoneNumber(
        phoneNumber: _testPhoneNumber,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void _onPhoneInputComplete(String phone) async {
    _showLoader(context);
    _testPhoneNumber = phone;
    await _handleSmsLogin(context);
  }

  void _onSmSCodeInputComplete(String code) async {
    _showLoader(context);
    await _signInWithPhoneNum(code);

    _dismissLoader(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return new ChatListPage();
    }));
  }

  void _changeToScreen(int index) {
    activeScreen = index == 0 ? phoneNumSeg : smsInputSeg;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(title: Text(activeScreen.title)),
        body: activeScreen,
      ),
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(false);
      },
    );
  }
}

class PhoneNumberInputSegment extends StatefulWidget {
  final String _title = "Phone login";
  final Function(String phone) onComplete;

  String get title => _title;

  PhoneNumberInputSegment(this.onComplete);
  @override
  _PhoneNumberInputSegmentState createState() =>
      _PhoneNumberInputSegmentState();
}

class _PhoneNumberInputSegmentState extends State<PhoneNumberInputSegment> {
  TextEditingController phoneNumTxtController = new TextEditingController();

  FocusNode phoneNumberFocus = new FocusNode();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                        color: Colors.grey, style: BorderStyle.solid),
                    color: Color(0xFF666666)),
                padding: EdgeInsets.all(12.0),
                margin: EdgeInsets.only(right: 16.0),
                child: Text(
                  "04",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0),
                ),
              ),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 200.0),
                  child: TextField(
                    focusNode: phoneNumberFocus,
                    cursorColor: themeColor,
                    onChanged: (String text) {
                      if (phoneNumTxtController.text.length > 8)
                        phoneNumTxtController.text =
                            phoneNumTxtController.text.substring(0, 8);
                    },
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.send,
                    keyboardAppearance: Brightness.dark,
                    controller: phoneNumTxtController,
                    style: TextStyle(
                        color: themeColor,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: greyColor, style: BorderStyle.solid)),
                        contentPadding: EdgeInsets.all(12.0),
                        // errorBorder: OutlineInputBorder(
                        //     borderSide: BorderSide(
                        //         color: Colors.red, style: BorderStyle.solid)),
                        //          errorText: "Invalid number format",
                        fillColor: Colors.white,
                        filled: true,
                        hintStyle: TextStyle(color: Colors.grey.withAlpha(100)),
                        hintText: "12345678"),
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 56.0),
          child: FlatButton(
            key: GlobalKey(debugLabel: "btnToSMSCode"),
            padding: EdgeInsets.all(12.0),
            onPressed: () {
              phoneNumberFocus.unfocus();
              if (phoneNumTxtController.text.length != 8) {
                Scaffold.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    "Invalid phone number.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20.0),
                  ),
                ));
                return;
              }
              widget.onComplete("+614" + phoneNumTxtController.text);
            },
            color: themeColor,
            child: Text(
              "Send sms code",
              style: TextStyle(color: Colors.white),
            ),
          ),
        )
      ],
    );
  }
}

class SMSCodeInputSegment extends StatelessWidget {
  final String _title = "Verify SMS";
  final Function(String code) onComplete;
  final TextEditingController smsCodeController = new TextEditingController();

  String get title => _title;
  SMSCodeInputSegment(this.onComplete);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 200.0),
                  child: TextField(
                    cursorColor: themeColor,
                    onChanged: (String text) {
                      if (smsCodeController.text.length > 8)
                        smsCodeController.text =
                            smsCodeController.text.substring(0, 8);
                    },
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.send,
                    keyboardAppearance: Brightness.dark,
                    controller: smsCodeController,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: themeColor,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: greyColor, style: BorderStyle.solid)),
                        contentPadding: EdgeInsets.all(12.0),
                        // errorBorder: OutlineInputBorder(
                        //     borderSide: BorderSide(
                        //         color: Colors.red, style: BorderStyle.solid)),
                        //          errorText: "Invalid number format",
                        fillColor: Colors.white,
                        filled: true,
                        hintStyle: TextStyle(color: Colors.grey.withAlpha(100)),
                        hintText: "888888"),
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 56.0),
          child: FlatButton(
            padding: EdgeInsets.all(12.0),
            onPressed: () {
              onComplete(smsCodeController.text);
            },
            color: themeColor,
            child: Text(
              "Verify",
              style: TextStyle(color: Colors.white),
            ),
          ),
        )
      ],
    );
  }
}
