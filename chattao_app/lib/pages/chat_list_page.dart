import 'dart:async';

import 'package:chattao_app/actions/app_actions.dart';
import 'package:chattao_app/controllers/chat_list_controller.dart';
import 'package:chattao_app/models/app_state.dart';
import 'package:chattao_app/models/chat.dart';
import 'package:chattao_app/pages/chat_page.dart';
import 'package:chattao_app/routes/scale_route.dart';
import 'package:chattao_app/views/bottombar_view.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  String uid;
  bool initialized = false;
  SharedPreferences prefs;
  StreamSubscription onceOffSub;

  Future readLocal() async {
    var prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('id') ?? 'uid-xxxx';

    setState(() {
      initialized = true;
    });
  }

  void _handleJumpOver() {
    var reduxStore = StoreProvider.of<AppState>(context);
    onceOffSub.cancel();
    onceOffSub = null;
    User peer = reduxStore.state.friends
        .where((friend) =>
            friend.uid == reduxStore.state.targetPeerId.trim().toString())
        .first;

    var newRoute = new ScaleRoute(
        widget: new ChatPage(
      peerId: peer.uid,
      peerName: peer.name,
      peerAvatar: peer.avataURL,
    ));

    reduxStore.dispatch(ClearJumpToPeerAction());
    if (reduxStore.state.currentRouteName != "/chatView") {
      Navigator.push(context, newRoute);
      reduxStore.dispatch(UpdateRouteNameAction("/chatView"));
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      var reduxStore = StoreProvider.of<AppState>(context);
      var controller = new ChatListController(reduxStore);
      controller.readFromLocal().then((_) {
        controller.streamFromServer();
        setState(() {});
      });

      if (reduxStore.state.targetPeerId == null ||
          reduxStore.state.targetPeerId.isEmpty) return;

      if (reduxStore.state.friends.length < 1) {
        onceOffSub = reduxStore.onChange.listen((state) {
          if (state.friends.length > 1) {
            _handleJumpOver();
          }
        });
      } else
        _handleJumpOver();
    });
    readLocal();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: !initialized
          ? Container()
          : Scaffold(
              appBar: new AppBar(
                 elevation: 0.0,
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
              bottomNavigationBar: BottomBarView(
                context: context,
              ),
              backgroundColor: Color(0xFFEFEFEF),
              body: SafeArea(
                child: Column(
                  children: <Widget>[
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
        ScaleRoute(
            widget: new ChatPage(
          peerId: chat.peer.uid,
          peerAvatar: chat.peer.avataURL,
          peerName: chat.peer.name,
        )));
    StoreProvider.of<AppState>(context)
        .dispatch(UpdateRouteNameAction("/chatView"));
  }

  @override
  Widget build(BuildContext context) {
    var lastMsg = chat.latestMsg?.content ?? "--";
    if (lastMsg.length > 24) {
      lastMsg = lastMsg.substring(0, 20) + "...";
    }

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
          padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
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
                    Container(child: new Text(chat.peer.name)),
                    Container(
                      padding: EdgeInsets.only(top: 8.0),
                      child: chat.latestMsg != null
                          ? new Text(
                              lastMsg,
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12.0),
                            )
                          : new Container(),
                    )
                  ],
                ),
              ),
              new SizedBox(
                width: 40.0,
              ),
              new Text(
                chat.latestMsg != null
                    ? _convertToDateString(chat.lastUpdated)
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

  String _convertToDateString(DateTime lastUpdateTime) {
    DateTime now = DateTime.now();

    var diff = now.difference(lastUpdateTime);

    if (diff.inSeconds < 60) return "Just now";

    if (diff.inMinutes < 10) return "A while ago";
    if (diff.inMinutes < 60) return "Past hour";
    if (diff.inHours < 5) return "In ${diff.inHours} hours";
    if (diff.inHours < 24) return "In a day";
    if (diff.inDays == 1) return "Yesterday";

    return DateFormat("dd MMM").format(lastUpdateTime);
  }
}
