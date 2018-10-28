import 'dart:async';

import 'package:chattao_app/constants.dart';
import 'package:chattao_app/controllers/login_controller.dart';
import 'package:chattao_app/pages/chat_list_page.dart';
import 'package:chattao_app/routes/scale_route.dart';
import 'package:chattao_app/routes/slide_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

class SMSLoginPage extends StatefulWidget {
  @override
  _SMSLoginPageState createState() => _SMSLoginPageState();
}

class _SMSLoginPageState extends State<SMSLoginPage> {
  LoginController controller;

  dynamic activeScreen;
  PhoneNumberInputSegment phoneNumSeg;
  SMSCodeInputSegment smsInputSeg;

  @override
  initState() {
    super.initState();
    controller = new LoginController();
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

  void _onPhoneInputComplete(String phoneNum) async {
    _showLoader(context);
    controller.handleSmsCodeReceive(context, phoneNum, () {
      _dismissLoader(context);
      _changeToScreen(1);
    });
  }

  void _onSmSCodeInputComplete(String smsCode) async {
    _showLoader(context);
    await controller.signInWithPhoneNum(context, smsCode);
    _dismissLoader(context);
    Navigator.push(context, SlideRoute(widget: new ChatListPage()));
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
