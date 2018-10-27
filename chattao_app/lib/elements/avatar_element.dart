import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattao_app/constants.dart';
import 'package:flutter/material.dart';

class AvatarElement extends StatelessWidget {
  final String avatarUrl;
  final double widgetHeight;

  AvatarElement({this.avatarUrl, this.widgetHeight = 32.0});

  @override
  Widget build(
    BuildContext context,
  ) {
    var avaUrl = this.avatarUrl;
    if (this.avatarUrl == null || avatarUrl.isEmpty) {
      avaUrl =
          "https://www.templaza.com/blog/components/com_easyblog/themes/wireframe/images/placeholder-image.png";
    }
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
        imageUrl: avaUrl,
        width: widgetHeight,
        height: widgetHeight,
        fit: BoxFit.cover,
      ),
    );
  }
}
