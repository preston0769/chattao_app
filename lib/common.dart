import 'package:chattao_app/constants.dart';
import 'package:chattao_app/friends.dart';
import 'package:chattao_app/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class BottomBar extends StatelessWidget {
  final BuildContext context;
  final int activeIndex;
  BottomBar({@required this.context, this.activeIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: themeColor,
      child: SafeArea(
        child: Container(
            padding: EdgeInsets.only(top: 8.0),
            constraints: BoxConstraints(maxHeight: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                NavBarItem(
                  iconData: Icons.chat,
                  title: "Chat",
                  isFocused: activeIndex == 0,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => FriendsPage()));
                  },
                ),
                NavBarItem(iconData: Icons.import_contacts, title: "Contacts"),
                NavBarItem(
                  iconData: Icons.notification_important,
                  title: "Requests",
                  onTap: () {},
                ),
                NavBarItem(
                    iconData: Icons.location_searching, title: "Discover"),
                NavBarItem(
                  iconData: Icons.portrait,
                  title: "Me",
                  isFocused: activeIndex == 4,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfilePage()));
                  },
                ),
              ],
            )),
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  final IconData iconData;
  final String title;
  final bool isFocused;
  final VoidCallback onTap;

  NavBarItem(
      {@required this.iconData,
      @required this.title,
      this.isFocused = false,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isFocused ? () {} : onTap ?? onTap,
      child: Container(
        child: Column(
          children: <Widget>[
            Icon(
              iconData,
              color: isFocused ? Colors.orangeAccent : Colors.white,
            ),
            Text(
              title,
              style: TextStyle(
                  color: isFocused ? Colors.orangeAccent : Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
