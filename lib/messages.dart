import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattao_app/constants.dart';
import 'package:chattao_app/models/chat.dart';
import 'package:flutter/material.dart';

class ImageMessageContent extends StatelessWidget {
  final ChatMessage message;
  final bool isLastMessageRight;
  final bool isMyMessage;

  ImageMessageContent(
      {@required this.message,
      this.isLastMessageRight = false,
      this.isMyMessage = true});
  @override
  Widget build(BuildContext context) {
    if (message.type != 1) return Container();
    return BaseMessageView(
      message: message,
      child: Container(
        child: Material(
          child: message.localImageFile != null
              ? Row(
                  children: <Widget>[
                    message.syncing
                        ? Container(
                            padding: EdgeInsets.all(5.0),
                            height: 20.0,
                            width: 20.0,
                            child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(themeColor)),
                          )
                        : Container(),
                    Image.file(
                      message.localImageFile,
                      width: 200.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                  ],
                )
              : CachedNetworkImage(
                  placeholder: Container(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    ),
                    width: 200.0,
                    height: 200.0,
                    padding: EdgeInsets.all(70.0),
                    decoration: BoxDecoration(
                      color: greyColor2,
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                    ),
                  ),
                  errorWidget: Material(
                    child: Image.asset(
                      'images/img_not_available.jpeg',
                      width: 200.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                  ),
                  imageUrl: message.content,
                  width: 200.0,
                  height: 200.0,
                  fit: BoxFit.cover,
                ),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        margin: EdgeInsets.only(
            bottom: isLastMessageRight ? 20.0 : 10.0, right: 8.0, left: 8.0),
      ),
    );
  }
}

class BaseMessageView extends StatelessWidget {
  final Widget child;
  final ChatMessage message;
  BaseMessageView({@required this.child, @required this.message});

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
                    message.Delete();
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
          _handleDelete(context);
        },
        child: child);
  }
}

class TextMessageContent extends StatelessWidget {
  final ChatMessage message;
  final bool isLastMessageRight;
  final bool highlight;

  TextMessageContent(
      {@required this.message,
      this.isLastMessageRight = false,
      this.highlight = false});

  @override
  Widget build(BuildContext context) {
    if (message.type != 0) return Container();
    return BaseMessageView(
      message: message,
      child: Container(
        constraints: BoxConstraints(maxWidth: 200.0),
        child: Text(
          message.content,
          style: TextStyle(color: highlight ? Colors.white : primaryColor),
        ),
        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
        decoration: BoxDecoration(
            color: highlight ? themeColor : greyColor2,
            borderRadius: BorderRadius.circular(4.0)),
        margin: EdgeInsets.only(
            bottom: isLastMessageRight ? 20.0 : 10.0, right: 8.0, left: 8.0),
      ),
    );
  }
}

class StickerMessageContent extends StatelessWidget {
  final ChatMessage message;
  final bool isLastMessageRight;

  StickerMessageContent(
      {@required this.message, this.isLastMessageRight = false});

  @override
  Widget build(BuildContext context) {
    if (message.type != 2) return Container();
    return BaseMessageView(
      message: message,
      child: Container(
        child: new Image.asset(
          'images/${message.content}.gif',
          width: 100.0,
          height: 100.0,
          fit: BoxFit.cover,
        ),
        margin: EdgeInsets.only(
            bottom: isLastMessageRight ? 20.0 : 8.0, right: 8.0),
      ),
    );
  }
}

class ChatAvatar extends StatelessWidget {
  String avatarUrl;
  final double widgetHeight;

  ChatAvatar({this.avatarUrl, this.widgetHeight = 32.0}) {
    if (this.avatarUrl == null || avatarUrl.isEmpty) {
      this.avatarUrl =
          "https://www.templaza.com/blog/components/com_easyblog/themes/wireframe/images/placeholder-image.png";
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      height: widgetHeight,
      width: widgetHeight,
      color: themeColor,
      child: CachedNetworkImage(
        placeholder: Container(
          child: CircularProgressIndicator(
            strokeWidth: 1.0,
            valueColor: AlwaysStoppedAnimation<Color>(themeColor),
          ),
          width: widgetHeight,
          height: widgetHeight,
          padding: EdgeInsets.all(10.0),
        ),
        imageUrl: avatarUrl,
        width: widgetHeight,
        height: widgetHeight,
        fit: BoxFit.cover,
      ),
    );
  }
}
