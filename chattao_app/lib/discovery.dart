import 'package:chattao_app/common.dart';
import 'package:flutter/material.dart';

class DiscoveryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Discovery",
          style: TextStyle(color: Colors.white),
        ),
      ),
      bottomNavigationBar: BottomBar(
        context: context,
        activeIndex: 2,
      ),
      body: Container(
        child: Center(child: Text("Nothing")),
      ),
    );
  }
}
