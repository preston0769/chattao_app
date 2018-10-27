import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattao_app/actions/app_actions.dart';
import 'package:chattao_app/models/app_state.dart';
import 'package:chattao_app/models/chat.dart';
import 'package:chattao_app/pages/chat_page.dart';
import 'package:chattao_app/routes/scale_route.dart';
import 'package:chattao_app/views/bottombar_view.dart';
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
        elevation: 0.0,
        title: Text(
          "Contacts",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
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
                fillColor: Colors.white.withAlpha(200),
                filled: true,
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black.withAlpha(200),
                        width: 1.0,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8.0)),
                hintText: "Search friend",
              ),
            ),
          ),
          Expanded(
            child: StoreConnector<AppState, List<User>>(
              converter: (store) {
                return store.state.friends;
              },
              builder: (context, friends) {
                return ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    return new ContactItemView(
                        context, friends.elementAt(index));
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBarView(
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
        new ScaleRoute(
            widget: new ChatPage(
          peerId: contact.uid,
          peerAvatar: contact.avataURL,
          peerName: contact.name,
        )));
    StoreProvider.of<AppState>(context)
        .dispatch(UpdateRouteNameAction("/chatView"));
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
