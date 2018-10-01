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
        primaryColor: Color(0xFF17CDBB),
      ),
      title: 'Tao Chat',
      home: const MyHomePage(title: 'Tao Chat'),
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
    super.initState();
    activeScreen = LoginPage();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(body: activeScreen);
  }
}
