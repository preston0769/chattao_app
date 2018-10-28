import 'package:chattao_app/constants.dart';
import 'package:chattao_app/models/app_state.dart';
import 'package:chattao_app/pages/chat_list_page.dart';
import 'package:chattao_app/pages/discovery_page.dart';
import 'package:chattao_app/pages/friends_page.dart';
import 'package:chattao_app/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class BottomBarView extends StatelessWidget {
  final BuildContext context;
  final int activeIndex;
  BottomBarView({@required this.context, this.activeIndex = 0});

  _navToChatList() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, _, __) => ChatListPage(),
      ),
    );
  }

  _navToContacts() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, _, __) => FriendsPage(),
      ),
    );
  }

  _navToProfile() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, _, __) => ProfilePage(),
      ),
    );
  }

  _navToDiscovery() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, _, __) => DiscoveryPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(0xFFDCDCDC),
      child: SafeArea(
        child: Container(
            padding: EdgeInsets.only(top: 8.0),
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
                StoreConnector<AppState, int>(
                   converter:  (store){
                      int count =0;
                      store.state.chats.forEach((chat){
                        count  = count + chat.unreadMessage;
                      });
                      return count;
                   },
                  builder: (context, count) => NavBarItem(
                      iconName: "chats",
                      title: "Chat",
                      isFocused: activeIndex == 0,
                      notificaton: count,
                      onTap: _navToChatList),
                ),
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
  final int notificaton;
  final VoidCallback onTap;
  final double notificationSize;

  NavBarItem(
      {@required this.iconName,
      @required this.title,
      this.isFocused = false,
      this.onTap,
      this.notificaton = 0,
      this.notificationSize = 12.0});

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
            Stack(children: <Widget>[
              ImageIcon(
                AssetImage("images/icons/$iconname.png"),
                size: 24.0,
                color: isFocused ? themeColor : Colors.black.withAlpha(160),
              ),
              notificaton == 0
                  ? Container()
                  : Positioned(
                      right: 0.0,
                      top: 0.0,
                      child: Transform(
                        transform: Matrix4.translationValues(
                            notificationSize / 2, -notificationSize / 2, 0.0),
                        child: Container(
                          height: notificationSize,
                          width: notificationSize,
                          child: notificaton < 0
                              ? Container()
                              : Center(
                                  child: Text(
                                  notificaton.toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 8.0),
                                )),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(notificationSize / 2),
                              color: Colors.red),
                        ),
                      ),
                    )
            ]),
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
