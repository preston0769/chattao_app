
import 'package:chattao_app/elements/base_message_element.dart';
import 'package:chattao_app/models/chat_message.dart';
import 'package:flutter/material.dart';

class StickerMessageElement extends StatelessWidget {
  final ChatMessage message;
  final bool isLastMessageRight;

  StickerMessageElement(
      {@required this.message, this.isLastMessageRight = false});

  @override
  Widget build(BuildContext context) {
    if (message.type != 2) return Container();
    var localUrl = message.content;
    if (!localUrl.contains("gifs"))
      localUrl = "gifs/" +
          localUrl.substring(0, localUrl.length - 1).toString() +
          "/" +
          localUrl;
    return BaseMessageElement(
      message: message,
      child: Container(
        child: new Image.asset(
          'images/$localUrl.gif',
          width: 100.0,
          height: 100.0,
          fit: BoxFit.cover,
        )?? Center(child:Text("New Sticker")),
        margin: EdgeInsets.only(
            bottom: isLastMessageRight ? 20.0 : 8.0, right: 8.0),
      ),
    );
  }
}
