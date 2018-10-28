import 'dart:async';
import 'package:chattao_app/actions/app_actions.dart';
import 'package:chattao_app/constants.dart';
import 'package:chattao_app/controllers/login_controller.dart';
import 'package:chattao_app/models/app_state.dart';
import 'package:chattao_app/models/chat.dart';
import 'package:chattao_app/pages/chat_list_page.dart';
import 'package:chattao_app/pages/smsLogin_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var initialized = false;
  var loginController = new LoginController();


  @override
  initState() {
    super.initState();

    loginController.addListener((){
      if(loginController.status == LoginStatusEnum.StartLogin){
        _showLoader(context);
      }
      if(loginController.status ==  LoginStatusEnum.Done){
        _dismissLoader(context);
      }

    });
    readLocal();
  }

  readLocal() async {
    // _showLoader(context);
    var prefs = await SharedPreferences.getInstance();
    var uid = prefs.getString('id');
    if (uid != null && uid.isNotEmpty) {
      User me = new User(prefs.getString('id'));
      me.avataURL = prefs.getString('photoUrl');
      me.name = prefs.getString('name');
      me.nickName = prefs.getString('name');

      var reduxStore = StoreProvider.of<AppState>(context);
      reduxStore.dispatch(UserLoginedAction(me));
      // _dismissLoader(context);
      Navigator.push(context,  PageRouteBuilder(pageBuilder:(context,_,__)=> new ChatListPage()));
    } else {
      // _dismissLoader(context);
      setState(() {
        initialized = true;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
          title: new Text(
        "Login",
        style: TextStyle(color: Colors.white),
      )),
      backgroundColor: Color(0xFFBFBFBF),
      body: !initialized
          ? Container()
          : Center(
              child: IntrinsicWidth(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 6.0,
                            offset: Offset(0.0, 3.0))
                      ]),
                      width: double.infinity,
                      child: FlatButton(
                        padding: EdgeInsets.all(16.0),
                        color: themeColor,
                        onPressed: () async {
                          await  loginController.handleGoogleLogin(context);
                        },
                        child: Text(
                          "Sign in with Google",
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    Container(
                      decoration: BoxDecoration(boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 6.0,
                            offset: Offset(0.0, 3.0))
                      ]),
                      width: double.infinity,
                      child: FlatButton(
                        padding: EdgeInsets.all(16.0),
                        color: Colors.amber,
                        onPressed: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SMSLoginPage()));
                        },
                        child: Text(
                          "Sign in with SMS",
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
