import 'package:chattao_app/actions/app_actions.dart';
import 'package:chattao_app/chats.dart';
import 'package:chattao_app/keys/global_keys.dart';
import 'package:chattao_app/local_processing/local_rw.dart';
import 'package:chattao_app/login.dart';
import 'package:chattao_app/models/app_state.dart';
import 'package:chattao_app/models/chat.dart';
import 'package:chattao_app/models/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:chattao_app/reducers/app_reducers.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  final store =
      new Store<AppState>(appReducer, initialState: AppState.initial());
  MyApp() : super(key: mainAppKey);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: new MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Color(0xFF17CDBB),
        ),
        title: 'Tao Chat',
        home: const MyHomePage(title: 'Tao Chat'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  State<StatefulWidget> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  Widget activeScreen;
  Store<AppState> reduxStore = (mainAppKey.currentWidget as MyApp).store;
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    _configFireBaseMessage();
    WidgetsBinding.instance.addObserver(this);
    print("App inited");
    activeScreen = LoginPage();
    _loadLocalActiveMessage();
  }

  void _loadLocalActiveMessage() async {
    print('hello');
    reduxStore.dispatch(StartLoadActiveChatAction());
    List<Chat> chatList = await readChatList();
    if (chatList != null && chatList.length > 0)
      reduxStore.dispatch(LoadActiveChatsFinishedAction(chatList));
  }

  void _listenToChatListChange(User me) async {
    Firestore.instance
        .collection('messages')
        .where('uids', arrayContains: me.uid)
        .snapshots()
        .listen((snapshot) {
      List<Chat> chats = new List();
      List<User> users = reduxStore.state.friends;

      snapshot.documents.forEach((document) {
        List<String> uids =
            List<String>.from((document['uids'] as List<dynamic>));

        String peerId = uids.where((uid) => uid != me.uid).first;

        if (peerId != null || peerId.isNotEmpty) {
          User peer = users.where((user) => user.uid == peerId).first;

          Chat chat = new Chat(me, peer);
          chat.lastUpdated = DateTime.fromMillisecondsSinceEpoch(
              int.parse(document['lastUpdated']));
          chats.add(chat);
        }
      });

      reduxStore.dispatch(UpdateChatList(chats));
    });
  }

  Future _getAllFriends(User me) async {
    Firestore.instance.collection('users').snapshots().listen((snapshot) {
      print(snapshot.documents);

      List<User> friends = new List();
      snapshot.documents.forEach((document) {
        var uid = document['id'];
        if (uid != reduxStore.state.me.uid) {
          var friend = new User(uid);
          friend.avataURL = document['photoUrl'];
          friend.name = document['name'];
          friend.nickName = friend.name;
          friends.add(friend);
        }
      });

      reduxStore.dispatch(UpdateFriends(friends));
      if (reduxStore.state.targetPeerId != null &&
          reduxStore.state.targetPeerId.isNotEmpty) _handleJumpOver();
    });
  }

  void _handleJumpOver() {
    User peer = reduxStore.state.friends
        .where((friend) => friend.uid == reduxStore.state.targetPeerId)
        .first;
    Navigator.push(context, new CupertinoPageRoute(builder: (context) {
      return new ChatView(
        peerId: peer.uid,
        peerName: peer.name,
        peerAvatar: peer.avataURL,
      );
    }));
  }

  void _configFireBaseMessage() {
    reduxStore.onChange.listen(_onAppStateChange);
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        var idFrom = message['idFrom'];
        print("onMessage: $idFrom");
        var chatMsg = new ChatMessage(
            content: message.toString(),
            idFrom: idFrom,
            idTo: "Null",
            timeStamp: "88888",
            type: 0);
        reduxStore.dispatch(NewChatMsgReceivedAction(chatMsg));
      },
      onLaunch: (Map<String, dynamic> message) async {
        var idFrom = message['idFrom'];
        var chatMsg = new ChatMessage(
            content: message.toString(),
            idFrom: idFrom,
            idTo: "Null",
            timeStamp: "88888",
            type: 0);

        reduxStore.dispatch(NewChatMsgReceivedAction(chatMsg));

        if (reduxStore.state.friends.length > 0) {
          reduxStore.dispatch(SetJumpToPeerAction(idFrom));
          _handleJumpOver();
        } else
          reduxStore.dispatch(SetJumpToPeerAction(idFrom));
      },
      onResume: (Map<String, dynamic> message) async {
        var idFrom = message['idFrom'];

        if (reduxStore.state.friends.length > 0) {
          reduxStore.dispatch(SetJumpToPeerAction(idFrom));
          _handleJumpOver();
        } else
          reduxStore.dispatch(SetJumpToPeerAction(idFrom));
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      print("Token:" + token);
      reduxStore.dispatch(UpdatePushNotificationTokenAction(token));
      assert(token != null);
      setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(body: activeScreen);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print("App disposed");
    super.dispose();
  }

  void _onAppStateChange(AppState state) async {
    if (!state.listenerRegistered && state.logined) {
      reduxStore.dispatch(CloudListenerRegistered());
      await _getAllFriends(state.me);
      _listenToChatListChange(state.me);
    }
  }
}