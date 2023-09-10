import 'package:flutter/material.dart';

class AnimatedChild extends AnimatedWidget {
  final int index;
  final Color backgroundColor;
  final Color foregroundColor;
  final double elevation;
  final Widget child;
  final String? label;
  final TextStyle labelStyle;
  final Color labelBackgroundColor;
  final bool visible;
  final VoidCallback onTap;
  final VoidCallback toggleChildren;
  final ShapeBorder shape;
  final String heroTag;

  AnimatedChild({
    Key? key,
    required Animation<double> animation,
    required this.index,
    required this.backgroundColor,
    required this.foregroundColor,
    this.elevation = 6.0,
    required this.child,
    this.label,
    required this.labelStyle,
    required this.labelBackgroundColor,
    this.visible = false,
    required this.onTap,
    required this.toggleChildren,
    required this.shape,
    required this.heroTag,
  }) : super(key: key, listenable: animation);

  Widget _renderLabel() {
    final Animation<double> animation = listenable as Animation<double>;
    if (label != null && visible && animation.value == 62.0) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        margin: EdgeInsets.only(right: 18.0),
        decoration: BoxDecoration(
          color: labelBackgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(6.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.7),
              offset: Offset(0.8, 0.8),
              blurRadius: 2.4,
            )
          ],
        ),
        child: Text(label ?? "", style: labelStyle),
      );
    }
    return Container();
  }

  void _performAction() {
    if (onTap != null) onTap();
    toggleChildren();
  }

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          _renderLabel(),
          Container(
            width: 62.0,
            height: animation.value,
            padding: EdgeInsets.only(bottom: 62.0 - animation.value),
            child: Container(
              height: 62.0,
              width: animation.value,
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: FloatingActionButton(
                heroTag: heroTag,
                onPressed: _performAction,
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                elevation: elevation,
                child: animation.value > 50.0
                    ? Container(
                        width: animation.value,
                        height: animation.value,
                        child: child,
                      )
                    : Container(width: 0.0, height: 0.0),
              ),
            ),
          )
        ],
      ),
    );
  }
}
