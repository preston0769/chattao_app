
import 'package:chattao_app/constants.dart';
import 'package:chattao_app/elements/base_message_element.dart';
import 'package:chattao_app/models/chat_message.dart';
import 'package:flutter/material.dart';

class TextMessageElement extends StatelessWidget {
  final ChatMessage message;
  final bool isLastMessageRight;
  final bool highlight;

  TextMessageElement(
      {@required this.message,
      this.isLastMessageRight = false,
      this.highlight = false});

  @override
  Widget build(BuildContext context) {
    if (message.type != 0) return Container();
    return BaseMessageElement(
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
