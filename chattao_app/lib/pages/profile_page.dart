import 'dart:async';

import 'package:chattao_app/constants.dart';
import 'package:chattao_app/elements/avatar_element.dart';
import 'package:chattao_app/pages/login_page.dart';
import 'package:chattao_app/routes/scale_route.dart';
import 'package:chattao_app/views/bottombar_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String myAvatar;
  String name = "";
  String uid = "";
  bool initialized = false;

  Future readLocal() async {
    var prefs = await SharedPreferences.getInstance();
    myAvatar = prefs.getString('photoUrl') ?? '';
    name = prefs.getString('name') ?? 'name-xxx';
    uid = prefs.getString('id') ?? 'uid-xxxx';
    setState(() {
      initialized = true;
    });
  }

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
    readLocal();
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
      child: !initialized
          ? Container()
          : Scaffold(
              backgroundColor: greyColor2,
              appBar: AppBar(
                title: Text(
                  "Profile",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              body: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      margin: EdgeInsets.only(top: 30.0, bottom: 40.0),
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: AvatarElement(
                              avatarUrl: myAvatar.length > 0 ? myAvatar : null,
                              widgetHeight: 64.0,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: InkWell(
                                          onTap: () {},
                                          child: Icon(
                                            Icons.edit,
                                            color: themeColor,
                                          )),
                                    )
                                  ],
                                ),
                                Text(uid.substring(uid.length - 10)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                          // Icon(Icons.code)
                        ],
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
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0),
                          ),
                        ),
                      ),
                    )
                  ],
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
