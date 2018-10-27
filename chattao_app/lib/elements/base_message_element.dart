
import 'package:chattao_app/models/app_state.dart';
import 'package:chattao_app/models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class BaseMessageElement extends StatelessWidget {
  final Widget child;
  final ChatMessage message;
  BaseMessageElement({@required this.child, @required this.message});

  ListTile _createTile(
      BuildContext context, String title, IconData icon, Function action) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        action();
      },
    );
  }

  void _handleDelete(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.only(top: 12.0),
            color: Color(0x88888888),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _createTile(context, "Delete", Icons.delete, () {
                    message.delete();
                  }),
                  Divider(
                    color: Colors.white,
                  ),
                  _createTile(context, "Cancel", Icons.cancel, () {})
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onLongPress: () {
          var me = StoreProvider.of<AppState>(context).state.me;
          if (me.uid != message.idFrom) return;
          _handleDelete(context);
        },
        child: child);
  }
}
