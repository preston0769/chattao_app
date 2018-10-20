import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattao_app/chats.dart';
import 'package:chattao_app/common.dart';
import 'package:chattao_app/models/app_state.dart';
import 'package:chattao_app/models/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts"),
      ),
      body: Container(
        child: StoreConnector<AppState, List<User>>(
          converter: (store) {
            return store.state.friends;
          },
          builder: (context, friends) {
            return ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                return new ContactItemView(context, friends.elementAt(index));
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomBar(
        context: context,
        activeIndex: 1,
      ),
    );
  }
}

class ContactItemView extends StatelessWidget {
  final BuildContext context;
  final User contact;
  ContactItemView(this.context, this.contact);

  void _navToChatPage() {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new ChatView(
                  peerId: contact.uid,
                  peerAvatar: contact.avataURL,
                  peerName: contact.name,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: InkWell(
        onTap: _navToChatPage,
        onLongPress: _navToChatPage,
        onDoubleTap: _navToChatPage,
        child: Container(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: Colors.grey.withAlpha(80),
                      style: BorderStyle.solid,
                      width: 1.0))),
          child: new Row(
            children: <Widget>[
              CachedNetworkImage(
                placeholder: Container(
                  child: CircularProgressIndicator(
                    strokeWidth: 1.0,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                  ),
                  width: 40.0,
                  height: 40.0,
                ),
                imageUrl: contact.avataURL,
                width: 40.0,
                height: 40.0,
                fit: BoxFit.cover,
              ),
              SizedBox(
                width: 16.0,
              ),
              new Expanded(
                child: new Text(contact.name),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
