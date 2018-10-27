import 'package:flutter/material.dart';

class FadeSlideRoute extends PageRouteBuilder {
  final Widget widget;
  FadeSlideRoute({this.widget})
      : super(pageBuilder: (BuildContext context, _, __) {
          return widget;
        }, transitionsBuilder:
            (_, Animation<double> animation, __, Widget child) {
          return new FadeTransition(
            opacity: animation,
            child: new SlideTransition(
                position: new Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child),
          );
        });
}