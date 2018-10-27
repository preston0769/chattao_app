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
        context, MaterialPageRoute(builder: (context) => ChatListPage()));
  }

  _navToContacts() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => FriendsPage()));
  }

  _navToProfile() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProfilePage()));
  }

  _navToDiscovery() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => DiscoveryPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(0xFFDCDCDC),
      child: SafeArea(
        child: Container(
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            constraints: BoxConstraints(maxHeight: 58.0),
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
                    iconData: Icons.chat,
                    title: "Chat",
                    isFocused: activeIndex == 0,
                    onTap: _navToChatList),
                NavBarItem(
                    iconData: Icons.import_contacts,
                    title: "Contacts",
                    isFocused: activeIndex == 1,
                    onTap: _navToContacts),
                NavBarItem(
                    isFocused: activeIndex == 2,
                    iconData: Icons.location_searching,
                    title: "Discover",
                    onTap: _navToDiscovery),
                NavBarItem(
                    iconData: Icons.portrait,
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
      onLongPress: isFocused ? () {} : onTap ?? onTap,
      onDoubleTap: isFocused ? () {} : onTap ?? onTap,
      child: Container(
        child: Column(
          children: <Widget>[
            Icon(
              iconData,
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
