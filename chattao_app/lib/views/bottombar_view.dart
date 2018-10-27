import 'package:chattao_app/constants.dart';
import 'package:chattao_app/pages/chat_list_page.dart';
import 'package:chattao_app/pages/discovery_page.dart';
import 'package:chattao_app/pages/friends_page.dart';
import 'package:chattao_app/pages/profile_page.dart';
import 'package:flutter/material.dart';

class BottomBarView extends StatelessWidget {
  final BuildContext context;
  final int activeIndex;
  BottomBarView({@required this.context, this.activeIndex = 0});

  _navToChatList() {
    Navigator.push(
        context,  PageRouteBuilder( pageBuilder: (context,_,__) => ChatListPage(), ), );
  }

  _navToContacts() {
    Navigator.push(
        context,  PageRouteBuilder( pageBuilder: (context,_,__) => FriendsPage(), ), );
  }

  _navToProfile() {
    Navigator.push(
        context,  PageRouteBuilder( pageBuilder: (context,_,__) => ProfilePage(), ), );
  }

  _navToDiscovery() {
    Navigator.push(
        context,  PageRouteBuilder( pageBuilder: (context,_,__) => DiscoveryPage(), ), );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(0xFFDCDCDC),
      child: SafeArea(
        child: Container(
            padding: EdgeInsets.only(top: 8.0 ),
            constraints: BoxConstraints(maxHeight: 52.0),
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
                        width: 0.3,
                        style: BorderStyle.solid,
                        color: Colors.grey))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                NavBarItem(
                    iconName: "chats",
                    title: "Chat",
                    isFocused: activeIndex == 0,
                    onTap: _navToChatList),
                NavBarItem(
                    iconName: "contacts",
                    title: "Contacts",
                    isFocused: activeIndex == 1,
                    onTap: _navToContacts),
                NavBarItem(
                    isFocused: activeIndex == 2,
                    iconName: "discover",
                    title: "Discover",
                    onTap: _navToDiscovery),
                NavBarItem(
                    iconName: "profile",
                    title: "Me",
                    isFocused: activeIndex == 3,
                    onTap: _navToProfile),
              ],
            )),
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  final String iconName;
  final String title;
  final bool isFocused;
  final VoidCallback onTap;

  NavBarItem(
      {@required this.iconName,
      @required this.title,
      this.isFocused = false,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    var iconname = iconName + (isFocused ? "_active" : "_outline");
    return InkWell(
      onTap: isFocused ? () {} : onTap ?? onTap,
      onLongPress: isFocused ? () {} : onTap ?? onTap,
      onDoubleTap: isFocused ? () {} : onTap ?? onTap,
      child: Container(
        child: Column(
          children: <Widget>[
            ImageIcon(
              AssetImage("images/icons/$iconname.png"),
              size: 24.0,
              color: isFocused ? themeColor : Colors.black.withAlpha(160),
            ),
            Text(title,
                style: TextStyle(
                  color: isFocused ? themeColor : Colors.black.withAlpha(160),
                )),
          ],
        ),
      ),
    );
  }
}
