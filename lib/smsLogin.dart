import 'dart:async';

import 'package:chattao_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vercoder_inputer/vercoder_inputer.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

class SMSLoginPage extends StatefulWidget {
  @override
  _SMSLoginPageState createState() => _SMSLoginPageState();
}

class _SMSLoginPageState extends State<SMSLoginPage> {
  Future<String> _message;
  String _testPhoneNumber;
  String _verificationId;

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

  FocusNode phoneNumberFocus = new FocusNode();
  var phoneNumSeg = new PhoneNumberInputSegment();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
          child: Scaffold(
        appBar: AppBar(title: Text(phoneNumSeg.title)),
        body: phoneNumSeg,
      ), onWillPop: () {
        phoneNumberFocus.unfocus();
         Navigator.pop(context);
         return Future.value(false);

      },
    );
  }
}

class PhoneNumberInputSegment extends StatefulWidget {
  final String _title = "Phone login";

  String get title => _title;
  @override
  _PhoneNumberInputSegmentState createState() =>
      _PhoneNumberInputSegmentState();
}

class _PhoneNumberInputSegmentState extends State<PhoneNumberInputSegment> {
  TextEditingController phoneNumTxtController = new TextEditingController();

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
                    autofocus: true,
                    onChanged: (String text) {
                       if( phoneNumTxtController.text.length>8)
                           phoneNumTxtController.text = phoneNumTxtController.text.substring(0,8);
                    },
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.send,
                    keyboardAppearance: Brightness.dark,
                    controller: phoneNumTxtController,
                    style: TextStyle( color: themeColor, fontSize: 20.0, fontWeight:  FontWeight.bold, letterSpacing: 2.0),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: greyColor, style: BorderStyle.solid)),
                        contentPadding: EdgeInsets.all(12.0),
                        fillColor: Colors.white,
                        filled: true,
                        hintStyle:  TextStyle( color: Colors.grey.withAlpha(100)),
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
            padding: EdgeInsets.all(12.0),
            onPressed: () {},
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

  String get title => _title;
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
