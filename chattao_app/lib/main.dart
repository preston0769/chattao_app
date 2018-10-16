import 'package:chattao_app/actions/app_actions.dart';
import 'package:chattao_app/keys/global_keys.dart';
import 'package:chattao_app/login.dart';
import 'package:chattao_app/models/app_state.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:chattao_app/reducers/app_reducers.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  final store =new Store<AppState>(appReducer, initialState:AppState.initial());
  MyApp():super(key:mainAppKey);

  @override
  Widget build(BuildContext context) {
    return  StoreProvider<AppState>(
         store: store,
          child: new MaterialApp(
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
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  @override
  void initState() {
    super.initState();
   WidgetsBinding.instance.addObserver(this);
    print("App inited");
    activeScreen = LoginPage();
    var reduxStore =  (mainAppKey.currentWidget as MyApp).store;
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {

        reduxStore.dispatch(NewChatMsgReceivedAction(0,1,"OnMsg:"+message.toString()));
        print("onMessage: $message");

      },
      onLaunch: (Map<String, dynamic> message) async {
        reduxStore.dispatch(NewChatMsgReceivedAction(0,1,"OnLaunch:"+message.toString()));
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        reduxStore.dispatch(NewChatMsgReceivedAction(0,1, "OnResume:"+message.toString()));
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      print("Token:"+token);
       reduxStore.dispatch( UpdatePushNotificationTokenAction(token));
      assert(token != null);
      setState(() {
      });
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
  void dispose(){

    WidgetsBinding.instance.removeObserver(this);
    print("App disposed");
    super.dispose();
  }
}
