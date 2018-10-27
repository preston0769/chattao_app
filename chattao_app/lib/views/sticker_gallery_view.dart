import 'dart:math';

import 'package:chattao_app/constants.dart';
import 'package:flutter/material.dart';

class StickerGalleryView extends StatelessWidget {
  final Function(String, int) onStickerSelected;

  final PageController controller =
      new PageController(viewportFraction: 1.0, initialPage: 0);

  final _kDuration = const Duration(milliseconds: 300);
  final _kCurve = Curves.ease;

  StickerGalleryView({@required this.onStickerSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 200.0),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          PageView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                StickerPage(
                  onStickerSelected: onStickerSelected,
                ),
                StickerPage2(
                  onStickerSelected: onStickerSelected,
                ),
                StickerPage3(
                  onStickerSelected: onStickerSelected,
                )
              ]),
          new Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: new Container(
                  // color: Colors.grey[800].withOpacity(0.5),
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: new Center(
                    child: new DotsIndicator(
                      controller: controller,
                      itemCount: 3,
                      color: greyColor,
                      onPageSelected: (int page) {
                        controller.animateToPage(
                          page,
                          duration: _kDuration,
                          curve: _kCurve,
                        );
                      },
                    ),
                  ))),
        ],
      ),
    );
  }
}

class StickerPage extends StatelessWidget {
  final Function(String, int) onStickerSelected;
  StickerPage({@required this.onStickerSelected});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onStickerSelected('mimi1', 2),
                child: new Image.asset(
                  'images/gifs/mimi/mimi1.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onStickerSelected('mimi2', 2),
                child: new Image.asset(
                  'images/gifs/mimi/mimi2.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onStickerSelected('mimi3', 2),
                child: new Image.asset(
                  'images/gifs/mimi/mimi3.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onStickerSelected('mimi4', 2),
                child: new Image.asset(
                  'images/gifs/mimi/mimi4.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onStickerSelected('mimi5', 2),
                child: new Image.asset(
                  'images/gifs/mimi/mimi5.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onStickerSelected('mimi6', 2),
                child: new Image.asset(
                  'images/gifs/mimi/mimi6.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onStickerSelected('mimi7', 2),
                child: new Image.asset(
                  'images/gifs/mimi/mimi7.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onStickerSelected('mimi8', 2),
                child: new Image.asset(
                  'images/gifs/mimi/mimi8.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onStickerSelected('mimi9', 2),
                child: new Image.asset(
                  'images/gifs/mimi/mimi9.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: new BoxDecoration(
          border:
              new Border(top: new BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }
}

class StickerPage2 extends StatelessWidget {
  final Function(String, int) onStickerSelected;
  StickerPage2({@required this.onStickerSelected});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onStickerSelected('doubi1', 2),
                child: new Image.asset(
                  'images/gifs/doubi/doubi1.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onStickerSelected('doubi2', 2),
                child: new Image.asset(
                  'images/gifs/doubi/doubi2.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onStickerSelected('doubi3', 2),
                child: new Image.asset(
                  'images/gifs/doubi/doubi3.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onStickerSelected('doubi4', 2),
                child: new Image.asset(
                  'images/gifs/doubi/doubi4.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onStickerSelected('doubi5', 2),
                child: new Image.asset(
                  'images/gifs/doubi/doubi5.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onStickerSelected('doubi6', 2),
                child: new Image.asset(
                  'images/gifs/doubi/doubi6.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onStickerSelected('doubi7', 2),
                child: new Image.asset(
                  'images/gifs/doubi/doubi7.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onStickerSelected('doubi8', 2),
                child: new Image.asset(
                  'images/gifs/doubi/doubi8.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onStickerSelected('doubi9', 2),
                child: new Image.asset(
                  'images/gifs/doubi/doubi9.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: new BoxDecoration(
          border:
              new Border(top: new BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }
}

class StickerPage3 extends StatelessWidget {
  final Function(String, int) onStickerSelected;
  StickerPage3({@required this.onStickerSelected});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onStickerSelected('miao1', 2),
                child: new Image.asset(
                  'images/gifs/miao/miao1.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onStickerSelected('miao2', 2),
                child: new Image.asset(
                  'images/gifs/miao/miao2.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onStickerSelected('miao3', 2),
                child: new Image.asset(
                  'images/gifs/miao/miao3.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onStickerSelected('miao4', 2),
                child: new Image.asset(
                  'images/gifs/miao/miao4.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onStickerSelected('miao5', 2),
                child: new Image.asset(
                  'images/gifs/miao/miao5.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onStickerSelected('miao6', 2),
                child: new Image.asset(
                  'images/gifs/miao/miao6.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onStickerSelected('miao7', 2),
                child: new Image.asset(
                  'images/gifs/miao/miao7.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onStickerSelected('miao8', 2),
                child: new Image.asset(
                  'images/gifs/miao/miao8.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onStickerSelected('miao9', 2),
                child: new Image.asset(
                  'images/gifs/miao/miao9.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: new BoxDecoration(
          border:
              new Border(top: new BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }
}

class DotsIndicator extends AnimatedWidget {
  DotsIndicator({
    this.controller,
    this.itemCount,
    this.onPageSelected,
    this.color: Colors.white,
  }) : super(listenable: controller);

  /// The PageController that this DotsIndicator is representing.
  final PageController controller;

  /// The number of items managed by the PageController
  final int itemCount;

  /// Called when a dot is tapped
  final ValueChanged<int> onPageSelected;

  /// The color of the dots.
  ///
  /// Defaults to `Colors.white`.
  final Color color;

  // The base size of the dots
  static const double _kDotSize = 4.0;

  // The increase in the size of the selected dot
  static const double _kMaxZoom = 1.8;

  // The distance between the center of each dot
  static const double _kDotSpacing = 12.0;

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((controller.page ?? controller.initialPage) - index).abs(),
      ),
    );
    double zoom = 1.0 + (_kMaxZoom - 1.0) * selectedness;
    return new Container(
      width: _kDotSpacing,
      child: new Center(
        child: new Material(
          color: color,
          type: MaterialType.circle,
          child: new Container(
            width: _kDotSize * zoom,
            height: _kDotSize * zoom,
            child: new InkWell(
              onTap: () => onPageSelected(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: new List<Widget>.generate(itemCount, _buildDot),
    );
  }
}
