import 'package:chattao_app/actions/app_actions.dart';
import 'package:chattao_app/constants.dart';
import 'package:chattao_app/keys/global_keys.dart';
import 'package:chattao_app/models/app_state.dart';
import 'package:chattao_app/models/chat.dart';
import 'package:chattao_app/models/chat_message.dart';
import 'package:chattao_app/pages/chat_list_page.dart';
import 'package:chattao_app/pages/chat_page.dart';
import 'package:chattao_app/pages/login_page.dart';
import 'package:chattao_app/routes/scale_route.dart';
import 'package:chattao_app/routes/slide_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'dart:async';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:chattao_app/reducers/app_reducers.dart';

class TaoChatApplication extends StatelessWidget {
  final store =
      new Store<AppState>(appReducer, initialState: AppState.initial());
  TaoChatApplication() : super(key: mainAppKey);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: new MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: primaryColor,
        ),
        title: 'Tao Chat',
        home: MyHomePage(title: 'Tao Chat'),
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
  Store<AppState> reduxStore =
      (mainAppKey.currentWidget as TaoChatApplication).store;
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    _configFireBaseMessage();
    WidgetsBinding.instance.addObserver(this);
    activeScreen = LoginPage();
  }

  Future _getAllFriends(User me) async {
    Completer completer = new Completer();
    Firestore.instance.collection('users').snapshots().listen((snapshot) {
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
      // reduxStore.dispatch(UpdateStatusAction("In get all friends"));

      reduxStore.dispatch(UpdateFriends(friends));
      if (!completer.isCompleted) completer.complete();
    });
    return completer.future;
  }

  void _handleJumpOver() {
    User peer = reduxStore.state.friends
        .where((friend) => friend.uid == reduxStore.state.targetPeerId)
        .first;

    var newRoute = new ScaleRoute(
        widget: new ChatPage(
      peerId: peer.uid,
      peerName: peer.name,
      peerAvatar: peer.avataURL,
    ));

    if (reduxStore.state.currentRouteName != "/chatView") {
      Navigator.push(context, newRoute);
      reduxStore.dispatch(UpdateRouteNameAction("/chatView"));
    }
  }

  void _configFireBaseMessage() {
    reduxStore.onChange.listen(_onAppStateChange);
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        var idFrom = message['idFrom'];
        var body = message['aps']['alert']['body'];
        var chatMsg = new ChatMessage(
            content: body,
            idFrom: idFrom,
            idTo: "Null",
            timeStamp: DateTime.now().millisecondsSinceEpoch.toString(),
            type: 0);
        reduxStore.dispatch(NewChatMsgReceivedAction(chatMsg));
      },
      onLaunch: (Map<String, dynamic> message) async {
        reduxStore.dispatch(UpdateStatusAction("On Lauch"));
        var idFrom = message['idFrom'];

        // var body = message['aps']['alert']['body'];
        // var chatMsg = new ChatMessage(
        //     content: body,
        //     idFrom: idFrom,
        //     idTo: "Null",
        //     timeStamp: DateTime.now().millisecondsSinceEpoch.toString(),
        //     type: 0);
        // reduxStore.dispatch(NewChatMsgReceivedAction(chatMsg));
        reduxStore.dispatch(UpdateStatusAction("After dispatch"));

        reduxStore.dispatch(UpdateStatusAction(idFrom.toString()));
        if (reduxStore.state.friends.length > 0) {
          reduxStore.dispatch(SetJumpToPeerAction(idFrom));
          reduxStore.dispatch(UpdateStatusAction("Direct Jump"));
          _handleJumpOver();
        } else {
          reduxStore.dispatch(UpdateStatusAction("After Jump"));
          reduxStore.dispatch(SetJumpToPeerAction(idFrom));
        }
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
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      try {
        FlutterAppBadger.isAppBadgeSupported().then((supported) {
          if (supported) {
            var count = 0;
            reduxStore.state.chats.forEach((chat) {
              count = count + chat.unreadMessage;
            });
            FlutterAppBadger.updateBadgeCount(count);
          }
        });
      } catch (ex) {}
    }
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

  _getMyInfo(User me) {
    Firestore.instance
        .collection('users')
        .document(me.uid)
        .snapshots()
        .listen((document) {
      reduxStore.dispatch(UpdateUserNameAction(document["name"]));
    });
  }

  void _onAppStateChange(AppState state) async {
    if (!state.listenerRegistered && state.logined) {
      reduxStore.dispatch(CloudListenerRegistered());
      await _getAllFriends(state.me);
      await _getMyInfo(state.me);
    }
  }
}
