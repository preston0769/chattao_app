import 'dart:async';

import 'package:chattao_app/chats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FriendsPage extends StatelessWidget {
  String currentUserId;
  VoidCallback onLogOut;
  FriendsPage({@required this.currentUserId,@required this.onLogOut}){
  }

  Future<SharedPreferences> _getPreference() async {
    var prefs = await SharedPreferences.getInstance();

    return prefs;
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
            builder: (context) => new Chat(
                  peerId: document.documentID,
                  peerAvatar: document['photoUrl'],
                )));
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return new ListTile(
        key: new ValueKey(document.documentID),
        title: new Container(
          decoration: new BoxDecoration(
            border: new Border.all(color: const Color(0x80000000)),
            borderRadius: new BorderRadius.circular(5.0),
          ),
          padding: const EdgeInsets.all(10.0),
          child: new Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
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
  Widget build(BuildContext context) {
    return SafeArea(
          child: Column(
        children: <Widget>[
          Expanded(
            child: new StreamBuilder(
                stream: Firestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    );
                  return new ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      padding: const EdgeInsets.only(top: 10.0),
                      // itemExtent: 25.0,
                      itemBuilder: (context, index) {
                        DocumentSnapshot ds = snapshot.data.documents[index];
                        if (ds.documentID == currentUserId) return Container();
                        return _buildListItem(context, ds);
                      });
                }),
          ),
          Center(
            child: FlatButton(
              padding: EdgeInsets.all(16.0),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                final GoogleSignIn googleSignIn = new GoogleSignIn();
                final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
                googleSignIn.signOut();
                firebaseAuth.signOut();
                onLogOut();
                
              },
              child: Text("Log out"),
            ),
          )
        ],
      ),
    );
  }
}
