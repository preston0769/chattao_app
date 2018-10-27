import 'dart:async';

import 'package:chattao_app/actions/app_actions.dart';
import 'package:chattao_app/constants.dart';
import 'package:chattao_app/elements/avatar_element.dart';
import 'package:chattao_app/models/app_state.dart';
import 'package:chattao_app/models/chat.dart';
import 'package:chattao_app/pages/login_page.dart';
import 'package:chattao_app/routes/scale_route.dart';
import 'package:chattao_app/server_handler/update_username_handler.dart';
import 'package:chattao_app/views/bottombar_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "";
  bool editNickName = false;

  TextEditingController controller = new TextEditingController();
  FocusNode focusenode = new FocusNode();

  _showConfirmLogooutDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Confirm Logout"),
            content: Text("Are your sure you want to log out TaoChat?"),
            actions: <Widget>[
              FlatButton(
                color: Colors.grey,
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(context);
                },
              ),
              FlatButton(
                color: Colors.red,
                child: Text(
                  "Confirm Logout",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  _handleLogout(context);
                },
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
  }

  _handleLogout(BuildContext context) async {
    final GoogleSignIn googleSignIn = new GoogleSignIn();
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await googleSignIn.signOut();
    await firebaseAuth.signOut();
    await prefs.clear();
    Navigator.popUntil(
        context, ModalRoute.withName(Navigator.defaultRouteName));
    Navigator.push(context, new ScaleRoute(widget: LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: greyColor2,
        appBar: AppBar(
          elevation: 0.0,
          title: Text(
            "Profile",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            setState(() {
              controller.text = name;
              editNickName = false;
            });
          },
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(maxHeight: 600.0),
              child: Column(
                children: <Widget>[
                  Container(
                    // width: double.infinity,
                    color: Colors.white,
                    margin: EdgeInsets.only(top: 30.0, bottom: 40.0),
                    padding: EdgeInsets.all(16.0),
                    child: StoreConnector<AppState, User>(
                      converter: (store) {
                        controller.text = store.state.me.nickName;
                        name = controller.text;
                        return store.state.me;
                      },
                      builder: (context, me) {
                        return Row(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: AvatarElement(
                                avatarUrl:
                                    me.avataURL.length > 0 ? me.avataURL : null,
                                widgetHeight: 64.0,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 15.0),
                              // height:  double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        constraints: BoxConstraints(
                                            maxHeight: 30.0, maxWidth: 150.0),
                                        child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8.0),
                                            child: TextField(
                                              maxLength: 20,
                                              enabled: editNickName,
                                              focusNode: focusenode,
                                              controller: controller,
                                              onSubmitted: (nickname) {
                                                if (nickname.trim().length >
                                                    0) {
                                                  updateUserNameHandler(
                                                      me, nickname.trim());

                                                  var reduxStore = StoreProvider
                                                      .of<AppState>(context);

                                                  reduxStore.dispatch(
                                                      UpdateUserNameAction(
                                                          nickname));
                                                  setState(() {
                                                    editNickName = false;
                                                  });
                                                } else
                                                  setState(() {
                                                    controller.text = name;
                                                    editNickName = false;
                                                  });
                                              },
                                              style: TextStyle(
                                                  fontSize: 20.0,
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.w600),
                                              decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                          2.0, 2.0, 2.0, 8.0),
                                                  border: InputBorder.none,
                                                  disabledBorder: InputBorder
                                                      .none,
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: themeColor,
                                                              style: BorderStyle
                                                                  .solid,
                                                              width: 2.0))),
                                              textInputAction:
                                                  TextInputAction.done,
                                            )),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: editNickName
                                            ? Container()
                                            : InkWell(
                                                onTap: () {
                                                  FocusScope.of(context)
                                                      .requestFocus(focusenode);
                                                  setState(() {
                                                    editNickName = true;
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.edit,
                                                  color: themeColor,
                                                )),
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                        me.uid.substring(me.uid.length - 10)),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(),
                            ),
                            // Icon(Icons.code)
                          ],
                        );
                      },
                    ),
                  ),
                  SettingItem("About", subTitle: "Version 0.1.0"),
                  SettingItem("Notifictions"),
                  Expanded(
                    child: Container(),
                  ),
                  InkWell(
                    onTap: () {
                      _showConfirmLogooutDialog();
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 32.0),
                      padding: EdgeInsets.all(16.0),
                      color: themeColor,
                      child: Center(
                        child: Text(
                          "Log out",
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomBarView(
          context: context,
          activeIndex: 3,
        ),
      ),
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(false);
      },
    );
  }
}

class SettingItem extends StatelessWidget {
  final String title;
  final String subTitle;
  final VoidCallback onTap;

  SettingItem(this.title, {this.subTitle, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.fromLTRB(24.0, 12.0, 16.0, 12.0),
      width: double.infinity,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: 16.0),
          ),
          Expanded(
            child: Container(),
          ),
          subTitle != null
              ? Text(
                  subTitle,
                  style: TextStyle(color: greyColor),
                )
              : Container(),
          Icon(
            Icons.keyboard_arrow_right,
            color: greyColor,
          )
        ],
      ),
    );
  }
}
