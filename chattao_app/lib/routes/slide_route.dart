import 'package:flutter/cupertino.dart';

class SlideRoute extends PageRouteBuilder {
  String fromDirection;
  final Widget widget;
  SlideRoute({ @required this.widget, this.fromDirection = "right"})
      : super(
            pageBuilder: (context, _, __) {
              return widget;
            },
            transitionDuration: Duration(milliseconds: 200),
            transitionsBuilder: (context, animation, animtation2, child) {
              return SlideTransition(
                position: new Tween(
                  begin: new Offset(fromDirection == 'left' ? -1.0 : 1.0, 0.0),
                  end: Offset.zero,
                ).animate( CurvedAnimation(parent: animation, curve:  Curves.easeIn)),
                child: child,
              );
            });
}
