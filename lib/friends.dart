import 'dart:async';

import 'package:chattao_app/chats.dart';
import 'package:chattao_app/common.dart';
import 'package:chattao_app/models/app_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
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

  void _toggleOnlineStatus(DocumentSnapshot document) async {
    Firestore.instance.runTransaction((transaction) async {
      DocumentSnapshot freshSnap = await transaction.get(document.reference);
      await transaction
          .update(freshSnap.reference, {'isOnline': !freshSnap['isOnline']});
    });
  }

  void _loadChatScreen(BuildContext context, DocumentSnapshot document) {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new ChatView(
                  peerId: document.documentID,
                  peerAvatar: document['photoUrl'],
                  peerName: document['name'],
                )));
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return new ListTile(
        key: new ValueKey(document.documentID),
        title: new Container(
          decoration: new BoxDecoration(
            border: new Border(
                bottom: BorderSide(
                    width: 1.0,
                    color: const Color(0x88888888),
                    style: BorderStyle.solid)),
            // borderRadius: new BorderRadius.circular(5.0),
          ),
          padding: const EdgeInsets.all(10.0),
          child: new Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                child: CachedNetworkImage(
                  placeholder: Container(
                    child: CircularProgressIndicator(
                      strokeWidth: 1.0,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                    ),
                    width: 40.0,
                    height: 40.0,
                    padding: EdgeInsets.all(15.0),
                  ),
                  imageUrl: document['photoUrl'],
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                width: 20.0,
              ),
              new Expanded(
                child: new Text(document['name']),
              ),
              new Text(
                document.documentID.substring(20),
              ),
            ],
          ),
        ),
        onTap: () {
          // _toggleOnlineStatus(document);
          _loadChatScreen(context, document);
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
                title: new Text(
                  "TaoChat",
                  style: TextStyle(color: Colors.white),
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
              backgroundColor: Color(0xFFBFBFBF),
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
                          fillColor: Colors.white.withAlpha(140),
                          filled: true,
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.transparent,
                                  width: 1.0,
                                  style: BorderStyle.none),
                              borderRadius: BorderRadius.circular(8.0)),
                          hintText: "Search friend",
                        ),
                      ),
                    ),
                    Expanded(
                      child: new StreamBuilder(
                          stream: Firestore.instance
                              .collection('users')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData)
                              return Center(
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.red),
                                ),
                              );
                            return new ListView.builder(
                                itemCount: snapshot.data.documents.length,
                                padding: const EdgeInsets.only(top: 10.0),
                                // itemExtent: 25.0,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot ds =
                                      snapshot.data.documents[index];
                                  if (ds.documentID == uid) return Container();
                                  return _buildListItem(context, ds);
                                });
                          }),
                    ),
                    StoreConnector<AppState,String>(converter: (store){
                       return store.state.message;

                    },
                     builder: ( context,content){
                       return Center(child: new Text(content));

                     },
                    )
                  ],
                ),
              ),
            ),
      onWillPop: () {},
    );
  }
}
