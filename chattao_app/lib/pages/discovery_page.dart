import 'package:chattao_app/views/bottombar_view.dart';
import 'package:flutter/material.dart';

class DiscoveryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          "Discovery",
          style: TextStyle(color: Colors.white),
        ),
      ),
      bottomNavigationBar: BottomBarView(
        context: context,
        activeIndex: 2,
      ),
      body: Container(
        child: Center(child: Text("Nothing")),
      ),
    );
  }
}
