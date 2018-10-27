
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattao_app/constants.dart';
import 'package:chattao_app/elements/base_message_element.dart';
import 'package:chattao_app/models/chat_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageMessageElement extends StatelessWidget {
  final ChatMessage message;
  final bool isLastMessageRight;
  final bool isMyMessage;

  ImageMessageElement(
      {@required this.message,
      this.isLastMessageRight = false,
      this.isMyMessage = true});
  @override
  Widget build(BuildContext context) {
    if (message.type != 1) return Container();
    return BaseMessageElement(
      message: message,
      child: Container(
        child: Material(
          child: message.localImageFile != null
              ? Row(
                  children: <Widget>[
                    message.syncing
                        ? Container(
                            height: 16.0,
                            width: 16.0,
                            child: CupertinoActivityIndicator(
                              animating: true,
                              radius: 8.0,
                            ),
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
