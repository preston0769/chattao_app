import 'dart:async';

import 'package:chattao_app/chats.dart';
import 'package:chattao_app/common.dart';
import 'package:chattao_app/models/app_state.dart';
import 'package:chattao_app/models/chat.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  String uid;
  bool initialized = false;
  SharedPreferences prefs;

  Future readLocal() async {
    var prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('id') ?? 'uid-xxxx';
    setState(() {
      initialized = true;
    });
  }

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: !initialized
          ? Container()
          : Scaffold(
              appBar: new AppBar(
                centerTitle: true,
                title: StoreConnector<AppState, InitState>(
                  converter: (store) {
                    return store.state.initState;
                  },
                  builder: (content, state) {
                    return new Text(
                      state == InitState.Inited ? "TaoChat" : "Loading",
                      style: TextStyle(color: Colors.white),
                    );
                  },
                ),
                leading: Container(),
                actions: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: Icon(Icons.add))
                ],
              ),
              bottomNavigationBar: BottomBar(
                context: context,
              ),
              backgroundColor: Color(0xFFEFEFEF),
              body: SafeArea(
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
                      child: TextField(
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(style: BorderStyle.none)),
                          contentPadding: EdgeInsets.all(0.0),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.black,
                          ),
                          fillColor: Colors.white.withAlpha(200),
                          filled: true,
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black.withAlpha(200),
                                  width: 1.0,
                                  style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(8.0)),
                          hintText: "Search friend",
                        ),
                      ),
                    ),
                    Expanded(
                      child: StoreConnector<AppState, List<Chat>>(
                          converter: (store) {
                        return store.state.chats;
                      }, builder: (context, chatList) {
                        if (chatList.length < 1) return Container();
                        return new ListView.builder(
                            itemCount: chatList.length,
                            padding: const EdgeInsets.only(top: 10.0),
                            // itemExtent: 25.0,
                            itemBuilder: (context, index) {
                              return ChatListItem(chatList.elementAt(index));
                            });
                      }),
                    ),
                    // StoreConnector<AppState, String>(
                    //   converter: (store) {
                    //     return store.state.message;
                    //   },
                    //   builder: (context, content) {
                    //     return Center(
                    //         child: new Text(content ?? "Nothing is here"));
                    //   },
                    // ),
                  ],
                ),
              ),
            ),
      onWillPop: () {},
    );
  }
}

class ChatListItem extends StatelessWidget {
  final Chat chat;
  ChatListItem(this.chat);

  void _loadChatScreen(BuildContext context, Chat chat) {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new ChatView(
                  peerId: chat.peer.uid,
                  peerAvatar: chat.peer.avataURL,
                  peerName: chat.peer.name,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return new ListTile(
        key: new ValueKey(chat.hashCode),
        title: new Container(
          decoration: new BoxDecoration(
            border: new Border(
                bottom: BorderSide(
                    width: 0.3,
                    color: const Color(0x88888888),
                    style: BorderStyle.solid)),
            // borderRadius: new BorderRadius.circular(5.0),
          ),
          padding: const EdgeInsets.only(top: 10.0,  bottom: 10.0),
          child: new Row(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    child: CachedNetworkImage(
                      placeholder: Container(
                        child: CircularProgressIndicator(
                          strokeWidth: 0.3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor),
                        ),
                        width: 48.0,
                        height: 48.0,
                        padding: EdgeInsets.all(12.0),
                      ),
                      imageUrl: chat.peer.avataURL,
                      width: 48.0,
                      height: 48.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  chat.unreadMessage > 0
                      ? Positioned(
                          right: 0.0,
                          top: 0.0,
                          child: Transform(
                            transform:
                                Matrix4.translationValues(8.0, -8.0, 0.0),
                            child: Container(
                              width: 20.0,
                              height: 20.0,
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Center(
                                  child: Text(
                                chat.unreadMessage.toString(),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12.0),
                              )),
                            ),
                          ),
                        )
                      : Container()
                ],
              ),
              SizedBox(
                width: 12.0,
              ),
              new Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container( child: new Text(chat.peer.name)),
                    Container(
                      padding: EdgeInsets.only(top: 8.0),
                      child: chat.latestMsg != null
                          ? new Text(
                              chat.latestMsg.content,
                              style: TextStyle(color: Colors.grey, fontSize: 12.0),
                            )
                          : new Container(),
                    )
                  ],
                ),
              ),
              new Text(
                chat.latestMsg != null
                    ? chat.lastUpdated.millisecondsSinceEpoch.toString()
                    : "Never",
                style: TextStyle(fontSize: 12.0, color: Colors.grey),
              ),
            ],
          ),
        ),
        onTap: () {
          // _toggleOnlineStatus(document);
          _loadChatScreen(context, chat);
        });
  }
}
