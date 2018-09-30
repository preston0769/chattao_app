import 'package:chattao_app/friends.dart';
import 'package:chattao_app/login.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: ThemeData(
         brightness: Brightness.light,
         primaryColor: Colors.amberAccent
      ),
      title: 'TaoTao ChatApp',
      home: const MyHomePage(title: 'TaoTao ChatApp'),
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

class _MyHomePageState extends State<MyHomePage> {
  Widget activeScreen;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    activeScreen = LoginPage(onBtnClick: (String userId) {
      setState(() {
        activeScreen = FriendsPage(currentUserId: userId,onLogOut:(){
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text(widget.title)), body: activeScreen);
  }
}
